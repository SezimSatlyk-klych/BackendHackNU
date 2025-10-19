from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import (
    CertificationBody, HalalCertificate, IngredientCategory, Ingredient,
    Supplier, ProductionProcess, CompanyAssessment, InterviewQuestion,
    InterviewResponse, ComplianceAudit, Partnership
)
from .serializers import (
    CertificationBodySerializer, HalalCertificateSerializer, IngredientCategorySerializer,
    IngredientSerializer, SupplierSerializer, ProductionProcessSerializer,
    CompanyAssessmentSerializer, InterviewQuestionSerializer, InterviewResponseSerializer,
    ComplianceAuditSerializer, PartnershipSerializer
)


class CertificationBodyViewSet(viewsets.ModelViewSet):
    """CRUD операции для органов сертификации халяльности"""
    queryset = CertificationBody.objects.all()
    serializer_class = CertificationBodySerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех органов сертификации",
        responses={200: CertificationBodySerializer(many=True)},
        tags=['Брокерская компания - Сертификация']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый орган сертификации",
        request_body=CertificationBodySerializer,
        responses={201: CertificationBodySerializer},
        tags=['Брокерская компания - Сертификация']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class HalalCertificateViewSet(viewsets.ModelViewSet):
    """CRUD операции для сертификатов халяльности"""
    queryset = HalalCertificate.objects.all()
    serializer_class = HalalCertificateSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех сертификатов халяльности",
        responses={200: HalalCertificateSerializer(many=True)},
        tags=['Брокерская компания - Сертификация']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый сертификат халяльности",
        request_body=HalalCertificateSerializer,
        responses={201: HalalCertificateSerializer},
        tags=['Брокерская компания - Сертификация']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class IngredientCategoryViewSet(viewsets.ModelViewSet):
    """CRUD операции для категорий ингредиентов"""
    queryset = IngredientCategory.objects.all()
    serializer_class = IngredientCategorySerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех категорий ингредиентов",
        responses={200: IngredientCategorySerializer(many=True)},
        tags=['Брокерская компания - Ингредиенты']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новую категорию ингредиентов",
        request_body=IngredientCategorySerializer,
        responses={201: IngredientCategorySerializer},
        tags=['Брокерская компания - Ингредиенты']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class IngredientViewSet(viewsets.ModelViewSet):
    """CRUD операции для ингредиентов"""
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех ингредиентов",
        responses={200: IngredientSerializer(many=True)},
        tags=['Брокерская компания - Ингредиенты']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый ингредиент",
        request_body=IngredientSerializer,
        responses={201: IngredientSerializer},
        tags=['Брокерская компания - Ингредиенты']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class SupplierViewSet(viewsets.ModelViewSet):
    """CRUD операции для поставщиков"""
    queryset = Supplier.objects.all()
    serializer_class = SupplierSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех поставщиков",
        responses={200: SupplierSerializer(many=True)},
        tags=['Брокерская компания - Поставщики']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать нового поставщика",
        request_body=SupplierSerializer,
        responses={201: SupplierSerializer},
        tags=['Брокерская компания - Поставщики']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class ProductionProcessViewSet(viewsets.ModelViewSet):
    """CRUD операции для производственных процессов"""
    queryset = ProductionProcess.objects.all()
    serializer_class = ProductionProcessSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех производственных процессов",
        responses={200: ProductionProcessSerializer(many=True)},
        tags=['Брокерская компания - Производство']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый производственный процесс",
        request_body=ProductionProcessSerializer,
        responses={201: ProductionProcessSerializer},
        tags=['Брокерская компания - Производство']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class InterviewQuestionViewSet(viewsets.ModelViewSet):
    """CRUD операции для вопросов интервью"""
    queryset = InterviewQuestion.objects.all()
    serializer_class = InterviewQuestionSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех вопросов интервью",
        responses={200: InterviewQuestionSerializer(many=True)},
        tags=['Брокерская компания - Интервью']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый вопрос интервью",
        request_body=InterviewQuestionSerializer,
        responses={201: InterviewQuestionSerializer},
        tags=['Брокерская компания - Интервью']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class CompanyAssessmentViewSet(viewsets.ModelViewSet):
    """CRUD операции для оценки компаний"""
    queryset = CompanyAssessment.objects.all()
    serializer_class = CompanyAssessmentSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех оценок компаний",
        responses={200: CompanyAssessmentSerializer(many=True)},
        tags=['Брокерская компания - Оценка']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новую оценку компании",
        request_body=CompanyAssessmentSerializer,
        responses={201: CompanyAssessmentSerializer},
        tags=['Брокерская компания - Оценка']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(
        method='post',
        operation_description="Запустить автоматический расчет общей оценки",
        responses={
            200: openapi.Response(
                description="Оценка пересчитана",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'overall_score': openapi.Schema(type=openapi.TYPE_INTEGER),
                    }
                )
            ),
            404: 'Оценка не найдена',
        },
        tags=['Брокерская компания - Оценка']
    )
    @action(detail=True, methods=['post'])
    def calculate_score(self, request, pk=None):
        """Автоматический расчет общей оценки"""
        try:
            assessment = self.get_object()
            
            # Расчет общей оценки как среднее арифметическое всех критериев
            scores = [
                assessment.certification_score,
                assessment.production_score,
                assessment.ingredients_score,
                assessment.logistics_score,
                assessment.company_values_score
            ]
            
            # Исключаем нулевые оценки из расчета
            valid_scores = [score for score in scores if score > 0]
            
            if valid_scores:
                overall_score = sum(valid_scores) / len(valid_scores)
                assessment.overall_score = round(overall_score)
                assessment.save()
                
                return Response({
                    'message': 'Общая оценка пересчитана',
                    'overall_score': assessment.overall_score,
                    'individual_scores': {
                        'certification': assessment.certification_score,
                        'production': assessment.production_score,
                        'ingredients': assessment.ingredients_score,
                        'logistics': assessment.logistics_score,
                        'company_values': assessment.company_values_score
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'message': 'Нет данных для расчета оценки',
                    'overall_score': 0
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except CompanyAssessment.DoesNotExist:
            return Response(
                {'error': 'Оценка не найдена'},
                status=status.HTTP_404_NOT_FOUND
            )


class InterviewResponseViewSet(viewsets.ModelViewSet):
    """CRUD операции для ответов на вопросы интервью"""
    queryset = InterviewResponse.objects.all()
    serializer_class = InterviewResponseSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех ответов на вопросы",
        responses={200: InterviewResponseSerializer(many=True)},
        tags=['Брокерская компания - Интервью']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый ответ на вопрос",
        request_body=InterviewResponseSerializer,
        responses={201: InterviewResponseSerializer},
        tags=['Брокерская компания - Интервью']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class ComplianceAuditViewSet(viewsets.ModelViewSet):
    """CRUD операции для аудитов соответствия"""
    queryset = ComplianceAudit.objects.all()
    serializer_class = ComplianceAuditSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех аудитов соответствия",
        responses={200: ComplianceAuditSerializer(many=True)},
        tags=['Брокерская компания - Аудит']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый аудит соответствия",
        request_body=ComplianceAuditSerializer,
        responses={201: ComplianceAuditSerializer},
        tags=['Брокерская компания - Аудит']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class PartnershipViewSet(viewsets.ModelViewSet):
    """CRUD операции для партнерств"""
    queryset = Partnership.objects.all()
    serializer_class = PartnershipSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех партнерств",
        responses={200: PartnershipSerializer(many=True)},
        tags=['Брокерская компания - Партнерство']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новое партнерство",
        request_body=PartnershipSerializer,
        responses={201: PartnershipSerializer},
        tags=['Брокерская компания - Партнерство']
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)