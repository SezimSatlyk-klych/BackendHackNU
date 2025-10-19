//
//  BrokeringAnalytics.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Analytics Overview
struct AnalyticsOverviewView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Key Metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Assessments",
                    value: "\(brokeringViewModel.totalAssessments)",
                    subtitle: "Companies evaluated",
                    color: .blue
                )
                
                MetricCard(
                    title: "Partnership Eligible",
                    value: "\(brokeringViewModel.partnershipEligibleCompanies.count)",
                    subtitle: "Ready for partnership",
                    color: .green
                )
                
                MetricCard(
                    title: "High Performers",
                    value: "\(brokeringViewModel.highPerformingCompanies.count)",
                    subtitle: "Score ≥ 85%",
                    color: .purple
                )
                
                MetricCard(
                    title: "Needs Improvement",
                    value: "\(brokeringViewModel.needsImprovementCompanies.count)",
                    subtitle: "Score < 70%",
                    color: .orange
                )
            }
            
            // Score Distribution Chart
            ScoreDistributionView(brokeringViewModel: brokeringViewModel)
            
            // Industry Breakdown
            IndustryBreakdownView(brokeringViewModel: brokeringViewModel)
            
            // Partnership Recommendations
            PartnershipRecommendationsView(brokeringViewModel: brokeringViewModel)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Score Distribution
struct ScoreDistributionView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Distribution")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(["90-100", "80-89", "70-79", "60-69", "Below 60"], id: \.self) { range in
                    ScoreDistributionBar(
                        range: range,
                        count: brokeringViewModel.scoreDistribution[range] ?? 0,
                        total: brokeringViewModel.totalAssessments,
                        color: colorForRange(range)
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func colorForRange(_ range: String) -> Color {
        switch range {
        case "90-100": return .green
        case "80-89": return .blue
        case "70-79": return .orange
        case "60-69": return .yellow
        default: return .red
        }
    }
}

struct ScoreDistributionBar: View {
    let range: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Text(range)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Industry Breakdown
struct IndustryBreakdownView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Industry Analysis")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(Array(brokeringViewModel.industryBreakdown.keys.sorted()), id: \.self) { industry in
                    IndustryRow(
                        industry: industry,
                        count: brokeringViewModel.industryBreakdown[industry] ?? 0,
                        averageScore: brokeringViewModel.averageScoreByIndustry[industry] ?? 0
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct IndustryRow: View {
    let industry: String
    let count: Int
    let averageScore: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(industry)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text("\(count) companies")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f", averageScore))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(scoreColor(averageScore))
                
                Text("avg score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 85...100: return .green
        case 70...84: return .blue
        case 60...69: return .orange
        default: return .red
        }
    }
}

// MARK: - Partnership Recommendations
struct PartnershipRecommendationsView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Partnership Recommendations")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(brokeringViewModel.partnershipRecommendations.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            if brokeringViewModel.partnershipRecommendations.isEmpty {
                Text("No new partnership recommendations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(brokeringViewModel.partnershipRecommendations.prefix(3)) { recommendation in
                        PartnershipRecommendationCard(recommendation: recommendation)
                    }
                    
                    if brokeringViewModel.partnershipRecommendations.count > 3 {
                        Text("+ \(brokeringViewModel.partnershipRecommendations.count - 3) more recommendations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct PartnershipRecommendationCard: View {
    let recommendation: PartnershipRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.company.companyName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(recommendation.company.industry)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.0f%%", Double(recommendation.company.overallScore)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor(recommendation.company.overallScore))
                    
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(recommendation.recommendation)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                PriorityBadge(priority: recommendation.priority)
                
                Spacer()
                
                Text("Est. Value: $\(Int(recommendation.estimatedValue), specifier: "%.0f")")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 85...100: return .green
        case 70...84: return .blue
        case 60...69: return .orange
        default: return .red
        }
    }
}

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: PartnershipPriority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priorityColor(priority))
            .cornerRadius(4)
    }
    
    private func priorityColor(_ priority: PartnershipPriority) -> Color {
        switch priority {
        case .high: return .green
        case .medium: return .blue
        case .low: return .orange
        case .none: return .red
        }
    }
}

// MARK: - Quick Actions
struct QuickActionsView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    @State private var showingCompanySelection = false
    @State private var showingCompanyGrading = false
    @State private var showingResearchReport = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    icon: "building.2",
                    title: "Company Grading",
                    subtitle: "Analyze company",
                    color: .blue
                ) {
                    showingCompanySelection = true
                }
                
                ActionButton(
                    icon: "doc.text",
                    title: "Research Report",
                    subtitle: "Generate report",
                    color: .orange
                ) {
                    showingResearchReport = true
                }
                
                ActionButton(
                    icon: "chart.bar",
                    title: "Batch Analysis",
                    subtitle: "Multiple companies",
                    color: .purple
                ) {
                    Task {
                        await brokeringViewModel.performBatchAnalysis()
                    }
                }
                
                ActionButton(
                    icon: "handshake",
                    title: "Create Partnership",
                    subtitle: "From assessment",
                    color: .green
                ) {
                    // TODO: Implement partnership creation
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyticsOverviewView(brokeringViewModel: BrokeringViewModel())
}
