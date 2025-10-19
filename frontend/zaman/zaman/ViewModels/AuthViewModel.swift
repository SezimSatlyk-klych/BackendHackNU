//
//  AuthViewModel.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Authentication ViewModel
@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Always perform fresh login - no token validation
            let loginResponse = try await networkService.login(email: email, password: password)
            
            // Convert LoginResponse to User
            let user = User(
                id: loginResponse.id,
                name: loginResponse.name,
                surname: loginResponse.surname,
                type: loginResponse.type,
                email: loginResponse.email
            )
            
            // Update authentication state (already on main thread due to @MainActor)
            self.currentUser = user
            self.isAuthenticated = true
            print("✅ Authentication successful - navigating to Home view")
            print("🔍 AuthViewModel state: isAuthenticated = \(self.isAuthenticated), currentUser = \(self.currentUser?.name ?? "nil")")
            
            // Force UI update
            self.objectWillChange.send()
            print("🔄 AuthViewModel: Sent objectWillChange notification")
            
            // Store user data securely (in a real app, use Keychain)
            UserDefaults.standard.set(user.id, forKey: "currentUserId")
            UserDefaults.standard.set(user.email, forKey: "currentUserEmail")
            UserDefaults.standard.set(user.name, forKey: "userName")
            UserDefaults.standard.set(user.surname, forKey: "userSurname")
            UserDefaults.standard.set(user.type, forKey: "userType")
            
            // Clear any previous cached data to force fresh fetch
            UserDefaults.standard.removeObject(forKey: "lastDataFetch")
            UserDefaults.standard.removeObject(forKey: "cachedFinanceData")
            UserDefaults.standard.removeObject(forKey: "cachedGoalsData")
            UserDefaults.standard.removeObject(forKey: "cachedTransactionsData")
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        // Clear network service auth token
        networkService.logout()
        
        // Clear all authentication state on main thread
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = nil
            self.isLoading = false
            
            // Clear all stored user data
            UserDefaults.standard.removeObject(forKey: "currentUserId")
            UserDefaults.standard.removeObject(forKey: "currentUserEmail")
            UserDefaults.standard.removeObject(forKey: "userName")
            UserDefaults.standard.removeObject(forKey: "userSurname")
            UserDefaults.standard.removeObject(forKey: "userType")
            
            // Clear any cached data
            UserDefaults.standard.removeObject(forKey: "lastDataFetch")
            UserDefaults.standard.removeObject(forKey: "cachedFinanceData")
            UserDefaults.standard.removeObject(forKey: "cachedGoalsData")
            UserDefaults.standard.removeObject(forKey: "cachedTransactionsData")
            
            // Force UI update
            self.objectWillChange.send()
        }
    }
    
    func checkAuthenticationStatus() {
        if let userId = UserDefaults.standard.object(forKey: "currentUserId") as? Int,
           let userEmail = UserDefaults.standard.string(forKey: "currentUserEmail"),
           let userName = UserDefaults.standard.string(forKey: "userName"),
           let userSurname = UserDefaults.standard.string(forKey: "userSurname"),
           let userType = UserDefaults.standard.string(forKey: "userType") {
            
            // Reconstruct user from stored data
            let user = User(
                id: userId,
                name: userName,
                surname: userSurname,
                type: userType,
                email: userEmail
            )
            
            currentUser = user
            isAuthenticated = true
            print("🔄 Restored authentication from stored data")
        }
    }
}
