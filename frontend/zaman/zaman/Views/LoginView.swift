//
//  LoginView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo and Title
                headerView
                
                // Login Form
                loginForm
                
                // Login Button
                loginButton
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .alert("Login Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(authViewModel.errorMessage ?? "An error occurred")
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    // Navigation will be handled by the main app
                }
            }
            .dismissKeyboardOnTap()
            .fixKeyboardConstraints()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // App Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("ZamanBank")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your Personal Financial Assistant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 50)
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 20) {
            // Email Field
            SafeTextField(
                "Email",
                text: $email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress
            )
            
            // Password Field
            SafeTextField(
                "Password",
                text: $password,
                placeholder: "Enter your password",
                isSecure: true
            )
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: performLogin) {
            HStack {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                
                Text(authViewModel.isLoading ? "Signing In..." : "Sign In")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Actions
    private func performLogin() {
        guard !email.isEmpty && !password.isEmpty else { return }
        
        Task {
            await authViewModel.login(email: email, password: password)
            
            if authViewModel.errorMessage != nil {
                showingAlert = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView(authViewModel: AuthViewModel())
}
