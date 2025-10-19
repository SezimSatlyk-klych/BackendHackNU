//
//  ImageGeneration.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - Image Generation Models

struct ImageGeneration: Codable, Identifiable {
    let id: Int
    let prompt: String
    let imageUrl: String?
    let status: ImageGenerationStatus
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case prompt
        case imageUrl = "image_url"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ImageGenerationStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .processing:
            return "Processing"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        }
    }
    
    var isProcessing: Bool {
        return self == .pending || self == .processing
    }
    
    var isCompleted: Bool {
        return self == .completed
    }
    
    var isFailed: Bool {
        return self == .failed
    }
}

// MARK: - Image Generation Request
struct ImageGenerationRequest: Codable {
    let prompt: String
}

// MARK: - Image Generation Response
struct ImageGenerationResponse: Codable {
    let id: Int
    let prompt: String
    let imageUrl: String?
    let status: ImageGenerationStatus
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case prompt
        case imageUrl = "image_url"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Force Generation Response
struct ForceGenerationResponse: Codable {
    let message: String
    let generationId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case generationId = "generation_id"
    }
}
