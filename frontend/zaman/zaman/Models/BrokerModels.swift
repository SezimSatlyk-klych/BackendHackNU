//
//  BrokerModels.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - Company Assessment Model
struct CompanyAssessment: Codable, Identifiable {
    let id: Int
    let companyName: String
    let contactPerson: String
    let email: String
    let phone: String
    let industry: String
    let country: String
    let website: String?
    let certificationScore: Int
    let productionScore: Int
    let ingredientsScore: Int
    let logisticsScore: Int
    let companyValuesScore: Int
    let overallScore: Int
    let status: AssessmentStatus
    let assessmentDate: String?
    let assessorName: String?
    let notes: String?
    let recommendations: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case contactPerson = "contact_person"
        case email, phone, industry, country, website
        case certificationScore = "certification_score"
        case productionScore = "production_score"
        case ingredientsScore = "ingredients_score"
        case logisticsScore = "logistics_score"
        case companyValuesScore = "company_values_score"
        case overallScore = "overall_score"
        case status
        case assessmentDate = "assessment_date"
        case assessorName = "assessor_name"
        case notes, recommendations
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum AssessmentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending: return "На рассмотрении"
        case .inProgress: return "В процессе"
        case .completed: return "Завершена"
        case .failed: return "Не пройдена"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .inProgress: return "blue"
        case .completed: return "green"
        case .failed: return "red"
        }
    }
}

// MARK: - Halal Certificate Model
struct HalalCertificate: Codable, Identifiable {
    let id: Int
    let certificateNumber: String
    let companyName: String
    let productName: String
    let certificationBody: Int
    let certificationBodyName: String?
    let issuedDate: String
    let expiryDate: String
    let status: CertificateStatus
    let certificateFile: String?
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case certificateNumber = "certificate_number"
        case companyName = "company_name"
        case productName = "product_name"
        case certificationBody = "certification_body"
        case certificationBodyName = "certification_body_name"
        case issuedDate = "issued_date"
        case expiryDate = "expiry_date"
        case status
        case certificateFile = "certificate_file"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum CertificateStatus: String, Codable, CaseIterable {
    case active = "active"
    case expired = "expired"
    case suspended = "suspended"
    case revoked = "revoked"
    
    var displayName: String {
        switch self {
        case .active: return "Действующий"
        case .expired: return "Истекший"
        case .suspended: return "Приостановленный"
        case .revoked: return "Отозванный"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "green"
        case .expired: return "orange"
        case .suspended: return "yellow"
        case .revoked: return "red"
        }
    }
}

// MARK: - Ingredient Model
struct Ingredient: Codable, Identifiable {
    let id: Int
    let name: String
    let scientificName: String?
    let category: Int
    let categoryName: String?
    let categoryType: String?
    let description: String?
    let commonSources: String?
    let halalConditions: String?
    let isActive: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case scientificName = "scientific_name"
        case category
        case categoryName = "category_name"
        case categoryType = "category_type"
        case description
        case commonSources = "common_sources"
        case halalConditions = "halal_conditions"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

// MARK: - Supplier Model
struct Supplier: Codable, Identifiable {
    let id: Int
    let name: String
    let contactPerson: String
    let email: String
    let phone: String
    let address: String
    let country: String
    let website: String?
    let halalCertificate: Int?
    let halalCertificateNumber: String?
    let status: SupplierStatus
    let halalComplianceScore: Int
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case contactPerson = "contact_person"
        case email, phone, address, country, website
        case halalCertificate = "halal_certificate"
        case halalCertificateNumber = "halal_certificate_number"
        case status
        case halalComplianceScore = "halal_compliance_score"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum SupplierStatus: String, Codable, CaseIterable {
    case approved = "approved"
    case pending = "pending"
    case rejected = "rejected"
    case suspended = "suspended"
    
    var displayName: String {
        switch self {
        case .approved: return "Одобрен"
        case .pending: return "На рассмотрении"
        case .rejected: return "Отклонен"
        case .suspended: return "Приостановлен"
        }
    }
    
    var color: String {
        switch self {
        case .approved: return "green"
        case .pending: return "orange"
        case .rejected: return "red"
        case .suspended: return "yellow"
        }
    }
}

// MARK: - Partnership Model
struct Partnership: Codable, Identifiable {
    let id: Int
    let companyAssessment: Int
    let companyName: String?
    let partnershipType: PartnershipType
    let status: PartnershipStatus
    let startDate: String?
    let endDate: String?
    let contractValue: Double?
    let termsAndConditions: String?
    let halalRequirements: String
    let monitoringFrequency: String
    let contactPerson: String
    let contactEmail: String
    let contactPhone: String
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyAssessment = "company_assessment"
        case companyName = "company_name"
        case partnershipType = "partnership_type"
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case contractValue = "contract_value"
        case termsAndConditions = "terms_and_conditions"
        case halalRequirements = "halal_requirements"
        case monitoringFrequency = "monitoring_frequency"
        case contactPerson = "contact_person"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum PartnershipType: String, Codable, CaseIterable {
    case supplier = "supplier"
    case distributor = "distributor"
    case manufacturer = "manufacturer"
    case serviceProvider = "service_provider"
    
    var displayName: String {
        switch self {
        case .supplier: return "Поставщик"
        case .distributor: return "Дистрибьютор"
        case .manufacturer: return "Производитель"
        case .serviceProvider: return "Поставщик услуг"
        }
    }
}

enum PartnershipStatus: String, Codable, CaseIterable {
    case proposed = "proposed"
    case negotiating = "negotiating"
    case active = "active"
    case suspended = "suspended"
    case terminated = "terminated"
    
