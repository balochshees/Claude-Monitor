//
//  ClaudeAPIService.swift
//  Claude Monitor
//
//  Created by Tim Morgan on 12/3/25.
//

import Foundation
import Logging

/// Errors that can occur when communicating with the Claude API.
///
/// All cases conform to `LocalizedError` to provide user-friendly messages
/// with descriptions, failure reasons, and recovery suggestions where applicable.
enum APIError: Error, LocalizedError {
  /// No API token is available or configured.
  case noToken

  /// The API URL could not be constructed.
  case invalidURL

  /// The server returned an HTTP error status code.
  ///
  /// - Parameters:
  ///   - statusCode: The HTTP status code (e.g., 401, 429, 500).
  ///   - message: Optional error message from the response body.
  case httpError(statusCode: Int, message: String?)

  /// The response could not be decoded as expected JSON.
  ///
  /// - Parameter error: The underlying decoding error.
  case decodingError(Error)

  /// A network-level error occurred (e.g., no connection, timeout).
  ///
  /// - Parameter error: The underlying network error.
  case networkError(Error)

  var errorDescription: String? {
    String(localized: "Could not access the Claude API.")
  }

  var failureReason: String? {
    switch self {
      case .noToken: String(localized: "No API token is available.")
      case .invalidURL: String(localized: "The API URL is invalid.")
      case let .httpError(code, msg):
        if let msg {
          String(localized: "The server returned HTTP \(code): \(msg)")
        } else {
          String(localized: "The server returned HTTP \(code).")
        }
      case .decodingError(let error):
        String(localized: "Failed to parse the server response: \(error.localizedDescription)")
      case .networkError(let error):
        String(localized: "A network error occurred: \(error.localizedDescription)")
    }
  }

  var recoverySuggestion: String? {
    switch self {
      case .noToken: String(localized: "Configure a Claude API token in Settings.")
      case .invalidURL: nil
      case .httpError(let code, _):
        if code == 401 {
          String(
            localized:
              "Your token may be invalid or expired. Try re-authenticating in Claude Code or entering a new token."
          )
        } else if code == 429 {
          String(localized: "You've exceeded the rate limit. Please wait before trying again.")
        } else {
          nil
        }
      case .decodingError: nil
      case .networkError: String(localized: "Check your internet connection and try again.")
    }
  }
}

/// A service for communicating with the Anthropic Claude API.
///
/// `ClaudeAPIService` is a thread-safe singleton that handles all API communication
/// with the Anthropic OAuth usage endpoint. It manages request construction,
/// authentication headers, and response parsing.
///
/// ## Usage
/// ```swift
/// let service = ClaudeAPIService.shared
/// let usage = try await service.fetchUsage(token: "sk-ant-oat...")
/// ```
///
/// ## Thread Safety
/// This service is `Sendable` and safe to use from any actor or thread.
final class ClaudeAPIService: Sendable {
  /// The shared singleton instance.
  static let shared = ClaudeAPIService()

  private let baseURL = "https://api.anthropic.com"
  private let usagePath = "/api/oauth/usage"
  private let logger = Logger(label: "codes.tim.Claude-Monitor.ClaudeAPIService")

  private init() {}

  /// Fetches the current usage data from the Claude API.
  ///
  /// This method calls the OAuth usage endpoint to retrieve the user's
  /// current usage limits across all quota buckets.
  ///
  /// - Parameter token: A valid OAuth token (starts with `sk-ant-oat`).
  /// - Returns: A ``UsageResponse`` containing all usage buckets.
  /// - Throws: An ``APIError`` if the request fails.
  func fetchUsage(token: String) async throws -> UsageResponse {
    guard let url = URL(string: baseURL + usagePath) else {
      throw APIError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
    request.setValue("claude-code/2.0.32", forHTTPHeaderField: "User-Agent")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    logger.debug("Fetching usage data")

    do {
      let (data, response) = try await URLSession.shared.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.networkError(NSError(domain: "Invalid response", code: -1))
      }

      guard (200...299).contains(httpResponse.statusCode) else {
        let message = String(data: data, encoding: .utf8)
        logger.warning("HTTP error", metadata: ["statusCode": "\(httpResponse.statusCode)"])
        throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
      }

      do {
        let response = try JSONDecoder().decode(UsageResponse.self, from: data)
        logger.debug("Successfully fetched usage data")
        return response
      } catch {
        logger.error("Failed to decode response", metadata: ["error": "\(error)"])
        throw APIError.decodingError(error)
      }
    } catch let error as APIError {
      throw error
    } catch {
      logger.error("Network error", metadata: ["error": "\(error)"])
      throw APIError.networkError(error)
    }
  }

  /// Validates whether a token is valid by attempting to fetch usage data.
  ///
  /// This is a convenience method that attempts a real API call and returns
  /// whether it succeeded. Use this to validate user-entered tokens before saving.
  ///
  /// - Parameter token: The token to validate.
  /// - Returns: `true` if the token is valid and the API call succeeded.
  func validateToken(_ token: String) async -> Bool {
    do {
      _ = try await fetchUsage(token: token)
      return true
    } catch {
      return false
    }
  }
}
