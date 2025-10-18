//
//  AccountView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Account View
struct AccountView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    @State private var isLoggingOut = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Account Header
            accountHeader
            
            // Main Content
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Account Information
                    accountInfoSection
                    
                    // App Settings
                    settingsSection
                    
                    // Logout Button
                    logoutSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to logout? This will clear all your session data and you'll need to login again.")
        }
    }
    
    // MARK: - Account Header
    private var accountHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Manage your profile and settings")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // User Avatar
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                    
                    Text(authViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.teal, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // User Info
            VStack(spacing: 8) {
                Text(authViewModel.currentUser?.fullName ?? "User Name")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(authViewModel.currentUser?.email ?? "user@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // User Type Badge
                HStack {
                    Image(systemName: authViewModel.currentUser?.isAdult == true ? "person.fill" : "person.fill.turn.down")
                        .font(.caption)
                    Text(authViewModel.currentUser?.type.capitalized ?? "User")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Edit Profile Button
            Button(action: {
                showingEditProfile = true
            }) {
                Text("Edit Profile")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.teal)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Account Information Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "person.fill",
                    title: "Full Name",
                    value: authViewModel.currentUser?.fullName ?? "Not available"
                )
                
                InfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: authViewModel.currentUser?.email ?? "Not available"
                )
                
                InfoRow(
                    icon: "person.badge.key.fill",
                    title: "Account Type",
                    value: authViewModel.currentUser?.type.capitalized ?? "Not available"
                )
                
                InfoRow(
                    icon: "calendar",
                    title: "Member Since",
                    value: "October 2025" // Placeholder - would come from backend
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "gear",
                    title: "App Settings",
                    action: { showingSettings = true }
                )
                
                Divider()
                
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    action: { /* Handle notifications */ }
                )
                
                Divider()
                
                SettingsRow(
                    icon: "lock",
                    title: "Privacy & Security",
                    action: { /* Handle privacy */ }
                )
                
                Divider()
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    action: { /* Handle help */ }
                )
                
                Divider()
                
                SettingsRow(
                    icon: "info.circle",
                    title: "About",
                    action: { /* Handle about */ }
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                if isLoggingOut {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                Text(isLoggingOut ? "Logging out..." : "Logout")
                    .fontWeight(.medium)
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
        .disabled(isLoggingOut)
    }
    
    // MARK: - Logout Function
    private func performLogout() {
        isLoggingOut = true
        
        // Simulate a brief delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            authViewModel.logout()
            isLoggingOut = false
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.teal)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.teal)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $name)
                    TextField("Last Name", text: $surname)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Account Type") {
                    Text(authViewModel.currentUser?.type.capitalized ?? "User")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentData()
            }
        }
    }
    
    private func loadCurrentData() {
        name = authViewModel.currentUser?.name ?? ""
        surname = authViewModel.currentUser?.surname ?? ""
        email = authViewModel.currentUser?.email ?? ""
    }
    
    private func saveProfile() {
        // In a real app, update the backend
        dismiss()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Security") {
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                }
                
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let authViewModel = AuthViewModel()
    
    // Mock data for preview
    authViewModel.currentUser = User(
        id: 1,
        name: "John",
        surname: "Doe",
        type: "adult",
        email: "john.doe@example.com"
    )
    
    return AccountView(authViewModel: authViewModel)
}
