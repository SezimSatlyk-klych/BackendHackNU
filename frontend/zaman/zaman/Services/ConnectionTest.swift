//
//  ConnectionTest.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - Connection Test Service
class ConnectionTest {
    static let shared = ConnectionTest()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - Test Backend Connection
    func testBackendConnection() async -> Bool {
        do {
            // Test if backend is reachable by trying to fetch data
            let _ = try await networkService.fetchFinance()
            return true
        } catch {
            print("Backend connection test failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Test Authentication
    func testAuthentication(email: String, password: String) async -> Bool {
        do {
            let _ = try await networkService.login(email: email, password: password)
            return true
        } catch {
            print("Authentication test failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Test All Endpoints
    func testAllEndpoints() async -> [String: Bool] {
        var results: [String: Bool] = [:]
        
        // Test Finance endpoint
        do {
            let _ = try await networkService.fetchFinance()
            results["Finance"] = true
        } catch {
            results["Finance"] = false
            print("Finance endpoint failed: \(error.localizedDescription)")
        }
        
        // Test Goals endpoint
        do {
            let _ = try await networkService.fetchGoals()
            results["Goals"] = true
        } catch {
            results["Goals"] = false
            print("Goals endpoint failed: \(error.localizedDescription)")
        }
        
        // Test Transactions endpoints
        do {
            let _ = try await networkService.fetchTransactionsFrom()
            results["TransactionsFrom"] = true
        } catch {
            results["TransactionsFrom"] = false
            print("TransactionsFrom endpoint failed: \(error.localizedDescription)")
        }
        
        do {
            let _ = try await networkService.fetchTransactionsTo()
            results["TransactionsTo"] = true
        } catch {
            results["TransactionsTo"] = false
            print("TransactionsTo endpoint failed: \(error.localizedDescription)")
        }
        
        // Test Savings endpoint
        do {
            let _ = try await networkService.fetchSavings()
            results["Savings"] = true
        } catch {
            results["Savings"] = false
            print("Savings endpoint failed: \(error.localizedDescription)")
        }
        
        return results
    }
}
