#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работы AI чат функции
"""

from ai_chat import AIChatService, ask_ai

def test_simple_question():
    """Тест простого вопроса"""
    print("=== Тест простого вопроса ===")
    
    ai_service = AIChatService()
    result = ai_service.ask_question("Привет! Как дела?")
    
    if result["success"]:
        print(f"✅ Успех: {result['answer']}")
    else:
        print(f"❌ Ошибка: {result['error']}")

def test_question_with_context():
    """Тест вопроса с контекстом"""
    print("\n=== Тест вопроса с контекстом ===")
    
    ai_service = AIChatService()
    result = ai_service.ask_question(
        "Что такое машинное обучение?", 
        context="Пользователь изучает программирование и хочет понять основы ML"
    )
    
    if result["success"]:
        print(f"✅ Успех: {result['answer']}")
    else:
        print(f"❌ Ошибка: {result['error']}")

def test_simple_function():
    """Тест простой функции ask_ai"""
    print("\n=== Тест простой функции ===")
    
    answer = ask_ai("Расскажи про Python в двух предложениях")
    print(f"✅ Ответ: {answer}")


if __name__ == "__main__":
    print("🤖 Тестирование AI чат функции...")
    
    try:
        test_simple_question()
        test_question_with_context()
        test_simple_function()
        
        print("\n🎉 Все тесты завершены!")
        
    except Exception as e:
        print(f"\n💥 Критическая ошибка: {e}")
