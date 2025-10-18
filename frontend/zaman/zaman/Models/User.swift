//
//  User.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - User Model (matches Django serializer)
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let surname: String
    let type: String // "adult" | "child"
    let email: String
    // Note: password excluded from response (write_only in serializer)
    
    var fullName: String {
        return "\(name) \(surname)"
    }
    
    var isAdult: Bool {
        return type == "adult"
    }
}

// MARK: - Login Request Model
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Login Response Model
struct LoginResponse: Codable {
    let id: Int
    let name: String
    let surname: String
    let email: String
    let type: String
}
