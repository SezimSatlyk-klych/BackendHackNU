//
//  BrokeringViewModel.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import Combine

// MARK: - Brokering ViewModel
@MainActor
class BrokeringViewModel: ObservableObject {
    @Published var companyAssessments: [CompanyAssessment] = []
    @Published var partnerships: [Partnership] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab = 0
    
    // LLM Analysis Results
    @Published var halalAnalysisResult: HalalAnalysisResponse?
    @Published var companyGradingResult: CompanyGradingResponse?
    @Published var researchReport: ResearchReportResponse?
    @Published var batchAnalysisResult: BatchAnalysisResponse?
    @Published var predictionResult: CompanyPredictionResponse?
    
    // Search and Filter
    @Published var searchText = ""
    @Published var selectedStatusFilter: AssessmentStatus?
    @Published var selectedPartnershipStatus: PartnershipStatus?
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchFiltering()
    }
    
    // MARK: - Data Loading
    func loadAllData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let assessments = networkService.fetchCompanyAssessments()
            async let partnershipsData = networkService.fetchPartnerships()
            
            let (assessmentsResult, partnershipsResult) = try await (
                assessments, partnershipsData
            )
            
            companyAssessments = assessmentsResult
            partnerships = partnershipsResult
            
            // If no data exists, create default assessments
            if companyAssessments.isEmpty {
                await createDefaultAssessments()
            }
            
            print("✅ BrokeringViewModel: Loaded all data successfully")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to load data - \(error)")
            
            // Create default data even if API fails
            await createDefaultAssessments()
        }
        
        isLoading = false
    }
    
    func refreshData() async {
        await loadAllData()
    }
    
    // MARK: - Default Data Creation
    private func createDefaultAssessments() async {
        let defaultAssessments = [
            CompanyAssessment(
                id: 1,
                companyName: "Halal Foods Ltd",
                contactPerson: "Ahmed Hassan",
                email: "ahmed@halalfoods.com",
                phone: "+1-555-0101",
                industry: "Food Production",
                country: "Malaysia",
                website: "https://halalfoods.com",
                certificationScore: 85,
                productionScore: 90,
                ingredientsScore: 88,
                logisticsScore: 82,
                companyValuesScore: 87,
                overallScore: 86,
                status: .completed,
                assessmentDate: "2024-01-15",
                assessorName: "Dr. Sarah Johnson",
                notes: "Excellent halal compliance practices",
                recommendations: "Continue current practices",
                createdAt: "2024-01-15T10:00:00Z",
                updatedAt: "2024-01-15T10:00:00Z"
            ),
            CompanyAssessment(
                id: 2,
                companyName: "Green Valley Organic",
                contactPerson: "Maria Rodriguez",
                email: "maria@greenvalley.com",
                phone: "+1-555-0102",
                industry: "Organic Farming",
                country: "Spain",
                website: "https://greenvalley.com",
                certificationScore: 92,
                productionScore: 95,
                ingredientsScore: 90,
                logisticsScore: 88,
                companyValuesScore: 93,
                overallScore: 92,
                status: .completed,
                assessmentDate: "2024-01-20",
                assessorName: "Dr. Michael Chen",
                notes: "Outstanding organic and halal practices",
                recommendations: "Consider expanding to new markets",
                createdAt: "2024-01-20T14:30:00Z",
                updatedAt: "2024-01-20T14:30:00Z"
            ),
            CompanyAssessment(
                id: 3,
                companyName: "Premium Meats Co",
                contactPerson: "John Smith",
                email: "john@premiummeats.com",
                phone: "+1-555-0103",
                industry: "Meat Processing",
                country: "Turkey",
                website: "https://premiummeats.com",
                certificationScore: 78,
                productionScore: 82,
                ingredientsScore: 85,
                logisticsScore: 80,
                companyValuesScore: 75,
                overallScore: 80,
                status: .inProgress,
                assessmentDate: "2024-01-25",
                assessorName: "Dr. Fatima Al-Zahra",
                notes: "Good progress, some areas need improvement",
                recommendations: "Improve logistics and company values alignment",
                createdAt: "2024-01-25T09:15:00Z",
                updatedAt: "2024-01-25T09:15:00Z"
            ),
            CompanyAssessment(
                id: 4,
                companyName: "Spice World International",
                contactPerson: "Raj Patel",
                email: "raj@spiceworld.com",
                phone: "+1-555-0104",
                industry: "Spice Trading",
                country: "India",
                website: "https://spiceworld.com",
                certificationScore: 88,
                productionScore: 85,
                ingredientsScore: 90,
                logisticsScore: 87,
                companyValuesScore: 89,
                overallScore: 88,
                status: .completed,
                assessmentDate: "2024-02-01",
                assessorName: "Dr. Sarah Johnson",
                notes: "Strong halal certification and practices",
                recommendations: "Maintain current standards",
                createdAt: "2024-02-01T11:45:00Z",
                updatedAt: "2024-02-01T11:45:00Z"
            ),
            CompanyAssessment(
                id: 5,
                companyName: "Fresh Dairy Products",
                contactPerson: "Emma Wilson",
                email: "emma@freshdairy.com",
                phone: "+1-555-0105",
                industry: "Dairy Production",
                country: "New Zealand",
                website: "https://freshdairy.com",
                certificationScore: 75,
                productionScore: 80,
                ingredientsScore: 85,
                logisticsScore: 78,
                companyValuesScore: 82,
                overallScore: 80,
                status: .pending,
                assessmentDate: nil,
                assessorName: nil,
                notes: "Assessment in progress",
                recommendations: nil,
                createdAt: "2024-02-05T08:00:00Z",
                updatedAt: "2024-02-05T08:00:00Z"
            )
        ]
        
        let defaultPartnerships = [
            Partnership(
                id: 1,
                companyAssessment: 1,
                companyName: "Halal Foods Ltd",
                partnershipType: .supplier,
                status: .active,
                startDate: "2024-01-01",
                endDate: "2024-12-31",
                contractValue: 250000.0,
                termsAndConditions: "Supply halal-certified food products",
                halalRequirements: "All products must be halal certified",
                monitoringFrequency: "Monthly",
                contactPerson: "Ahmed Hassan",
                contactEmail: "ahmed@halalfoods.com",
                contactPhone: "+1-555-0101",
                notes: "Primary halal food supplier",
                createdAt: "2024-01-01T00:00:00Z",
                updatedAt: "2024-01-01T00:00:00Z"
            ),
            Partnership(
                id: 2,
                companyAssessment: 2,
                companyName: "Green Valley Organic",
                partnershipType: .manufacturer,
                status: .active,
                startDate: "2024-01-15",
                endDate: "2025-01-15",
                contractValue: 500000.0,
                termsAndConditions: "Manufacture organic halal products",
                halalRequirements: "Organic certification + halal compliance",
                monitoringFrequency: "Quarterly",
                contactPerson: "Maria Rodriguez",
                contactEmail: "maria@greenvalley.com",
                contactPhone: "+1-555-0102",
                notes: "Premium organic halal manufacturer",
                createdAt: "2024-01-15T00:00:00Z",
                updatedAt: "2024-01-15T00:00:00Z"
            ),
            Partnership(
                id: 3,
                companyAssessment: 4,
                companyName: "Spice World International",
                partnershipType: .distributor,
                status: .active,
                startDate: "2024-02-01",
                endDate: "2024-12-31",
                contractValue: 150000.0,
                termsAndConditions: "Distribute halal spices globally",
                halalRequirements: "Halal certification for all spice products",
                monitoringFrequency: "Bi-monthly",
                contactPerson: "Raj Patel",
                contactEmail: "raj@spiceworld.com",
                contactPhone: "+1-555-0104",
                notes: "Global spice distribution partner",
                createdAt: "2024-02-01T00:00:00Z",
                updatedAt: "2024-02-01T00:00:00Z"
            )
        ]
        
        companyAssessments = defaultAssessments
        partnerships = defaultPartnerships
        
        print("✅ BrokeringViewModel: Created default assessments and partnerships")
        print("📊 Partnerships created: \(partnerships.count)")
        print("📊 Assessments created: \(companyAssessments.count)")
    }
    
    // MARK: - Company Assessment Operations
    func createCompanyAssessment(_ assessment: CompanyAssessment) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newAssessment = try await networkService.createCompanyAssessment(assessment)
            companyAssessments.append(newAssessment)
            print("✅ BrokeringViewModel: Created new company assessment")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to create assessment - \(error)")
        }
        
        isLoading = false
    }
    
    func calculateScore(for assessmentId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await networkService.calculateCompanyScore(assessmentId: assessmentId)
            print("✅ BrokeringViewModel: Calculated score - \(result)")
            
            // Update the assessment in the list
            if let index = companyAssessments.firstIndex(where: { $0.id == assessmentId }) {
                // Note: In a real app, you'd update the specific fields from the result
                companyAssessments[index] = companyAssessments[index] // Trigger UI update
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to calculate score - \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - LLM Analysis Operations
    func analyzeIngredient(_ ingredientName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            halalAnalysisResult = try await networkService.analyzeIngredientHalal(ingredientName)
            print("✅ BrokeringViewModel: Analyzed ingredient - \(ingredientName)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to analyze ingredient - \(error)")
        }
        
        isLoading = false
    }
    
    func gradeCompany(companyId: Int? = nil, companyName: String? = nil, useDb: Bool = true, companyData: CompanyData? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Try to use existing assessment data first
            if let companyId = companyId, let assessment = companyAssessments.first(where: { $0.id == companyId }) {
                // Use local assessment data for analysis
                let localGrading = createLocalGradingFromAssessment(assessment)
                companyGradingResult = localGrading
                print("✅ BrokeringViewModel: Used local assessment data for grading")
            } else {
                // Fallback to API
                companyGradingResult = try await networkService.gradeCompanyCompliance(
                    companyId: companyId,
                    companyName: companyName,
                    useDb: useDb,
                    companyData: companyData
                )
                print("✅ BrokeringViewModel: Graded company compliance via API")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to grade company - \(error)")
        }
        
        isLoading = false
    }
    
    private func createLocalGradingFromAssessment(_ assessment: CompanyAssessment) -> CompanyGradingResponse {
        let breakdown = [
            "certification": assessment.certificationScore,
            "production": assessment.productionScore,
            "ingredients": assessment.ingredientsScore,
            "logistics": assessment.logisticsScore,
            "company_values": assessment.companyValuesScore
        ]
        
        let hasActiveCertificate = assessment.certificationScore >= 80
        let halalValid = assessment.overallScore >= 70
        
        return CompanyGradingResponse(
            companyName: assessment.companyName,
            halalValid: halalValid,
            compliancePercent: assessment.overallScore,
            breakdown: breakdown,
            hasActiveCertificate: hasActiveCertificate,
            status: assessment.status.rawValue,
            timestamp: assessment.updatedAt,
            source: "local_assessment",
            analysis: assessment.notes ?? "Assessment completed with \(assessment.overallScore)% compliance score",
            modelUsed: "local_data"
        )
    }
    
    func generateResearchReport(topic: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            researchReport = try await networkService.generateResearchReport(topic: topic)
            print("✅ BrokeringViewModel: Generated research report")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to generate report - \(error)")
        }
        
        isLoading = false
    }
    
    func performBatchAnalysis(limit: Int = 10, statusFilter: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Use local assessment data for batch analysis
            let filteredAssessments = companyAssessments.prefix(limit)
            let results = filteredAssessments.map { assessment in
                let grading = createLocalGradingFromAssessment(assessment)
                return BatchAnalysisResult(
                    companyId: assessment.id,
                    companyName: assessment.companyName,
                    analysis: grading
                )
            }
            
            batchAnalysisResult = BatchAnalysisResponse(
                analyzedCount: results.count,
                results: results,
                timestamp: ISO8601DateFormatter().string(from: Date())
            )
            
            print("✅ BrokeringViewModel: Performed batch analysis using local data")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed batch analysis - \(error)")
        }
        
        isLoading = false
    }
    
    func predictAuditPass(companyId: Int? = nil, analyzeAll: Bool = false, limit: Int = 50) async {
        isLoading = true
        errorMessage = nil
        
        do {
            predictionResult = try await networkService.predictCompanyAuditPass(
                companyId: companyId,
                analyzeAll: analyzeAll,
                limit: limit
            )
            print("✅ BrokeringViewModel: Predicted audit pass probability")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ BrokeringViewModel: Failed to predict audit - \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filtered Data
    var filteredCompanyAssessments: [CompanyAssessment] {
        var filtered = companyAssessments
        
        if !searchText.isEmpty {
            filtered = filtered.filter { assessment in
                assessment.companyName.localizedCaseInsensitiveContains(searchText) ||
                assessment.industry.localizedCaseInsensitiveContains(searchText) ||
                assessment.country.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let statusFilter = selectedStatusFilter {
            filtered = filtered.filter { $0.status == statusFilter }
        }
        
        return filtered
    }
    
    var filteredPartnerships: [Partnership] {
        var filtered = partnerships
        
        if !searchText.isEmpty {
            filtered = filtered.filter { partnership in
                partnership.companyName?.localizedCaseInsensitiveContains(searchText) == true ||
                partnership.contactPerson.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let statusFilter = selectedPartnershipStatus {
            filtered = filtered.filter { $0.status == statusFilter }
        }
        
        return filtered
    }
    
    
    // MARK: - Statistics
    var totalAssessments: Int {
        companyAssessments.count
    }
    
    var completedAssessments: Int {
        companyAssessments.filter { $0.status == .completed }.count
    }
    
    var averageScore: Double {
        guard !companyAssessments.isEmpty else { return 0 }
        let totalScore = companyAssessments.reduce(0) { $0 + $1.overallScore }
        return Double(totalScore) / Double(companyAssessments.count)
    }
    
    var activePartnerships: Int {
        partnerships.filter { $0.status == .active }.count
    }
    
    var totalContractValue: Double {
        partnerships.compactMap { $0.contractValue }.reduce(0, +)
    }
    
    // MARK: - Comprehensive Analytics
    var partnershipEligibleCompanies: [CompanyAssessment] {
        companyAssessments.filter { assessment in
            assessment.status == .completed && 
            assessment.overallScore >= 70 &&
            assessment.certificationScore >= 60 &&
            assessment.productionScore >= 60 &&
            assessment.ingredientsScore >= 60
        }
    }
    
    var highPerformingCompanies: [CompanyAssessment] {
        companyAssessments.filter { $0.overallScore >= 85 }
    }
    
    var needsImprovementCompanies: [CompanyAssessment] {
        companyAssessments.filter { $0.overallScore < 70 }
    }
    
    var scoreDistribution: [String: Int] {
        var distribution: [String: Int] = [:]
        
        for assessment in companyAssessments {
            let range: String
            switch assessment.overallScore {
            case 90...100: range = "90-100"
            case 80...89: range = "80-89"
            case 70...79: range = "70-79"
            case 60...69: range = "60-69"
            default: range = "Below 60"
            }
            distribution[range, default: 0] += 1
        }
        
        return distribution
    }
    
    var industryBreakdown: [String: Int] {
        var breakdown: [String: Int] = [:]
        for assessment in companyAssessments {
            breakdown[assessment.industry, default: 0] += 1
        }
        return breakdown
    }
    
    var averageScoreByIndustry: [String: Double] {
        var scores: [String: [Int]] = [:]
        
        for assessment in companyAssessments {
            scores[assessment.industry, default: []].append(assessment.overallScore)
        }
        
        return scores.mapValues { scores in
            Double(scores.reduce(0, +)) / Double(scores.count)
        }
    }
    
    var partnershipRecommendations: [PartnershipRecommendation] {
        var recommendations: [PartnershipRecommendation] = []
        
        for assessment in companyAssessments {
            if assessment.status == .completed && !partnerships.contains(where: { $0.companyAssessment == assessment.id }) {
                let eligibility = determinePartnershipEligibility(assessment)
                if eligibility.isEligible {
                    recommendations.append(PartnershipRecommendation(
                        company: assessment,
                        recommendation: eligibility.recommendation,
                        priority: eligibility.priority,
                        estimatedValue: calculateEstimatedPartnershipValue(assessment)
                    ))
                }
            }
        }
        
        return recommendations.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }
    
    private func determinePartnershipEligibility(_ assessment: CompanyAssessment) -> (isEligible: Bool, recommendation: String, priority: PartnershipPriority) {
        let scores = [
            ("Certification", assessment.certificationScore),
            ("Production", assessment.productionScore),
            ("Ingredients", assessment.ingredientsScore),
            ("Logistics", assessment.logisticsScore),
            ("Values", assessment.companyValuesScore)
        ]
        
        let criticalScores = [assessment.certificationScore, assessment.productionScore, assessment.ingredientsScore]
        let allCriticalPass = criticalScores.allSatisfy { $0 >= 60 }
        let overallPass = assessment.overallScore >= 70
        
        if overallPass && allCriticalPass {
            if assessment.overallScore >= 90 {
                return (true, "Excellent candidate for premium partnership", .high)
            } else if assessment.overallScore >= 80 {
                return (true, "Strong candidate for standard partnership", .medium)
            } else {
                return (true, "Suitable for basic partnership with monitoring", .low)
            }
        } else {
            let weakAreas = scores.filter { $0.1 < 60 }.map { $0.0 }
            return (false, "Improve \(weakAreas.joined(separator: ", ")) before partnership", .none)
        }
    }
    
    private func calculateEstimatedPartnershipValue(_ assessment: CompanyAssessment) -> Double {
        // Base value calculation based on score and industry
        let baseValue = Double(assessment.overallScore) * 1000
        
        // Industry multipliers
        let industryMultiplier: Double
        switch assessment.industry.lowercased() {
        case let industry where industry.contains("food") || industry.contains("meat"):
            industryMultiplier = 1.5
        case let industry where industry.contains("organic"):
            industryMultiplier = 1.3
        case let industry where industry.contains("dairy"):
            industryMultiplier = 1.2
        default:
            industryMultiplier = 1.0
        }
        
        return baseValue * industryMultiplier
    }
    
    // MARK: - Helper Methods
    private func setupSearchFiltering() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                // Trigger UI update when search text changes
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearAnalysisResults() {
        halalAnalysisResult = nil
        companyGradingResult = nil
        researchReport = nil
        batchAnalysisResult = nil
        predictionResult = nil
    }
}
