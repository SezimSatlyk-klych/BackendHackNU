//
//  HomeViewModel.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var finance: [Finance] = []
    @Published var goals: [Goal] = []
    @Published var transactionsFrom: [TransactionFrom] = []
    @Published var transactionsTo: [TransactionTo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    func loadData() async {
        print("🔄 HomeViewModel: Starting to load data...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Always fetch fresh data from database - no caching
            print("📡 HomeViewModel: Fetching data from API...")
            async let financeData = networkService.fetchFinance()
            async let goalsData = networkService.fetchGoals()
            async let transactionsFromData = networkService.fetchTransactionsFrom()
            async let transactionsToData = networkService.fetchTransactionsTo()
            
            let (financeResult, goalsResult, transactionsFromResult, transactionsToResult) = try await (
                financeData, goalsData, transactionsFromData, transactionsToData
            )
            
            print("✅ HomeViewModel: Data fetched successfully")
            print("📊 Finance records: \(financeResult.count)")
            print("🎯 Goals: \(goalsResult.count)")
            print("💰 Transactions From: \(transactionsFromResult.count)")
            print("💸 Transactions To: \(transactionsToResult.count)")
            
            finance = financeResult
            goals = goalsResult
            transactionsFrom = transactionsFromResult
            transactionsTo = transactionsToResult
            
        } catch {
            print("❌ HomeViewModel: Error loading data: \(error.localizedDescription)")
            // Handle specific network errors
            if let networkError = error as? NetworkError {
                switch networkError {
                case .unauthorized:
                    errorMessage = "Please login again to access your data"
                case .forbidden:
                    errorMessage = "Access denied. Please check your permissions"
                case .notFound:
                    errorMessage = "Data not found"
                case .serverError:
                    errorMessage = "Server error. Please try again later"
                case .networkUnavailable:
                    errorMessage = "No internet connection. Please check your network"
                default:
                    errorMessage = networkError.localizedDescription
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func clearData() {
        finance = []
        goals = []
        transactionsFrom = []
        transactionsTo = []
        errorMessage = nil
        isLoading = false
    }
    
    var currentBalance: Decimal {
        finance.first?.currentState ?? 0
    }
    
    var totalIncoming: Decimal {
        transactionsFrom.reduce(0) { $0 + $1.sum }
    }
    
    var totalOutgoing: Decimal {
        transactionsTo.reduce(0) { $0 + $1.sum }
    }
    
    var activeGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }
    
    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }
    
    var recentTransactions: [Any] {
        let allTransactions: [Any] = transactionsFrom.map { TransactionWrapper.from($0) } + 
                                    transactionsTo.map { TransactionWrapper.to($0) }
        return allTransactions.sorted { transaction1, transaction2 in
            // Sort by ID (assuming higher ID = more recent)
            let id1 = (transaction1 as? TransactionWrapper)?.id ?? 0
            let id2 = (transaction2 as? TransactionWrapper)?.id ?? 0
            return id1 > id2
        }
    }
}

// MARK: - Transaction Wrapper for unified display
struct TransactionWrapper {
    let id: Int
    let sum: Decimal
    let type: String
    let isIncoming: Bool
    
    static func from(_ transaction: TransactionFrom) -> TransactionWrapper {
        TransactionWrapper(
            id: transaction.id,
            sum: transaction.sum,
            type: transaction.type,
            isIncoming: true
        )
    }
    
    static func to(_ transaction: TransactionTo) -> TransactionWrapper {
        TransactionWrapper(
            id: transaction.id,
            sum: transaction.sum,
            type: transaction.type,
            isIncoming: false
        )
    }
}
