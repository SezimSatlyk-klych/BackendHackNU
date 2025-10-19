from django.contrib import admin
from .models import (
    CertificationBody, HalalCertificate, IngredientCategory, Ingredient,
    Supplier, ProductionProcess, CompanyAssessment, InterviewQuestion,
    InterviewResponse, ComplianceAudit, Partnership
)


@admin.register(CertificationBody)
class CertificationBodyAdmin(admin.ModelAdmin):
    list_display = ['name', 'country', 'accreditation_number', 'is_active', 'created_at']
    list_filter = ['country', 'is_active', 'created_at']
    search_fields = ['name', 'country', 'accreditation_number']
    ordering = ['name']


@admin.register(HalalCertificate)
class HalalCertificateAdmin(admin.ModelAdmin):
    list_display = ['certificate_number', 'company_name', 'product_name', 'certification_body', 'status', 'expiry_date']
    list_filter = ['status', 'certification_body', 'issued_date', 'expiry_date']
    search_fields = ['certificate_number', 'company_name', 'product_name']
    ordering = ['-issued_date']


@admin.register(IngredientCategory)
class IngredientCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'type', 'created_at']
    list_filter = ['type', 'created_at']
    search_fields = ['name', 'description']
    ordering = ['name']


@admin.register(Ingredient)
class IngredientAdmin(admin.ModelAdmin):
    list_display = ['name', 'scientific_name', 'category', 'is_active', 'created_at']
    list_filter = ['category', 'is_active', 'created_at']
    search_fields = ['name', 'scientific_name', 'description']
    ordering = ['name']


@admin.register(Supplier)
class SupplierAdmin(admin.ModelAdmin):
    list_display = ['name', 'contact_person', 'country', 'status', 'halal_compliance_score', 'created_at']
    list_filter = ['status', 'country', 'created_at']
    search_fields = ['name', 'contact_person', 'email']
    ordering = ['name']


@admin.register(ProductionProcess)
class ProductionProcessAdmin(admin.ModelAdmin):
    list_display = ['name', 'process_type', 'is_active', 'created_at']
    list_filter = ['process_type', 'is_active', 'created_at']
    search_fields = ['name', 'description']
    ordering = ['name']


@admin.register(CompanyAssessment)
class CompanyAssessmentAdmin(admin.ModelAdmin):
    list_display = ['company_name', 'industry', 'country', 'status', 'overall_score', 'assessment_date']
    list_filter = ['status', 'industry', 'country', 'assessment_date']
    search_fields = ['company_name', 'contact_person', 'email']
    ordering = ['-created_at']


@admin.register(InterviewQuestion)
class InterviewQuestionAdmin(admin.ModelAdmin):
    list_display = ['question_text', 'category', 'question_type', 'weight', 'is_active']
    list_filter = ['category', 'question_type', 'is_active']
    search_fields = ['question_text']
    ordering = ['category', 'weight']


@admin.register(InterviewResponse)
class InterviewResponseAdmin(admin.ModelAdmin):
    list_display = ['assessment', 'question', 'score', 'created_at']
    list_filter = ['question__category', 'created_at']
    search_fields = ['assessment__company_name', 'answer']
    ordering = ['-created_at']


@admin.register(ComplianceAudit)
class ComplianceAuditAdmin(admin.ModelAdmin):
    list_display = ['company_assessment', 'audit_type', 'status', 'scheduled_date', 'compliance_score']
    list_filter = ['audit_type', 'status', 'scheduled_date']
    search_fields = ['company_assessment__company_name', 'auditor_name']
    ordering = ['-scheduled_date']


@admin.register(Partnership)
class PartnershipAdmin(admin.ModelAdmin):
    list_display = ['company_assessment', 'partnership_type', 'status', 'start_date', 'contract_value']
    list_filter = ['partnership_type', 'status', 'start_date']
    search_fields = ['company_assessment__company_name', 'contact_person']
    ordering = ['-created_at']