    var displayName: String {
        switch self {
        case .proposed: return "Предложено"
        case .negotiating: return "Переговоры"
        case .active: return "Активное"
        case .suspended: return "Приостановлено"
        case .terminated: return "Завершено"
        }
    }
    
    var color: String {
        switch self {
        case .proposed: return "blue"
        case .negotiating: return "orange"
        case .active: return "green"
        case .suspended: return "yellow"
        case .terminated: return "red"
        }
    }
}

// MARK: - Analytics Models
struct PartnershipRecommendation: Identifiable {
    let id = UUID()
    let company: CompanyAssessment
    let recommendation: String
    let priority: PartnershipPriority
    let estimatedValue: Double
}

enum PartnershipPriority: Int, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    var displayName: String {
        switch self {
        case .none: return "Not Eligible"
        case .low: return "Low Priority"
        case .medium: return "Medium Priority"
        case .high: return "High Priority"
        }
    }
    
    var color: String {
        switch self {
        case .none: return "red"
        case .low: return "orange"
        case .medium: return "blue"
        case .high: return "green"
        }
    }
}

// MARK: - LLM Analysis Models
struct HalalAnalysisRequest: Codable {
    let ingredientName: String
}

struct HalalAnalysisResponse: Codable {
    let ingredient: String
    let halalStatus: String
    let analysis: String
    let confidence: Double
}

struct CompanyGradingRequest: Codable {
    let companyId: Int?
    let companyName: String?
    let useDb: Bool?
    let companyData: CompanyData?
}

struct CompanyData: Codable {
    let name: String?
    let industry: String?
    let country: String?
    let certificationInfo: String?
    let productionInfo: String?
    let ingredientsInfo: String?
    let logisticsInfo: String?
    let valuesInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case name, industry, country
        case certificationInfo = "certification_info"
        case productionInfo = "production_info"
        case ingredientsInfo = "ingredients_info"
        case logisticsInfo = "logistics_info"
        case valuesInfo = "values_info"
    }
}

struct CompanyGradingResponse: Codable {
    let companyName: String
    let halalValid: Bool
    let compliancePercent: Int
    let breakdown: [String: Int]
    let hasActiveCertificate: Bool
    let status: String
    let timestamp: String
    let source: String?
    let analysis: String?
    let modelUsed: String?
}

struct ResearchReportRequest: Codable {
    let topic: String
}

struct ResearchReportResponse: Codable {
    let topic: String
    let report: String
    let timestamp: String
    let wordCount: Int
}

struct BatchAnalysisRequest: Codable {
    let limit: Int?
    let statusFilter: String?
}

struct BatchAnalysisResponse: Codable {
    let analyzedCount: Int
    let results: [BatchAnalysisResult]
    let timestamp: String
}

struct BatchAnalysisResult: Codable {
    let companyId: Int
    let companyName: String
    let analysis: CompanyGradingResponse
}

struct CompanyPredictionResponse: Codable {
    let companyId: Int
    let companyName: String
    let compliancePercent: Int
    let passProbability: Double
    let projectedCompliancePercent: Int
    let projectedPassProbability: Double
    let hasActiveCertificate: Bool
    let breakdown: [String: Int]
    let weakestCriterion: WeakestCriterion
    let reasons: [String]
    let timestamp: String
}

struct WeakestCriterion: Codable {
    let name: String
    let score: Int
}
