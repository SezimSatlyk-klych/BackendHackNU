from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
try:
    from halal_llm_trainer import HalalAnalysisLLM  # heavy deps, may be absent at runtime
except Exception:
    HalalAnalysisLLM = None
from broker_company.models import CompanyAssessment, Ingredient, HalalCertificate
from datetime import datetime
import json


class HalalAnalysisView(APIView):
    """API для анализа халяльности с помощью LLM"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM() if HalalAnalysisLLM else None
    
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
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.analyze_ingredient_halal_status(ingredient_name)
            return Response(result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка анализа: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @swagger_auto_schema(
        operation_description="Анализ халяльности ингредиента (GET)",
        manual_parameters=[
            openapi.Parameter(
                'ingredient_name', openapi.IN_QUERY, required=True,
                description='Название ингредиента', type=openapi.TYPE_STRING
            )
        ],
        responses={200: openapi.Response(description="OK")},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        ingredient_name = request.query_params.get('ingredient_name')
        if not ingredient_name:
            return Response({'error': 'ingredient_name обязателен'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.analyze_ingredient_halal_status(ingredient_name)
            return Response(result, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': f'Ошибка анализа: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CompanyGradingView(APIView):
    """API для оценки соответствия компании халяльным стандартам"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM() if HalalAnalysisLLM else None
    
    @swagger_auto_schema(
        operation_description="Оценка соответствия компании халяльным стандартам. Если указан company_id или company_name и данные есть в БД, используется расчёт на основе БД. Иначе — LLM.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'company_id': openapi.Schema(type=openapi.TYPE_INTEGER, description='ID записи CompanyAssessment'),
                'company_name': openapi.Schema(type=openapi.TYPE_STRING, description='Название компании для поиска в БД'),
                'use_db': openapi.Schema(type=openapi.TYPE_BOOLEAN, description='Принудительно использовать расчёт по БД, если возможно'),
                'company_data': openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    description='Свободная форма данных для LLM, если записи в БД нет',
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
                ),
            }
        ),
        responses={
            200: openapi.Response(
                description="Оценка компании (из БД либо через LLM)",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'company_name': openapi.Schema(type=openapi.TYPE_STRING),
                        'halal_valid': openapi.Schema(type=openapi.TYPE_BOOLEAN),
                        'compliance_percent': openapi.Schema(type=openapi.TYPE_INTEGER),
                        'breakdown': openapi.Schema(type=openapi.TYPE_OBJECT),
                        'has_active_certificate': openapi.Schema(type=openapi.TYPE_BOOLEAN),
                        'status': openapi.Schema(type=openapi.TYPE_STRING),
                        'timestamp': openapi.Schema(type=openapi.TYPE_STRING),
                        'source': openapi.Schema(type=openapi.TYPE_STRING),
                        'analysis': openapi.Schema(type=openapi.TYPE_STRING),
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
        """Оценка соответствия компании халяльным стандартам (БД → LLM)."""
        try:
            company_id = request.data.get('company_id')
            company_name = request.data.get('company_name')
            use_db = request.data.get('use_db', True)

            assessment = None
            if company_id:
                assessment = CompanyAssessment.objects.filter(id=company_id).first()
            elif company_name:
                assessment = CompanyAssessment.objects.filter(company_name__iexact=company_name).first()

            if use_db and assessment:
                # Прямой расчёт из БД
                result = self.llm_system.grade_company_from_db(assessment)
                return Response(result, status=status.HTTP_200_OK)

            # Fallback: используем LLM по предоставленным данным
            company_data = request.data.get('company_data')
            if not company_data:
                return Response(
                    {'error': 'Нет записи в БД. Передайте company_data для оценки через LLM.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.grade_company_compliance(company_data)
            result['source'] = 'llm'
            return Response(result, status=status.HTTP_200_OK)

        except Exception as e:
            return Response(
                {'error': f'Ошибка оценки: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @swagger_auto_schema(
        operation_description="Оценка соответствия компании (GET). Сначала ищем в БД по company_id/company_name (use_db=true), иначе используем LLM по переданным полям.",
        manual_parameters=[
            openapi.Parameter('company_id', openapi.IN_QUERY, type=openapi.TYPE_INTEGER, required=False, description='ID CompanyAssessment'),
            openapi.Parameter('company_name', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Название компании'),
            openapi.Parameter('use_db', openapi.IN_QUERY, type=openapi.TYPE_BOOLEAN, required=False, description='Использовать расчёт по БД (default=true)'),
            openapi.Parameter('name', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Имя компании (LLM)'),
            openapi.Parameter('industry', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Отрасль (LLM)'),
            openapi.Parameter('country', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Страна (LLM)'),
            openapi.Parameter('certification_info', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Сертификация (LLM)'),
            openapi.Parameter('production_info', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Производство (LLM)'),
            openapi.Parameter('ingredients_info', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Ингредиенты (LLM)'),
            openapi.Parameter('logistics_info', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Логистика (LLM)'),
            openapi.Parameter('values_info', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Ценности (LLM)'),
        ],
        responses={200: openapi.Response(description='OK')},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        try:
            company_id = request.query_params.get('company_id')
            company_name = request.query_params.get('company_name')
            use_db_param = request.query_params.get('use_db')
            use_db = True if use_db_param is None else str(use_db_param).lower() in ['1','true','yes']

            assessment = None
            if company_id:
                assessment = CompanyAssessment.objects.filter(id=company_id).first()
            elif company_name:
                assessment = CompanyAssessment.objects.filter(company_name__iexact=company_name).first()

            if use_db and assessment:
                result = self.llm_system.grade_company_from_db(assessment) if self.llm_system else {
                    'error': 'LLM система не инициализирована, но расчёт по БД недоступен',
                }
                return Response(result, status=status.HTTP_200_OK)

            # LLM fallback c query-параметрами
            company_data = {
                'name': request.query_params.get('name'),
                'industry': request.query_params.get('industry'),
                'country': request.query_params.get('country'),
                'certification_info': request.query_params.get('certification_info'),
                'production_info': request.query_params.get('production_info'),
                'ingredients_info': request.query_params.get('ingredients_info'),
                'logistics_info': request.query_params.get('logistics_info'),
                'values_info': request.query_params.get('values_info'),
            }
            if not any(v for v in company_data.values()):
                return Response({'error': 'Нужно указать company_id/company_name или поля для LLM (name, industry, ...).'}, status=status.HTTP_400_BAD_REQUEST)

            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.grade_company_compliance(company_data)
            result['source'] = 'llm'
            return Response(result, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': f'Ошибка оценки: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ResearchReportView(APIView):
    """API для генерации исследовательских отчетов"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM() if HalalAnalysisLLM else None
    
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
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.generate_research_report(topic)
            return Response(result, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response(
                {'error': f'Ошибка генерации отчета: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @swagger_auto_schema(
        operation_description="Генерация исследовательского отчёта (GET)",
        manual_parameters=[
            openapi.Parameter('topic', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=True, description='Тема отчёта')
        ],
        responses={200: openapi.Response(description='OK')},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        topic = request.query_params.get('topic')
        if not topic:
            return Response({'error': 'topic обязателен'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn/numpy согласно requirements.txt или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            result = self.llm_system.generate_research_report(topic)
            return Response(result, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': f'Ошибка генерации отчёта: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class LLMTrainingView(APIView):
    """API для управления тренировкой LLM"""
    
    def __init__(self):
        super().__init__()
        self.llm_system = HalalAnalysisLLM() if HalalAnalysisLLM else None
    
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
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
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

    @swagger_auto_schema(
        operation_description="Подготовка данных для тренировки LLM (GET)",
        responses={200: openapi.Response(description='OK')},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        try:
            if not self.llm_system and HalalAnalysisLLM:
                self.llm_system = HalalAnalysisLLM()
            if not self.llm_system:
                return Response(
                    {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn или пересоберите контейнер.'},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            training_data = self.llm_system.collect_training_data()
            if not training_data:
                return Response({'error': 'Нет данных для тренировки'}, status=status.HTTP_400_BAD_REQUEST)
            training_prompts = self.llm_system.prepare_training_prompts()
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
            return Response({'error': f'Ошибка подготовки данных: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


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

    @swagger_auto_schema(
        operation_description="Массовый анализ компаний (GET)",
        manual_parameters=[
            openapi.Parameter('limit', openapi.IN_QUERY, type=openapi.TYPE_INTEGER, required=False, description='Количество компаний'),
            openapi.Parameter('status_filter', openapi.IN_QUERY, type=openapi.TYPE_STRING, required=False, description='Фильтр по статусу оценки'),
        ],
        responses={200: openapi.Response(description='OK')},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        try:
            limit = int(request.query_params.get('limit') or 10)
            status_filter = request.query_params.get('status_filter')
            queryset = CompanyAssessment.objects.all()
            if status_filter:
                queryset = queryset.filter(status=status_filter)
            companies = queryset[:limit]
            results = []
            for company in companies:
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
                if not self.llm_system and HalalAnalysisLLM:
                    self.llm_system = HalalAnalysisLLM()
                if not self.llm_system:
                    return Response(
                        {'error': 'LLM не доступен (нет зависимостей). Установите pandas/scikit-learn или пересоберите контейнер.'},
                        status=status.HTTP_503_SERVICE_UNAVAILABLE
                    )
                analysis = self.llm_system.grade_company_compliance(company_data)
                results.append({'company_id': company.id, 'company_name': company.company_name, 'analysis': analysis})
            return Response({'analyzed_count': len(results), 'results': results, 'timestamp': datetime.now().isoformat()}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'error': f'Ошибка массового анализа: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CompanyPredictionView(APIView):
    """Прогноз прохождения халяль-аудита: по одной компании (company_id) или по всем."""

    def __init__(self):
        super().__init__()

    @staticmethod
    def _db_grade(assessment: CompanyAssessment) -> dict:
        # Базовый расчёт соответствия (среднее по критериям)
        scores = [
            assessment.certification_score,
            assessment.production_score,
            assessment.ingredients_score,
            assessment.logistics_score,
            assessment.company_values_score,
        ]
        valid_scores = [s for s in scores if isinstance(s, int) and s >= 0]
        compliance_percent = round(sum(valid_scores) / len(valid_scores)) if valid_scores else 0

        # Активный сертификат
        try:
            active_cert = HalalCertificate.objects.filter(
                company_name__iexact=assessment.company_name,
                status='active',
            ).exists()
        except Exception:
            active_cert = False

        # Вероятность прохождения (от 0 до 1)
        pass_prob = compliance_percent / 100.0
        if active_cert:
            pass_prob = min(1.0, pass_prob + 0.1)

        # Самые слабые критерии
        breakdown = {
            'certification': assessment.certification_score,
            'production': assessment.production_score,
            'ingredients': assessment.ingredients_score,
            'logistics': assessment.logistics_score,
            'company_values': assessment.company_values_score,
        }
        weakest_name = min(breakdown, key=breakdown.get)
        weakest_score = breakdown[weakest_name]

        # Прогноз на будущее: предполагаем подтяжку слабого места на +15 и общую оптимизацию +10% недобора
        improved_breakdown = breakdown.copy()
        improved_breakdown[weakest_name] = min(100, weakest_score + 15)
        projected = round(sum(improved_breakdown.values()) / 5)
        projected = min(100, projected + round((100 - projected) * 0.10))
        projected_pass_prob = min(1.0, projected / 100.0 + (0.05 if active_cert else 0.0))

        reasons = []
        if active_cert:
            reasons.append('Есть действующий сертификат — повышает шанс прохождения')
        else:
            reasons.append('Нет активного сертификата — рекомендуется сертификация')
        reasons.append(f"Слабое место: {weakest_name} ({weakest_score}/100)")

        return {
            'company_id': assessment.id,
            'company_name': assessment.company_name,
            'compliance_percent': compliance_percent,
            'pass_probability': round(pass_prob, 2),
            'projected_compliance_percent': projected,
            'projected_pass_probability': round(projected_pass_prob, 2),
            'has_active_certificate': active_cert,
            'breakdown': breakdown,
            'weakest_criterion': {
                'name': weakest_name,
                'score': weakest_score,
            },
            'reasons': reasons,
            'timestamp': datetime.now().isoformat(),
        }

    @swagger_auto_schema(
        operation_description="Прогноз прохождения аудита. Если передан company_id — по одной компании; если all=true — по всем.",
        manual_parameters=[
            openapi.Parameter('company_id', openapi.IN_QUERY, type=openapi.TYPE_INTEGER, required=False, description='ID CompanyAssessment'),
            openapi.Parameter('all', openapi.IN_QUERY, type=openapi.TYPE_BOOLEAN, required=False, description='Проанализировать все компании'),
            openapi.Parameter('limit', openapi.IN_QUERY, type=openapi.TYPE_INTEGER, required=False, description='Ограничение количества при all=true (по умолчанию 50)'),
        ],
        responses={200: openapi.Response(description='OK')},
        tags=['zzz LLM GET']
    )
    def get(self, request):
        try:
            company_id = request.query_params.get('company_id')
            analyze_all = str(request.query_params.get('all', 'false')).lower() in ['1','true','yes']
            limit = int(request.query_params.get('limit') or 50)

            if company_id:
                assessment = CompanyAssessment.objects.filter(id=company_id).first()
                if not assessment:
                    return Response({'error': 'CompanyAssessment не найден'}, status=status.HTTP_404_NOT_FOUND)
                return Response(self._db_grade(assessment), status=status.HTTP_200_OK)

            if analyze_all:
                results = [self._db_grade(a) for a in CompanyAssessment.objects.all()[:limit]]
                # Сводка по портфелю
                avg_comp = round(sum(r['compliance_percent'] for r in results) / len(results)) if results else 0
                avg_prob = round(sum(r['pass_probability'] for r in results) / len(results), 2) if results else 0.0
                return Response({
                    'count': len(results),
                    'avg_compliance_percent': avg_comp,
                    'avg_pass_probability': avg_prob,
                    'results': results,
                    'timestamp': datetime.now().isoformat(),
                }, status=status.HTTP_200_OK)

            return Response({'error': 'Укажите company_id или all=true'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': f'Ошибка прогноза: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
