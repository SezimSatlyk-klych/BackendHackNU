from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .ai_chat import AIChatService

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

