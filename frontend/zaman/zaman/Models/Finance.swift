//
//  Finance.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - Finance Model (matches Django serializer)
struct Finance: Codable, Identifiable {
    let id: Int
    let currentState: Decimal
    let transactionFrom: Int  // FK ID to TransactionFrom
    let transactionTo: Int    // FK ID to TransactionTo
    let goals: Int            // FK ID to Goal
    
    enum CodingKeys: String, CodingKey {
        case id
        case currentState = "current_state"
        case transactionFrom = "transaction_from"
        case transactionTo = "transaction_to"
        case goals
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Handle decimal as string from API
        let currentStateString = try container.decode(String.self, forKey: .currentState)
        currentState = Decimal(string: currentStateString) ?? 0
        
        transactionFrom = try container.decode(Int.self, forKey: .transactionFrom)
        transactionTo = try container.decode(Int.self, forKey: .transactionTo)
        goals = try container.decode(Int.self, forKey: .goals)
    }
}

// MARK: - Transaction Models (separate for incoming/outgoing)
struct TransactionFrom: Codable, Identifiable {
    let id: Int
    let sum: Decimal
    let type: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Handle decimal as string from API
        let sumString = try container.decode(String.self, forKey: .sum)
        sum = Decimal(string: sumString) ?? 0
        
        type = try container.decode(String.self, forKey: .type)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, sum, type
    }
}

struct TransactionTo: Codable, Identifiable {
    let id: Int
    let sum: Decimal
    let type: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Handle decimal as string from API
        let sumString = try container.decode(String.self, forKey: .sum)
        sum = Decimal(string: sumString) ?? 0
        
        type = try container.decode(String.self, forKey: .type)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, sum, type
    }
}

// MARK: - Goal Model (matches Django serializer)
struct Goal: Codable, Identifiable {
    let id: Int
    let goalDesc: String
    let goalSum: Decimal
    let goalProgress: Decimal
    
    enum CodingKeys: String, CodingKey {
        case id
        case goalDesc = "goal_desc"
        case goalSum = "goal_sum"
        case goalProgress = "goal_progress"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        goalDesc = try container.decode(String.self, forKey: .goalDesc)
        
        // Handle decimal as string from API
        let goalSumString = try container.decode(String.self, forKey: .goalSum)
        goalSum = Decimal(string: goalSumString) ?? 0
        
        let goalProgressString = try container.decode(String.self, forKey: .goalProgress)
        goalProgress = Decimal(string: goalProgressString) ?? 0
    }
    
    var progressPercentage: Double {
        return Double(truncating: goalProgress as NSDecimalNumber)
    }
    
    var isCompleted: Bool {
        return goalProgress >= 100
    }
}

// MARK: - Savings Model (matches Django serializer)
struct Savings: Codable, Identifiable {
    let id: Int
    let goal: Int
    let sum: Decimal
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        goal = try container.decode(Int.self, forKey: .goal)
        
        // Handle decimal as string from API
        let sumString = try container.decode(String.self, forKey: .sum)
        sum = Decimal(string: sumString) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, goal, sum
    }
}
