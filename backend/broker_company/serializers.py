from rest_framework import serializers
from .models import (
    CertificationBody, HalalCertificate, IngredientCategory, Ingredient,
    Supplier, ProductionProcess, CompanyAssessment, InterviewQuestion,
    InterviewResponse, ComplianceAudit, Partnership
)


class CertificationBodySerializer(serializers.ModelSerializer):
    """Сериализатор для органов сертификации"""
    
    class Meta:
        model = CertificationBody
        fields = '__all__'


class HalalCertificateSerializer(serializers.ModelSerializer):
    """Сериализатор для сертификатов халяльности"""
    certification_body_name = serializers.CharField(source='certification_body.name', read_only=True)
    
    class Meta:
        model = HalalCertificate
        fields = '__all__'


class IngredientCategorySerializer(serializers.ModelSerializer):
    """Сериализатор для категорий ингредиентов"""
    
    class Meta:
        model = IngredientCategory
        fields = '__all__'


class IngredientSerializer(serializers.ModelSerializer):
    """Сериализатор для ингредиентов"""
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_type = serializers.CharField(source='category.type', read_only=True)
    
    class Meta:
        model = Ingredient
        fields = '__all__'


class SupplierSerializer(serializers.ModelSerializer):
    """Сериализатор для поставщиков"""
    halal_certificate_number = serializers.CharField(source='halal_certificate.certificate_number', read_only=True)
    
    class Meta:
        model = Supplier
        fields = '__all__'


class ProductionProcessSerializer(serializers.ModelSerializer):
    """Сериализатор для производственных процессов"""
    
    class Meta:
        model = ProductionProcess
        fields = '__all__'


class InterviewQuestionSerializer(serializers.ModelSerializer):
    """Сериализатор для вопросов интервью"""
    
    class Meta:
        model = InterviewQuestion
        fields = '__all__'


class InterviewResponseSerializer(serializers.ModelSerializer):
    """Сериализатор для ответов на вопросы"""
    question_text = serializers.CharField(source='question.question_text', read_only=True)
    question_category = serializers.CharField(source='question.category', read_only=True)
    
    class Meta:
        model = InterviewResponse
        fields = '__all__'


class CompanyAssessmentSerializer(serializers.ModelSerializer):
    """Сериализатор для оценки компаний"""
    interview_responses = InterviewResponseSerializer(many=True, read_only=True)
    
    class Meta:
        model = CompanyAssessment
        fields = '__all__'


class ComplianceAuditSerializer(serializers.ModelSerializer):
    """Сериализатор для аудитов соответствия"""
    company_name = serializers.CharField(source='company_assessment.company_name', read_only=True)
    
    class Meta:
        model = ComplianceAudit
        fields = '__all__'


class PartnershipSerializer(serializers.ModelSerializer):
    """Сериализатор для партнерств"""
    company_name = serializers.CharField(source='company_assessment.company_name', read_only=True)
    
    class Meta:
        model = Partnership
        fields = '__all__'
