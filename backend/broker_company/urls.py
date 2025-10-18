from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CertificationBodyViewSet, HalalCertificateViewSet, IngredientCategoryViewSet,
    IngredientViewSet, SupplierViewSet, ProductionProcessViewSet,
    CompanyAssessmentViewSet, InterviewQuestionViewSet, InterviewResponseViewSet,
    ComplianceAuditViewSet, PartnershipViewSet
)
from .llm_views import (
    HalalAnalysisView, CompanyGradingView, ResearchReportView, 
    LLMTrainingView, BatchAnalysisView
)

router = DefaultRouter()
router.register(r'certification-bodies', CertificationBodyViewSet)
router.register(r'halal-certificates', HalalCertificateViewSet)
router.register(r'ingredient-categories', IngredientCategoryViewSet)
router.register(r'ingredients', IngredientViewSet)
router.register(r'suppliers', SupplierViewSet)
router.register(r'production-processes', ProductionProcessViewSet)
router.register(r'company-assessments', CompanyAssessmentViewSet)
router.register(r'interview-questions', InterviewQuestionViewSet)
router.register(r'interview-responses', InterviewResponseViewSet)
router.register(r'compliance-audits', ComplianceAuditViewSet)
router.register(r'partnerships', PartnershipViewSet)

urlpatterns = [
    path('', include(router.urls)),
    
    # LLM API эндпоинты
    path('llm/analyze-ingredient/', HalalAnalysisView.as_view(), name='analyze-ingredient'),
    path('llm/grade-company/', CompanyGradingView.as_view(), name='grade-company'),
    path('llm/generate-report/', ResearchReportView.as_view(), name='generate-report'),
    path('llm/prepare-training/', LLMTrainingView.as_view(), name='prepare-training'),
    path('llm/batch-analysis/', BatchAnalysisView.as_view(), name='batch-analysis'),
]
