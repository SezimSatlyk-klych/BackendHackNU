from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from django.http import HttpResponse
import base64
from .ai_chat import AIChatService
from .voice_service import VoiceService

class AIChatView(APIView):
    @swagger_auto_schema(
        operation_description="Задать вопрос ИИ ассистенту",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'question': openapi.Schema(
                    type=openapi.TYPE_STRING, 
                    description='Вопрос пользователя'
                ),
                'context': openapi.Schema(
                    type=openapi.TYPE_STRING, 
                    description='Дополнительный контекст (необязательно)'
                )
            },
            required=['question']
        ),
        responses={
            200: openapi.Response(
                description="Успешный ответ ИИ",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN),
                        'answer': openapi.Schema(type=openapi.TYPE_STRING),
                        'question': openapi.Schema(type=openapi.TYPE_STRING),
                        'model': openapi.Schema(type=openapi.TYPE_STRING)
                    }
                )
            ),
            400: openapi.Response(description="Неверные данные"),
            500: openapi.Response(description="Ошибка сервера")
        }
    )
    def post(self, request):
        """Отправка вопроса ИИ ассистенту"""
        question = request.data.get('question')
        context = request.data.get('context')
        
        if not question:
            return Response(
                {'error': 'Поле "question" обязательно'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            ai_service = AIChatService()
            result = ai_service.ask_question(question, context)
            
            if result["success"]:
                return Response(result, status=status.HTTP_200_OK)
            else:
                return Response(result, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
        except Exception as e:
            return Response(
                {'error': f'Ошибка сервера: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VoiceToVoiceView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    
    @swagger_auto_schema(
        operation_description="🎤 Полный цикл: голос -> текст -> AI ответ -> голос. Загрузите аудио файл с вопросом и получите голосовой ответ от AI.",
        manual_parameters=[
            openapi.Parameter(
                'audio_file',
                openapi.IN_FORM,
                description="🎵 Аудио файл с вопросом (WAV, MP3, M4A, OGG)",
                type=openapi.TYPE_FILE,
                required=True
            ),
            openapi.Parameter(
                'context',
                openapi.IN_FORM,
                description="📝 Дополнительный контекст для AI (необязательно)",
                type=openapi.TYPE_STRING,
                required=False
            )
        ],
        responses={
            200: openapi.Response(
                description="✅ Успешная обработка",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'success': openapi.Schema(type=openapi.TYPE_BOOLEAN, description="Статус успеха"),
                        'original_question': openapi.Schema(type=openapi.TYPE_STRING, description="Распознанный вопрос"),
                        'ai_response': openapi.Schema(type=openapi.TYPE_STRING, description="Ответ AI"),
                        'audio_response_base64': openapi.Schema(type=openapi.TYPE_STRING, description="Аудио ответ в base64"),
                        'voice_id': openapi.Schema(type=openapi.TYPE_STRING, description="ID использованного голоса"),
                        'model': openapi.Schema(type=openapi.TYPE_STRING, description="Использованные модели")
                    }
                )
            ),
            400: openapi.Response(description="❌ Неверные данные"),
            500: openapi.Response(description="💥 Ошибка сервера")
        }
    )
    def post(self, request):
        audio_file = request.FILES.get('audio_file')
        context = request.data.get('context')
        
        if not audio_file:
            return Response({'error': 'Аудио файл обязателен'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            voice_service = VoiceService()
            result = voice_service.process_voice_to_voice(audio_file, context)
            return Response(result, status=status.HTTP_200_OK if result.get('success') else status.HTTP_500_INTERNAL_SERVER_ERROR)
        except Exception as e:
            return Response({'error': f'Ошибка сервера: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)