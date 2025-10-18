from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
import os
import openai
import json

# Настройка OpenAI для старой версии
openai.api_key = os.getenv("OPENAI_API_KEY")

@swagger_auto_schema(
    method='post',
    operation_description="Отправка сообщения чатботу",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        required=['message'],
        properties={
            'message': openapi.Schema(type=openapi.TYPE_STRING, description='Сообщение пользователя'),
        },
    ),
    responses={
        200: openapi.Response(
            description="Ответ чатбота",
            examples={
                "application/json": {
                    "response": "Ответ от GPT",
                    "status": "success"
                }
            }
        ),
        400: "Ошибка в запросе"
    }
)
@api_view(['POST'])
def chat(request):
    """
    Эндпоинт для общения с чатботом
    """
    try:
        message = request.data.get('message')
        
        if not message:
            return Response({
                "error": "Сообщение не может быть пустым"
            }, status=400)
        
        # Вызов OpenAI
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  # используем gpt-3.5-turbo (дешевле)
            messages=[
                {"role": "system", "content": "Вы полезный помощник для проекта HackNU."},
                {"role": "user", "content": message}
            ],
            max_tokens=1000,
            temperature=0.7
        )
        
        bot_response = response.choices[0].message.content
        
        return Response({
            "response": bot_response,
            "status": "success"
        })
        
    except Exception as e:
        return Response({
            "error": f"Ошибка: {str(e)}"
        }, status=500)

@swagger_auto_schema(
    method='get',
    operation_description="Проверка статуса API",
    responses={
        200: openapi.Response(
            description="API работает",
            examples={
                "application/json": {
                    "status": "success",
                    "message": "Chatbot API готов к работе"
                }
            }
        )
    }
)
@api_view(['GET'])
def health(request):
    """
    Проверка работоспособности API
    """
    return Response({
        "status": "success",
        "message": "Chatbot API готов к работе"
    })