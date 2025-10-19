from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from django.http import HttpResponse
import base64
from .voice_service import VoiceService


class VoiceToVoiceAudioView(APIView):
    parser_classes = (MultiPartParser, FormParser)
    
    @swagger_auto_schema(
        operation_description="🎤 Полный цикл: голос -> текст -> AI ответ -> голос (возвращает готовый аудио файл)",
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
                description="🎵 Готовый аудио файл (MP3)",
                schema=openapi.Schema(
                    type=openapi.TYPE_FILE,
                    format=openapi.FORMAT_BINARY
                )
            ),
            400: openapi.Response(description="❌ Неверные данные"),
            500: openapi.Response(description="💥 Ошибка сервера")
        }
    )
    def post(self, request):
        """
        🎤 Voice-to-Voice AI Assistant (Audio File Response)
        
        Полный цикл обработки с возвратом готового аудио файла:
        1. 🎵 Загружаете аудио файл с вопросом
        2. 📝 AI распознает речь и извлекает текст
        3. 🤖 AI обрабатывает вопрос и генерирует ответ
        4. 🔊 AI конвертирует ответ в речь
        5. 📁 Получаете готовый MP3 файл для скачивания
        
        Поддерживаемые форматы: WAV, MP3, M4A, OGG
        Язык распознавания: Русский
        Голос: Фиксированный (из .env файла)
        """
        audio_file = request.FILES.get('audio_file')
        context = request.data.get('context')
        
        if not audio_file:
            return Response(
                {'error': 'Аудио файл обязателен'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            voice_service = VoiceService()
            result = voice_service.process_voice_to_voice(audio_file, context)
            
            if result["success"]:
                # Декодируем base64 в бинарные данные
                audio_data = base64.b64decode(result["audio_response_base64"])
                
                # Возвращаем готовый аудио файл
                response = HttpResponse(audio_data, content_type='audio/mpeg')
                response['Content-Disposition'] = 'attachment; filename="ai_response.mp3"'
                response['Content-Length'] = len(audio_data)
                
                return response
            else:
                return Response(result, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                
        except Exception as e:
            return Response(
                {'error': f'Ошибка сервера: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
