# AI Integration

Папка содержит функции для интеграции с ИИ для ответов на вопросы пользователей.

## Файлы

- `ai_chat.py` - Основной модуль с классом AIChatService и функцией ask_ai
- `views.py` - Django API views для веб-интерфейса
- `urls.py` - URL маршруты для API
- `test_ai.py` - Тестовый скрипт для проверки работы

## Использование

### Простая функция
```python
from ai_integration.ai_chat import ask_ai

# Простой вопрос
answer = ask_ai("Привет! Как дела?")
print(answer)

# Вопрос с контекстом
answer = ask_ai("Что такое Python?", context="Пользователь изучает программирование")
print(answer)
```

### Класс AIChatService
```python
from ai_integration.ai_chat import AIChatService

ai_service = AIChatService()

# Простой вопрос
result = ai_service.ask_question("Расскажи про машинное обучение")
if result["success"]:
    print(result["answer"])

# Вопрос с контекстом
result = ai_service.ask_question(
    "Что посоветуешь?", 
    context="Пользователь хочет изучить веб-разработку"
)

# Разговор с историей
history = [
    {"role": "user", "content": "Меня зовут Иван"},
    {"role": "assistant", "content": "Привет, Иван!"}
]
result = ai_service.ask_with_history("Что ты помнишь обо мне?", history)
```

## API Endpoints

### POST /ai/chat/
Отправка вопроса ИИ ассистенту

**Запрос:**
```json
{
    "question": "Привет! Как дела?",
    "context": "Дополнительный контекст (необязательно)"
}
```

**Ответ:**
```json
{
    "success": true,
    "answer": "Привет! У меня все отлично, спасибо! Как дела у тебя?",
    "question": "Привет! Как дела?",
    "model": "gpt-4"
}
```

### POST /ai/chat/history/
Отправка вопроса с учетом истории разговора

**Запрос:**
```json
{
    "question": "Что ты помнишь обо мне?",
    "conversation_history": [
        {"role": "user", "content": "Меня зовут Мадина"},
        {"role": "assistant", "content": "Привет, Мадина!"}
    ]
}
```

## Тестирование

Запустите тестовый скрипт:
```bash
cd backend/ai_integration
python test_ai.py
```

## Swagger UI

Откройте `http://localhost:8000/swagger/` и найдите секцию "AI Integration" для интерактивного тестирования API.
