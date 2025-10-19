//
//  AIChat.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - AI Chat Request
struct AIChatRequest: Codable {
    let question: String
    let context: String?
    
    init(question: String, context: String? = nil) {
        self.question = question
        self.context = context
    }
}

// MARK: - AI Chat Response
struct AIChatResponse: Codable {
    let success: Bool
    let answer: String
    let question: String
    let model: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case answer
        case question
        case model
        case error
    }
}

// MARK: - AI Chat Error Response
struct AIChatErrorResponse: Codable {
    let error: String
}
