//
//  HomeView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient background
            headerView
            
            // Tab Navigation
            tabNavigationView
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0:
                    transactionHistoryView
                case 1:
                    goalsView
                case 2:
                    AnalysisView()
                        .environmentObject(homeViewModel)
                        .environmentObject(authViewModel)
                default:
                    transactionHistoryView
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await homeViewModel.loadData()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting
            Text("Hello, \(authViewModel.currentUser?.name ?? "User")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Current Balance
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Balance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("$\(Double(truncating: NSDecimalNumber(decimal: homeViewModel.currentBalance)), specifier: "%.2f")")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.8), Color(red: 0.3, green: 0.8, blue: 0.6)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(
            .rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        )
    }
    
    // MARK: - Tab Navigation
    private var tabNavigationView: some View {
        HStack(spacing: 0) {
            TabButton(title: "History", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabButton(title: "Goals", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabButton(title: "Analysis", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    
    // MARK: - Transaction History View
    private var transactionHistoryView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(homeViewModel.recentTransactions.prefix(10).enumerated()), id: \.offset) { index, transaction in
                    if let wrapper = transaction as? TransactionWrapper {
                        ModernTransactionRow(transaction: wrapper)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Goals View
    private var goalsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add New Goal Button
                Button(action: {
                    // TODO: Implement add goal functionality
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                        Text("Add New Goal")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.8), Color(red: 0.3, green: 0.8, blue: 0.6)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                
                // Goals List
                LazyVStack(spacing: 16) {
                    ForEach(homeViewModel.activeGoals) { goal in
                        ModernGoalCard(goal: goal)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
    }
    
}

// MARK: - Supporting Views

// Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.8), Color(red: 0.3, green: 0.8, blue: 0.6)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(20)
        }
    }
}

// Modern Transaction Row
struct ModernTransactionRow: View {
    let transaction: TransactionWrapper
    
    var body: some View {
        HStack(spacing: 16) {
            // Transaction Icon
            Circle()
                .fill(transaction.isIncoming ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: transaction.isIncoming ? "arrow.down" : "arrow.up.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(transaction.isIncoming ? .blue : .red)
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(transaction.isIncoming ? "Income" : "Expense")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text("\(transaction.isIncoming ? "+" : "-")$\(Double(truncating: NSDecimalNumber(decimal: transaction.sum)), specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.isIncoming ? .green : .red)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Modern Goal Card
struct ModernGoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Goal Icon
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "house")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.goalDesc)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(goal.progressPercentage, specifier: "%.0f")%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            // Progress Bar
            ProgressView(value: goal.progressPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            // Goal Details
            HStack {
                Text("$\(Double(truncating: NSDecimalNumber(decimal: goal.goalSum * goal.goalProgress / 100)), specifier: "%.0f") of $\(Double(truncating: NSDecimalNumber(decimal: goal.goalSum)), specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}




