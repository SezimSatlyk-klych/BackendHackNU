from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .halal_llm_trainer import HalalAnalysisLLM
from broker_company.models import CompanyAssessment, Ingredient
import json


class HalalAnalysisView(APIView):
    """API для анализа халяльности с помощью LLM"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM()
    
    @swagger_auto_schema(
        operation_description="Анализ халяльности ингредиента",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['ingredient_name'],
            properties={
                'ingredient_name': openapi.Schema(
                    type=openapi.TYPE_STRING, 
                    description='Название ингредиента для анализа'
                )
            }
        ),
        responses={
            200: openapi.Response(
                description="Анализ халяльности",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'ingredient': openapi.Schema(type=openapi.TYPE_STRING),
                        'halal_status': openapi.Schema(type=openapi.TYPE_STRING),
                        'analysis': openapi.Schema(type=openapi.TYPE_STRING),
                        'confidence': openapi.Schema(type=openapi.TYPE_NUMBER),
                    }
                )
            ),
            400: openapi.Response(description="Неверные данные"),
            500: openapi.Response(description="Ошибка сервера")
        },
        tags=['LLM Халяль Анализ']
    )
    def post(self, request):
        """Анализ халяльности ингредиента"""
        ingredient_name = request.data.get('ingredient_name')
        
        if not ingredient_name:
            return Response(
                {'error': 'Название ингредиента обязательно'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            result = self.llm_system.analyze_ingredient_halal_status(ingredient_name)
            return Response(result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка анализа: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CompanyGradingView(APIView):
    """API для оценки соответствия компании халяльным стандартам"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM()
    
    @swagger_auto_schema(
        operation_description="Оценка соответствия компании халяльным стандартам",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['company_data'],
            properties={
                'company_data': openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'name': openapi.Schema(type=openapi.TYPE_STRING),
                        'industry': openapi.Schema(type=openapi.TYPE_STRING),
                        'country': openapi.Schema(type=openapi.TYPE_STRING),
                        'certification_info': openapi.Schema(type=openapi.TYPE_STRING),
                        'production_info': openapi.Schema(type=openapi.TYPE_STRING),
                        'ingredients_info': openapi.Schema(type=openapi.TYPE_STRING),
                        'logistics_info': openapi.Schema(type=openapi.TYPE_STRING),
                        'values_info': openapi.Schema(type=openapi.TYPE_STRING),
                    }
                )
            }
        ),
        responses={
            200: openapi.Response(
                description="Оценка компании",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'company_name': openapi.Schema(type=openapi.TYPE_STRING),
                        'analysis': openapi.Schema(type=openapi.TYPE_STRING),
                        'timestamp': openapi.Schema(type=openapi.TYPE_STRING),
                        'model_used': openapi.Schema(type=openapi.TYPE_STRING),
                    }
                )
            ),
            400: openapi.Response(description="Неверные данные"),
            500: openapi.Response(description="Ошибка сервера")
        },
        tags=['LLM Халяль Анализ']
    )
    def post(self, request):
        """Оценка соответствия компании халяльным стандартам"""
        company_data = request.data.get('company_data')
        
        if not company_data:
            return Response(
                {'error': 'Данные компании обязательны'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            result = self.llm_system.grade_company_compliance(company_data)
            return Response(result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка оценки: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ResearchReportView(APIView):
    """API для генерации исследовательских отчетов"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM()
    
    @swagger_auto_schema(
        operation_description="Генерация исследовательского отчета",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['topic'],
            properties={
                'topic': openapi.Schema(
                    type=openapi.TYPE_STRING, 
                    description='Тема исследования'
                )
            }
        ),
        responses={
            200: openapi.Response(
                description="Исследовательский отчет",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'topic': openapi.Schema(type=openapi.TYPE_STRING),
                        'report': openapi.Schema(type=openapi.TYPE_STRING),
                        'timestamp': openapi.Schema(type=openapi.TYPE_STRING),
                        'word_count': openapi.Schema(type=openapi.TYPE_INTEGER),
                    }
                )
            ),
            400: openapi.Response(description="Неверные данные"),
            500: openapi.Response(description="Ошибка сервера")
        },
        tags=['LLM Халяль Анализ']
    )
    def post(self, request):
        """Генерация исследовательского отчета"""
        topic = request.data.get('topic')
        
        if not topic:
            return Response(
                {'error': 'Тема исследования обязательна'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            result = self.llm_system.generate_research_report(topic)
            return Response(result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка генерации отчета: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class LLMTrainingView(APIView):
    """API для управления тренировкой LLM"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM()
    
    @swagger_auto_schema(
        operation_description="Запуск процесса подготовки данных для тренировки LLM",
        responses={
            200: openapi.Response(
                description="Данные подготовлены",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'training_data_count': openapi.Schema(type=openapi.TYPE_INTEGER),
                        'training_prompts_count': openapi.Schema(type=openapi.TYPE_INTEGER),
                        'files_created': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    }
                )
            ),
            500: openapi.Response(description="Ошибка сервера")
        },
        tags=['LLM Халяль Анализ']
    )
    def post(self, request):
        """Подготовка данных для тренировки LLM"""
        try:
            # Собираем данные
            training_data = self.llm_system.collect_training_data()
            
            if not training_data:
                return Response(
                    {'error': 'Нет данных для тренировки'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Подготавливаем промпты
            training_prompts = self.llm_system.prepare_training_prompts()
            
            # Создаем датасет
            train_data, test_data = self.llm_system.create_fine_tuning_dataset(training_prompts)
            
            files_created = ['halal_training_data.jsonl', 'halal_test_data.jsonl']
            
            return Response({
                'message': 'Данные для тренировки подготовлены',
                'training_data_count': len(training_data),
                'training_prompts_count': len(training_prompts),
                'train_data_count': len(train_data),
                'test_data_count': len(test_data),
                'files_created': files_created
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка подготовки данных: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BatchAnalysisView(APIView):
    """API для массового анализа компаний"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM()
    
    @swagger_auto_schema(
        operation_description="Массовый анализ компаний из базы данных",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'limit': openapi.Schema(
                    type=openapi.TYPE_INTEGER, 
                    description='Количество компаний для анализа (по умолчанию 10)'
                ),
                'status_filter': openapi.Schema(
                    type=openapi.TYPE_STRING, 
                    description='Фильтр по статусу оценки'
                )
            }
        ),
        responses={
            200: openapi.Response(
                description="Результаты массового анализа",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'analyzed_count': openapi.Schema(type=openapi.TYPE_INTEGER),
                        'results': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_OBJECT)),
                        'timestamp': openapi.Schema(type=openapi.TYPE_STRING),
                    }
                )
            ),
            500: openapi.Response(description="Ошибка сервера")
        },
        tags=['LLM Халяль Анализ']
    )
    def post(self, request):
        """Массовый анализ компаний"""
        try:
            limit = request.data.get('limit', 10)
            status_filter = request.data.get('status_filter')
            
            # Получаем компании для анализа
            queryset = CompanyAssessment.objects.all()
            if status_filter:
                queryset = queryset.filter(status=status_filter)
            
            companies = queryset[:limit]
            
            results = []
            for company in companies:
                # Подготавливаем данные компании
                company_data = {
                    'name': company.company_name,
                    'industry': company.industry,
                    'country': company.country,
                    'certification_info': f"Оценка сертификации: {company.certification_score}/100",
                    'production_info': f"Оценка производства: {company.production_score}/100",
                    'ingredients_info': f"Оценка ингредиентов: {company.ingredients_score}/100",
                    'logistics_info': f"Оценка логистики: {company.logistics_score}/100",
                    'values_info': f"Оценка ценностей: {company.company_values_score}/100"
                }
                
                # Анализируем компанию
                analysis = self.llm_system.grade_company_compliance(company_data)
                results.append({
                    'company_id': company.id,
                    'company_name': company.company_name,
                    'analysis': analysis
                })
            
            return Response({
                'analyzed_count': len(results),
                'results': results,
                'timestamp': datetime.now().isoformat()
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка массового анализа: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
