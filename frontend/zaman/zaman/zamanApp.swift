//
//  zamanApp.swift
//  zaman
//
//  Created by Aiaulym Abduohapova on 18.10.2025.
//

import SwiftUI

@main
struct zamanApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView(authViewModel: authViewModel)
                        .onAppear {
                            print("🏠 Home view displayed - authentication successful")
                        }
                } else {
                    LoginView(authViewModel: authViewModel)
                        .onAppear {
                            print("🔐 Login view displayed - user not authenticated")
                        }
                }
            }
            .onAppear {
                authViewModel.checkAuthenticationStatus()
                print("🚀 App started - isAuthenticated: \(authViewModel.isAuthenticated)")
                // Configure for development
                UIApplication.shared.configureForDevelopment()
                NetworkConfig.configureForDevelopment()
                DebugHelper.suppressConsoleWarnings()
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                print("🔄 Authentication state changed: \(isAuthenticated)")
            }
            .fixKeyboardConstraints()
        }
    }
}
