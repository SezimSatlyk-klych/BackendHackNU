//
//  MainTabView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        TabView {
            HomeView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .environmentObject(homeViewModel)
            
            ChatView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
            
            VoiceView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Voice")
                }
            
            BrokeringView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Brokering")
                }
            
            AccountView(authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
        }
        .accentColor(.blue)
        .onAppear {
            authViewModel.checkAuthenticationStatus()
            Task {
                await homeViewModel.loadData()
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if !isAuthenticated {
                // Clear all data when user logs out
                homeViewModel.clearData()
            } else {
                // Load fresh data when user logs in
                Task {
                    await homeViewModel.loadData()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView(authViewModel: AuthViewModel())
}
