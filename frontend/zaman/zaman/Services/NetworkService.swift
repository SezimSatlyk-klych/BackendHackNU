//
//  NetworkService.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import Combine

// MARK: - Network Service
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = NetworkConfig.baseURL
    private let session = URLSession.shared
    private var authToken: String?
    
    private init() {}
    
    // MARK: - Authentication
    func login(email: String, password: String) async throws -> LoginResponse {
        let url = URL(string: "\(baseURL)/users/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            // Store auth token for future requests
            self.authToken = "user_\(loginResponse.id)" // Simple token for now
            return loginResponse
        case 401:
            throw NetworkError.authenticationFailed
        case 400:
            throw NetworkError.badRequest
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    func logout() {
        authToken = nil
        // Clear any cached data
        URLCache.shared.removeAllCachedResponses()
    }
    
    // MARK: - User Operations
    func fetchUser(id: Int) async throws -> User {
        let url = URL(string: "\(baseURL)/users/\(id)/")!
        return try await performAuthenticatedRequest(url: url, responseType: User.self)
    }
    
    // MARK: - Finance Operations
    func fetchFinance() async throws -> [Finance] {
        let url = URL(string: "\(baseURL)/finance/")!
        return try await performRequest(url: url, responseType: [Finance].self)
    }
    
    // MARK: - Transaction Operations
    func fetchTransactionsFrom() async throws -> [TransactionFrom] {
        let url = URL(string: "\(baseURL)/transaction-from/")!
        return try await performRequest(url: url, responseType: [TransactionFrom].self)
    }
    
    func fetchTransactionsTo() async throws -> [TransactionTo] {
        let url = URL(string: "\(baseURL)/transaction-to/")!
        return try await performRequest(url: url, responseType: [TransactionTo].self)
    }
    
    // MARK: - Goals Operations
    func fetchGoals() async throws -> [Goal] {
        let url = URL(string: "\(baseURL)/goals/")!
        return try await performRequest(url: url, responseType: [Goal].self)
    }
    
    // MARK: - Savings Operations
    func fetchSavings() async throws -> [Savings] {
        let url = URL(string: "\(baseURL)/savings/")!
        return try await performRequest(url: url, responseType: [Savings].self)
    }
    
    // MARK: - Generic Request Method
    private func performRequest<T: Codable>(url: URL, responseType: T.Type) async throws -> T {
        print("🌐 NetworkService: Making request to \(url)")
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ NetworkService: Invalid response")
            throw NetworkError.invalidResponse
        }
        
        print("📡 NetworkService: Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ NetworkService: Request failed with status \(httpResponse.statusCode)")
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
        
        print("✅ NetworkService: Request successful, decoding data...")
        return try JSONDecoder().decode(responseType, from: data)
    }
    
    // MARK: - Authenticated Request Method
    private func performAuthenticatedRequest<T: Codable>(url: URL, responseType: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        
        // Add authentication header if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(responseType, from: data)
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500:
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case authenticationFailed
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case requestFailed(Int)
    case decodingFailed
    case networkUnavailable
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed:
            return "Authentication failed"
        case .badRequest:
            return "Bad request - check your input"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error - please try again later"
        case .requestFailed(let code):
            return "Request failed with status code: \(code)"
        case .decodingFailed:
            return "Failed to decode response"
        case .networkUnavailable:
            return "Network unavailable - check your connection"
        case .timeout:
            return "Request timeout - please try again"
        }
    }
}
