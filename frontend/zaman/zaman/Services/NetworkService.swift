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
    
    // MARK: - AI Chat Operations
    func sendAIChatMessage(question: String, context: String? = nil) async throws -> AIChatResponse {
        let url = URL(string: "\(baseURL)/ai/chat/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chatRequest = AIChatRequest(question: question, context: context)
        request.httpBody = try JSONEncoder().encode(chatRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("🤖 AI Chat: Response status: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            let chatResponse = try JSONDecoder().decode(AIChatResponse.self, from: data)
            print("✅ AI Chat: Success - \(chatResponse.answer.prefix(50))...")
            return chatResponse
        case 400:
            let errorResponse = try JSONDecoder().decode(AIChatErrorResponse.self, from: data)
            throw NetworkError.badRequest
        case 500:
            let errorResponse = try JSONDecoder().decode(AIChatErrorResponse.self, from: data)
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    // MARK: - Broker Company Operations
    
    // Company Assessments
    func fetchCompanyAssessments() async throws -> [CompanyAssessment] {
        let url = URL(string: "\(baseURL)/broker/company-assessments/")!
        return try await performRequest(url: url, responseType: [CompanyAssessment].self)
    }
    
    func createCompanyAssessment(_ assessment: CompanyAssessment) async throws -> CompanyAssessment {
        let url = URL(string: "\(baseURL)/broker/company-assessments/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(assessment)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(CompanyAssessment.self, from: data)
    }
    
    func calculateCompanyScore(assessmentId: Int) async throws -> [String: Any] {
        let url = URL(string: "\(baseURL)/broker/company-assessments/\(assessmentId)/calculate_score/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
        
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
    
    // Halal Certificates
    func fetchHalalCertificates() async throws -> [HalalCertificate] {
        let url = URL(string: "\(baseURL)/broker/halal-certificates/")!
        return try await performRequest(url: url, responseType: [HalalCertificate].self)
    }
    
    // Suppliers
    func fetchSuppliers() async throws -> [Supplier] {
        let url = URL(string: "\(baseURL)/broker/suppliers/")!
        return try await performRequest(url: url, responseType: [Supplier].self)
    }
    
    // Partnerships
    func fetchPartnerships() async throws -> [Partnership] {
        let url = URL(string: "\(baseURL)/broker/partnerships/")!
        return try await performRequest(url: url, responseType: [Partnership].self)
    }
    
    // Ingredients
    func fetchIngredients() async throws -> [Ingredient] {
        let url = URL(string: "\(baseURL)/broker/ingredients/")!
        return try await performRequest(url: url, responseType: [Ingredient].self)
    }
    
    // MARK: - LLM Analysis Operations
    
    func analyzeIngredientHalal(_ ingredientName: String) async throws -> HalalAnalysisResponse {
        let url = URL(string: "\(baseURL)/broker/llm/analyze-ingredient/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let analysisRequest = HalalAnalysisRequest(ingredientName: ingredientName)
        request.httpBody = try JSONEncoder().encode(analysisRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(HalalAnalysisResponse.self, from: data)
        case 400:
            throw NetworkError.badRequest
        case 503:
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    func gradeCompanyCompliance(companyId: Int? = nil, companyName: String? = nil, useDb: Bool = true, companyData: CompanyData? = nil) async throws -> CompanyGradingResponse {
        let url = URL(string: "\(baseURL)/broker/llm/grade-company/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let gradingRequest = CompanyGradingRequest(
            companyId: companyId,
            companyName: companyName,
            useDb: useDb,
            companyData: companyData
        )
        request.httpBody = try JSONEncoder().encode(gradingRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(CompanyGradingResponse.self, from: data)
        case 400:
            throw NetworkError.badRequest
        case 503:
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    func generateResearchReport(topic: String) async throws -> ResearchReportResponse {
        let url = URL(string: "\(baseURL)/broker/llm/generate-report/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let reportRequest = ResearchReportRequest(topic: topic)
        request.httpBody = try JSONEncoder().encode(reportRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(ResearchReportResponse.self, from: data)
        case 400:
            throw NetworkError.badRequest
        case 503:
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    func performBatchAnalysis(limit: Int = 10, statusFilter: String? = nil) async throws -> BatchAnalysisResponse {
        let url = URL(string: "\(baseURL)/broker/llm/batch-analysis/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let batchRequest = BatchAnalysisRequest(limit: limit, statusFilter: statusFilter)
        request.httpBody = try JSONEncoder().encode(batchRequest)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(BatchAnalysisResponse.self, from: data)
        case 400:
            throw NetworkError.badRequest
        case 503:
            throw NetworkError.serverError
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
    }
    
    func predictCompanyAuditPass(companyId: Int? = nil, analyzeAll: Bool = false, limit: Int = 50) async throws -> CompanyPredictionResponse {
        var urlComponents = URLComponents(string: "\(baseURL)/broker/llm/prediction/")!
        
        var queryItems: [URLQueryItem] = []
        if let companyId = companyId {
            queryItems.append(URLQueryItem(name: "company_id", value: String(companyId)))
        }
        if analyzeAll {
            queryItems.append(URLQueryItem(name: "all", value: "true"))
        }
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        
        urlComponents.queryItems = queryItems
        
        let (data, response) = try await session.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(CompanyPredictionResponse.self, from: data)
        case 400:
            throw NetworkError.badRequest
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }
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
