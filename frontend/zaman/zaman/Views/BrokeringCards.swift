//
//  BrokeringCards.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Assessment Card
struct AssessmentCard: View {
    let assessment: CompanyAssessment
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assessment.companyName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(assessment.industry) • \(assessment.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: assessment.status)
            }
            
            // Scores
            VStack(spacing: 12) {
                HStack {
                    ScoreItem(title: "Certification", score: assessment.certificationScore)
                    ScoreItem(title: "Production", score: assessment.productionScore)
                    ScoreItem(title: "Ingredients", score: assessment.ingredientsScore)
                }
                
                HStack {
                    ScoreItem(title: "Logistics", score: assessment.logisticsScore)
                    ScoreItem(title: "Values", score: assessment.companyValuesScore)
                    ScoreItem(title: "Overall", score: assessment.overallScore, isOverall: true)
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    Task {
                        await brokeringViewModel.calculateScore(for: assessment.id)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Recalculate")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text("Updated: \(formatDate(assessment.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        }
        return "Unknown"
    }
}

// MARK: - Partnership Card
struct PartnershipCard: View {
    let partnership: Partnership
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(partnership.companyName ?? "Unknown Company")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(partnership.partnershipType.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: partnership.status, isPartnership: true)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.secondary)
                    Text(partnership.contactPerson)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                    Text(partnership.contactEmail)
                        .font(.subheadline)
                }
                
                if let contractValue = partnership.contractValue {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.secondary)
                        Text("$\(contractValue, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            
            // Dates
            HStack {
                if let startDate = partnership.startDate {
                    VStack(alignment: .leading) {
                        Text("Start Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDate(startDate))
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                if let endDate = partnership.endDate {
                    VStack(alignment: .trailing) {
                        Text("End Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatDate(endDate))
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        }
        return "Unknown"
    }
}

// MARK: - Supplier Card
struct SupplierCard: View {
    let supplier: Supplier
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(supplier.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(supplier.country) • \(supplier.contactPerson)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: supplier.status, isSupplier: true)
            }
            
            // Compliance Score
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Halal Compliance Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(supplier.halalComplianceScore)/100")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(scoreColor(supplier.halalComplianceScore))
                }
                
                ProgressView(value: Double(supplier.halalComplianceScore), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: scoreColor(supplier.halalComplianceScore)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                    Text(supplier.email)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.secondary)
                    Text(supplier.phone)
                        .font(.subheadline)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

// MARK: - Certificate Card
struct CertificateCard: View {
    let certificate: HalalCertificate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(certificate.companyName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(certificate.productName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: certificate.status, isCertificate: true)
            }
            
            // Certificate Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Certificate #")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(certificate.certificateNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if let bodyName = certificate.certificationBodyName {
                    HStack {
                        Text("Certified by")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(bodyName)
                            .font(.subheadline)
                    }
                }
            }
            
            // Dates
            HStack {
                VStack(alignment: .leading) {
                    Text("Issued")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(certificate.issuedDate))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Expires")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(certificate.expiryDate))
                        .font(.subheadline)
                        .foregroundColor(isExpired ? .red : .primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var isExpired: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let expiryDate = formatter.date(from: certificate.expiryDate) {
            return expiryDate < Date()
        }
        return false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        }
        return "Unknown"
    }
}

// MARK: - Ingredient Card
struct IngredientCard: View {
    let ingredient: Ingredient
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let scientificName = ingredient.scientificName {
                        Text(scientificName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await brokeringViewModel.analyzeIngredient(ingredient.name)
                    }
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Analyze")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Category
            if let categoryName = ingredient.categoryName {
                HStack {
                    Text("Category:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(categoryName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // Description
            if let description = ingredient.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Halal Conditions
            if let halalConditions = ingredient.halalConditions, !halalConditions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Halal Conditions:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text(halalConditions)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Analysis Tool Card
struct AnalysisToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Components

// Score Item
struct ScoreItem: View {
    let title: String
    let score: Int
    let isOverall: Bool
    
    init(title: String, score: Int, isOverall: Bool = false) {
        self.title = title
        self.score = score
        self.isOverall = isOverall
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(isOverall ? .headline : .subheadline)
                .fontWeight(isOverall ? .bold : .medium)
                .foregroundColor(scoreColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

// Status Badge
struct StatusBadge: View {
    let status: Any
    let isPartnership: Bool
    let isSupplier: Bool
    let isCertificate: Bool
    
    init(status: AssessmentStatus) {
        self.status = status
        self.isPartnership = false
        self.isSupplier = false
        self.isCertificate = false
    }
    
    init(status: PartnershipStatus, isPartnership: Bool) {
        self.status = status
        self.isPartnership = isPartnership
        self.isSupplier = false
        self.isCertificate = false
    }
    
    init(status: SupplierStatus, isSupplier: Bool) {
        self.status = status
        self.isPartnership = false
        self.isSupplier = isSupplier
        self.isCertificate = false
    }
    
    init(status: CertificateStatus, isCertificate: Bool) {
        self.status = status
        self.isPartnership = false
        self.isSupplier = false
        self.isCertificate = isCertificate
    }
    
    var body: some View {
        Text(displayName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(8)
    }
    
    private var displayName: String {
        if let assessmentStatus = status as? AssessmentStatus {
            return assessmentStatus.displayName
        } else if let partnershipStatus = status as? PartnershipStatus {
            return partnershipStatus.displayName
        } else if let supplierStatus = status as? SupplierStatus {
            return supplierStatus.displayName
        } else if let certificateStatus = status as? CertificateStatus {
            return certificateStatus.displayName
        }
        return "Unknown"
    }
    
    private var backgroundColor: Color {
        if let assessmentStatus = status as? AssessmentStatus {
            return Color(assessmentStatus.color)
        } else if let partnershipStatus = status as? PartnershipStatus {
            return Color(partnershipStatus.color)
        } else if let supplierStatus = status as? SupplierStatus {
            return Color(supplierStatus.color)
        } else if let certificateStatus = status as? CertificateStatus {
            return Color(certificateStatus.color)
        }
        return .gray
    }
}
