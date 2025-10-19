//
//  BrokeringAnalysis.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Analysis Result Cards

struct AnalysisResultCard: View {
    let result: HalalAnalysisResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "leaf")
                    .foregroundColor(.green)
                Text("Ingredient Analysis")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(result.halalStatus)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(halalStatusColor)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredient: \(result.ingredient)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(result.analysis)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("Confidence: \(Int(result.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ProgressView(value: result.confidence, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 100)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var halalStatusColor: Color {
        switch result.halalStatus.lowercased() {
        case "halal": return .green
        case "haram": return .red
        case "mashbooh": return .orange
        default: return .gray
        }
    }
}

struct CompanyGradingResultCard: View {
    let result: CompanyGradingResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                Text("Company Compliance")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(result.compliancePercent)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(complianceColor)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Company: \(result.companyName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Breakdown
                VStack(spacing: 8) {
                    ForEach(Array(result.breakdown.keys.sorted()), id: \.self) { key in
                        HStack {
                            Text(key.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(result.breakdown[key] ?? 0)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                if let analysis = result.analysis {
                    Text(analysis)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var complianceColor: Color {
        switch result.compliancePercent {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

struct ResearchReportCard: View {
    let report: ResearchReportResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.orange)
                Text("Research Report")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(report.wordCount) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Topic: \(report.topic)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(report.report)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(5)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct BatchAnalysisResultCard: View {
    let result: BatchAnalysisResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar")
                    .foregroundColor(.purple)
                Text("Batch Analysis Results")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(result.analyzedCount) companies")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(result.results, id: \.companyId) { companyResult in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(companyResult.companyName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("Compliance: \(companyResult.analysis.compliancePercent)%")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text(companyResult.analysis.halalValid ? "Halal Valid" : "Needs Review")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(companyResult.analysis.halalValid ? Color.green : Color.orange)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Modal Views

struct AddAssessmentView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var companyName = ""
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var industry = ""
    @State private var country = ""
    @State private var website = ""
    @State private var certificationScore = 0
    @State private var productionScore = 0
    @State private var ingredientsScore = 0
    @State private var logisticsScore = 0
    @State private var companyValuesScore = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Company Information") {
                    TextField("Company Name", text: $companyName)
                    TextField("Contact Person", text: $contactPerson)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Industry", text: $industry)
                    TextField("Country", text: $country)
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                }
                
                Section("Assessment Scores") {
                    VStack(alignment: .leading, spacing: 16) {
                        ScoreSlider(title: "Certification", score: $certificationScore)
                        ScoreSlider(title: "Production", score: $productionScore)
                        ScoreSlider(title: "Ingredients", score: $ingredientsScore)
                        ScoreSlider(title: "Logistics", score: $logisticsScore)
                        ScoreSlider(title: "Company Values", score: $companyValuesScore)
                    }
                }
            }
            .navigationTitle("New Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAssessment()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !companyName.isEmpty && !contactPerson.isEmpty && !email.isEmpty
    }
    
    private func saveAssessment() {
        let assessment = CompanyAssessment(
            id: 0, // Will be set by backend
            companyName: companyName,
            contactPerson: contactPerson,
            email: email,
            phone: phone,
            industry: industry,
            country: country,
            website: website.isEmpty ? nil : website,
            certificationScore: certificationScore,
            productionScore: productionScore,
            ingredientsScore: ingredientsScore,
            logisticsScore: logisticsScore,
            companyValuesScore: companyValuesScore,
            overallScore: 0, // Will be calculated
            status: .pending,
            assessmentDate: nil,
            assessorName: nil,
            notes: nil,
            recommendations: nil,
            createdAt: "",
            updatedAt: ""
        )
        
        Task {
            await brokeringViewModel.createCompanyAssessment(assessment)
            dismiss()
        }
    }
}

struct CompanySelectionView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(brokeringViewModel.companyAssessments) { assessment in
                    Button(action: {
                        Task {
                            await brokeringViewModel.gradeCompany(companyId: assessment.id)
                        }
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(assessment.companyName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(assessment.industry) • \(assessment.country)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Score: \(assessment.overallScore)%")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text(assessment.status.displayName)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(assessment.status.color))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Company")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CompanyGradingView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var companyName = ""
    @State private var industry = ""
    @State private var country = ""
    @State private var certificationInfo = ""
    @State private var productionInfo = ""
    @State private var ingredientsInfo = ""
    @State private var logisticsInfo = ""
    @State private var valuesInfo = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Company Information") {
                    TextField("Company Name", text: $companyName)
                    TextField("Industry", text: $industry)
                    TextField("Country", text: $country)
                }
                
                Section("Assessment Details") {
                    TextField("Certification Info", text: $certificationInfo, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Production Info", text: $productionInfo, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Ingredients Info", text: $ingredientsInfo, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Logistics Info", text: $logisticsInfo, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Values Info", text: $valuesInfo, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if let result = brokeringViewModel.companyGradingResult {
                    Section("Analysis Result") {
                        CompanyGradingResultCard(result: result)
                    }
                }
            }
            .navigationTitle("Company Grading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Grade") {
                        gradeCompany()
                    }
                    .disabled(companyName.isEmpty)
                }
            }
        }
    }
    
    private func gradeCompany() {
        let companyData = CompanyData(
            name: companyName,
            industry: industry,
            country: country,
            certificationInfo: certificationInfo,
            productionInfo: productionInfo,
            ingredientsInfo: ingredientsInfo,
            logisticsInfo: logisticsInfo,
            valuesInfo: valuesInfo
        )
        
        Task {
            await brokeringViewModel.gradeCompany(companyData: companyData)
        }
    }
}

struct ResearchReportView: View {
    @ObservedObject var brokeringViewModel: BrokeringViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var topic = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Research Topic")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter research topic", text: $topic, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                if let report = brokeringViewModel.researchReport {
                    ScrollView {
                        ResearchReportCard(report: report)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Research Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Generate") {
                        generateReport()
                    }
                    .disabled(topic.isEmpty)
                }
            }
        }
    }
    
    private func generateReport() {
        Task {
            await brokeringViewModel.generateResearchReport(topic: topic)
        }
    }
}

// MARK: - Supporting Views

struct ScoreSlider: View {
    let title: String
    @Binding var score: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(score)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            Slider(value: Binding(
                get: { Double(score) },
                set: { score = Int($0) }
            ), in: 0...100, step: 1)
            .accentColor(.blue)
        }
    }
}
