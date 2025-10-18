from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import ImageGeneration
from .serializers import ImageGenerationSerializer
from .image_service import ImageGenerationService
import threading


class ImageGenerationViewSet(viewsets.ModelViewSet):
    """CRUD операции для генерации комикс-стрипов (6 панелей) из текста"""
    queryset = ImageGeneration.objects.all()
    serializer_class = ImageGenerationSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех генераций комикс-стрипов",
        responses={200: ImageGenerationSerializer(many=True)},
        tags=['Text to Image']
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать новый комикс-стрип с 6 панелями",
        request_body=ImageGenerationSerializer,
        responses={201: ImageGenerationSerializer},
        tags=['Text to Image']
    )
    def create(self, request, *args, **kwargs):
        # Создаем запись
        response = super().create(request, *args, **kwargs)
        
        # Если создание успешно, запускаем генерацию в фоне
        if response.status_code == 201:
            generation_id = response.data['id']
            
            # Запускаем генерацию в отдельном потоке
            def generate_image_async():
                service = ImageGenerationService()
                service.process_generation_request(generation_id)
            
            thread = threading.Thread(target=generate_image_async)
            thread.daemon = True
            thread.start()
        
        return response
    
    @swagger_auto_schema(
        operation_description="Получить конкретную генерацию изображения",
        responses={200: ImageGenerationSerializer},
        tags=['Text to Image']
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Обновить генерацию изображения",
        request_body=ImageGenerationSerializer,
        responses={200: ImageGenerationSerializer},
        tags=['Text to Image']
    )
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Частично обновить генерацию изображения",
        request_body=ImageGenerationSerializer,
        responses={200: ImageGenerationSerializer},
        tags=['Text to Image']
    )
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Удалить генерацию изображения",
        responses={204: 'Генерация успешно удалена'},
        tags=['Text to Image']
    )
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)
    @swagger_auto_schema(
        method='post',
        operation_description="Принудительно запустить генерацию изображения",
        responses={
            200: openapi.Response(
                description="Генерация запущена",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'message': openapi.Schema(type=openapi.TYPE_STRING),
                        'generation_id': openapi.Schema(type=openapi.TYPE_INTEGER),
                    }
                )
            ),
            404: 'Генерация не найдена',
        },
        tags=['Text to Image']
    )
    @action(detail=True, methods=['post'])
    def generate(self, request, pk=None):
        """Принудительно запустить генерацию изображения"""
        try:
            generation = self.get_object()
            
            # Запускаем генерацию в отдельном потоке
            def generate_image_async():
                service = ImageGenerationService()
                service.process_generation_request(generation.id)
            
            thread = threading.Thread(target=generate_image_async)
            thread.daemon = True
            thread.start()
            
            return Response({
                'message': 'Генерация изображения запущена',
                'generation_id': generation.id
            }, status=status.HTTP_200_OK)
            
        except ImageGeneration.DoesNotExist:
            return Response(
                {'error': 'Генерация не найдена'},
                status=status.HTTP_404_NOT_FOUND
            )