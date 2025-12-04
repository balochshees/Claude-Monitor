//
//  KeychainService.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation
import Logging
import Security

/// Errors that can occur when accessing the macOS Keychain.
///
/// All cases conform to `LocalizedError` to provide user-friendly messages
/// with descriptions, failure reasons, and recovery suggestions.
enum KeychainError: Error, LocalizedError {
  /// The requested item was not found in the Keychain.
  case itemNotFound

  /// An item with the same identifier already exists.
  case duplicateItem

  /// An unexpected Keychain status code was returned.
  ///
  /// - Parameter status: The `OSStatus` code from the Security framework.
  case unexpectedStatus(OSStatus)

  /// The data retrieved from Keychain could not be parsed.
  case invalidData

  var errorDescription: String? {
    String(localized: "Could not access your Anthropic credentials.")
  }

  var failureReason: String? {
    switch self {
      case .itemNotFound: String(localized: "The token was not found in Keychain.")
      case .duplicateItem: String(localized: "A token with this identifier already exists.")
      case .unexpectedStatus(let status):
        String(localized: "Unexpected Keychain status code: \(status).")
      case .invalidData: String(localized: "The token data is invalid or corrupted.")
    }
  }

  var recoverySuggestion: String? {
    switch self {
      case .itemNotFound: String(localized: "Configure a token in Settings.")
      case .duplicateItem: String(localized: "Clear the existing token before saving a new one.")
      case .unexpectedStatus: nil
      case .invalidData: String(localized: "Try clearing and re-entering your token.")
    }
  }
}

/// The source of an OAuth token.
///
/// Claude Monitor can obtain tokens from multiple sources, and this enum
/// identifies which source a token came from.
enum TokenSource: String {
  /// Token was read from the Claude Code application's Keychain entry.
  case claudeCode

  /// Token was manually entered by the user in Settings.
  case manual
}

/// A service for secure token storage and retrieval using the macOS Keychain.
///
/// `KeychainService` manages two token sources:
/// 1. **Claude Code** — Reads tokens from the Claude Code CLI's Keychain entry (read-only)
/// 2. **Manual** — Manages the app's own Keychain entry for user-entered tokens
///
/// ## Token Resolution
/// Use ``resolveToken(preferredSource:)`` to automatically select the best available
/// token based on user preference with fallback behavior.
///
/// ## Thread Safety
/// This service is `Sendable` and safe to use from any actor or thread.
///
/// ## Example
/// ```swift
/// let service = KeychainService.shared
/// if let (token, source) = service.resolveToken(preferredSource: .claudeCode) {
///   print("Using token from \(source)")
/// }
/// ```
final class KeychainService: Sendable {
  /// The shared singleton instance.
  static let shared = KeychainService()

  private let appServiceName = "codes.tim.Claude-Monitor"
  private let appAccountName = "api-token"
  private let claudeCodeServiceName = "Claude Code-credentials"
  private let logger = Logger(label: "codes.tim.Claude-Monitor.KeychainService")

  /// Whether a Claude Code token is available in the Keychain.
  var isClaudeCodeTokenAvailable: Bool {
    (try? readClaudeCodeToken()) != nil
  }

  /// Whether a manually-entered token is available in the Keychain.
  var isManualTokenAvailable: Bool {
    (try? readManualToken()) != nil
  }

  private init() {}

  // MARK: - Claude Code Token (Primary - Read Only)

  /// Reads the OAuth token from Claude Code's Keychain entry.
  ///
  /// Claude Code stores its credentials as JSON in the Keychain. This method
  /// retrieves and parses that JSON to extract the OAuth access token.
  ///
  /// - Returns: The OAuth access token string.
  /// - Throws: A ``KeychainError`` if the token cannot be read or parsed.
  func readClaudeCodeToken() throws -> String {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: claudeCodeServiceName,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status == errSecSuccess else {
      if status == errSecItemNotFound {
        logger.debug("Claude Code token not found in Keychain")
        throw KeychainError.itemNotFound
      }
      logger.error("Failed to read Claude Code token", metadata: ["status": "\(status)"])
      throw KeychainError.unexpectedStatus(status)
    }

    guard let data = result as? Data,
      let jsonString = String(data: data, encoding: .utf8)
    else {
      logger.error("Invalid data format for Claude Code token")
      throw KeychainError.invalidData
    }

    logger.debug("Successfully read Claude Code token")
    return try parseClaudeCodeCredentials(jsonString)
  }

  private func parseClaudeCodeCredentials(_ json: String) throws -> String {
    guard let data = json.data(using: .utf8) else {
      throw KeychainError.invalidData
    }

    struct Credentials: Codable {
      let claudeAiOauth: OAuth

      struct OAuth: Codable {
        let accessToken: String
      }
    }

    let credentials = try JSONDecoder().decode(Credentials.self, from: data)
    return credentials.claudeAiOauth.accessToken
  }

  // MARK: - Manual Token (Secondary - Read/Write)

  /// Saves a manually-entered token to the app's Keychain entry.
  ///
  /// This method stores the token securely in the Keychain. If a token already
  /// exists, it is deleted before saving the new one.
  ///
  /// - Parameter token: The OAuth token to save.
  /// - Throws: A ``KeychainError`` if the token cannot be saved.
  func saveManualToken(_ token: String) throws {
    guard let data = token.data(using: .utf8) else {
      throw KeychainError.invalidData
    }

    try? deleteManualToken()

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: appServiceName,
      kSecAttrAccount as String: appAccountName,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]

    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecSuccess else {
      logger.error("Failed to save manual token", metadata: ["status": "\(status)"])
      throw KeychainError.unexpectedStatus(status)
    }

    logger.info("Saved manual token to Keychain")
  }

  /// Reads the manually-entered token from the app's Keychain entry.
  ///
  /// - Returns: The saved OAuth token string.
  /// - Throws: A ``KeychainError`` if no token exists or it cannot be read.
  func readManualToken() throws -> String {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: appServiceName,
      kSecAttrAccount as String: appAccountName,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status == errSecSuccess else {
      if status == errSecItemNotFound {
        throw KeychainError.itemNotFound
      }
      throw KeychainError.unexpectedStatus(status)
    }

    guard let data = result as? Data,
      let token = String(data: data, encoding: .utf8)
    else {
      throw KeychainError.invalidData
    }

    return token
  }

  /// Deletes the manually-entered token from the app's Keychain entry.
  ///
  /// This method is safe to call even if no token exists.
  ///
  /// - Throws: A ``KeychainError`` if an unexpected error occurs.
  func deleteManualToken() throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: appServiceName,
      kSecAttrAccount as String: appAccountName
    ]

    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.unexpectedStatus(status)
    }
  }

  // MARK: - Token Resolution

  /// Resolves the token from the user's preferred source.
  ///
  /// This method only returns a token from the specified source. If the preferred
  /// source has no token available, `nil` is returned (no fallback).
  ///
  /// - Parameter preferredSource: The user's preferred token source.
  /// - Returns: A tuple of the token and its source, or `nil` if no token is available.
  func resolveToken(preferredSource: TokenSource) -> (token: String, source: TokenSource)? {
    switch preferredSource {
      case .claudeCode:
        if let token = try? readClaudeCodeToken() {
          return (token, .claudeCode)
        }
      case .manual:
        if let token = try? readManualToken() {
          return (token, .manual)
        }
    }
    return nil
  }
}
