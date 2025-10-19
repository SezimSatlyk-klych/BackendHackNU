//
//  BrokeringView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Brokering View
struct BrokeringView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var brokeringViewModel = BrokeringViewModel()
    @State private var showingAddAssessment = false
    @State private var showingCompanySelection = false
    @State private var showingCompanyGrading = false
    @State private var showingResearchReport = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with gradient background
                headerView
                
                // Tab Navigation
                tabNavigationView
                
                // Content based on selected tab
                Group {
                    switch brokeringViewModel.selectedTab {
                    case 0:
                        assessmentsView
                    case 1:
                        partnershipsView
                    case 2:
                        analysisView
                    default:
                        assessmentsView
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await brokeringViewModel.refreshData()
            }
            .onAppear {
                Task {
                    await brokeringViewModel.loadAllData()
                }
            }
            .sheet(isPresented: $showingAddAssessment) {
                AddAssessmentView(brokeringViewModel: brokeringViewModel)
            }
            .sheet(isPresented: $showingCompanySelection) {
                CompanySelectionView(brokeringViewModel: brokeringViewModel)
            }
            .sheet(isPresented: $showingCompanyGrading) {
                CompanyGradingView(brokeringViewModel: brokeringViewModel)
            }
            .sheet(isPresented: $showingResearchReport) {
                ResearchReportView(brokeringViewModel: brokeringViewModel)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Halal Compliance")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Statistics
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Assessments",
                    value: "\(brokeringViewModel.totalAssessments)",
                    subtitle: "\(brokeringViewModel.completedAssessments) completed"
                )
                
                StatisticCard(
                    title: "Avg Score",
                    value: String(format: "%.1f", brokeringViewModel.averageScore),
                    subtitle: "Overall compliance"
                )
                
                StatisticCard(
                    title: "Partnerships",
                    value: "\(brokeringViewModel.activePartnerships)",
                    subtitle: "\(brokeringViewModel.partnershipEligibleCompanies.count) eligible"
                )
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                TabButton(title: "Assessments", isSelected: brokeringViewModel.selectedTab == 0) {
                    brokeringViewModel.selectedTab = 0
                }
                
                TabButton(title: "Partnerships", isSelected: brokeringViewModel.selectedTab == 1) {
                    brokeringViewModel.selectedTab = 1
                }
                
                TabButton(title: "Analysis", isSelected: brokeringViewModel.selectedTab == 2) {
                    brokeringViewModel.selectedTab = 2
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Assessments View
    private var assessmentsView: some View {
        VStack(spacing: 16) {
            // Search and Filter
            HStack {
                SearchBar(text: $brokeringViewModel.searchText)
                
                Menu {
                    Button("All Status") {
                        brokeringViewModel.selectedStatusFilter = nil
                    }
                    ForEach(AssessmentStatus.allCases, id: \.self) { status in
                        Button(status.displayName) {
                            brokeringViewModel.selectedStatusFilter = status
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            // Add Assessment Button
            Button(action: {
                showingAddAssessment = true
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.white)
                    Text("Add New Assessment")
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
            
            // Assessments List
            if brokeringViewModel.isLoading {
                ProgressView("Loading assessments...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if brokeringViewModel.filteredCompanyAssessments.isEmpty {
                EmptyStateView(
                    icon: "building.2",
                    title: "No Assessments",
                    subtitle: "Start by adding a new company assessment"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(brokeringViewModel.filteredCompanyAssessments) { assessment in
                            AssessmentCard(assessment: assessment, brokeringViewModel: brokeringViewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
    }
    
    // MARK: - Partnerships View
    private var partnershipsView: some View {
        VStack(spacing: 16) {
            // Search and Filter
            HStack {
                SearchBar(text: $brokeringViewModel.searchText)
                
                Menu {
                    Button("All Status") {
                        brokeringViewModel.selectedPartnershipStatus = nil
                    }
                    ForEach(PartnershipStatus.allCases, id: \.self) { status in
                        Button(status.displayName) {
                            brokeringViewModel.selectedPartnershipStatus = status
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            
            // Partnerships List
            if brokeringViewModel.isLoading {
                ProgressView("Loading partnerships...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if brokeringViewModel.filteredPartnerships.isEmpty {
                EmptyStateView(
                    icon: "handshake",
                    title: "No Partnerships",
                    subtitle: "No partnership agreements found"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(brokeringViewModel.filteredPartnerships) { partnership in
                            PartnershipCard(partnership: partnership)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
    }
    
    
    
    
    // MARK: - Analysis View
    private var analysisView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Comprehensive Analytics Overview
                AnalyticsOverviewView(brokeringViewModel: brokeringViewModel)
                
                // Quick Actions
                QuickActionsView(brokeringViewModel: brokeringViewModel)
                    .padding(.horizontal, 20)
                
                // Analysis Results
                if let gradingResult = brokeringViewModel.companyGradingResult {
                    CompanyGradingResultCard(result: gradingResult)
                        .padding(.horizontal, 20)
                }
                
                if let report = brokeringViewModel.researchReport {
                    ResearchReportCard(report: report)
                        .padding(.horizontal, 20)
                }
                
                if let batchResult = brokeringViewModel.batchAnalysisResult {
                    BatchAnalysisResultCard(result: batchResult)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Supporting Views




// Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}




struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    BrokeringView(authViewModel: AuthViewModel())
}
