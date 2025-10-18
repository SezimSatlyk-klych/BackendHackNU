import openai
import os
from typing import Dict, Optional

class AIChatService:
    def __init__(self):
        """Инициализация AI чат сервиса"""
        self.api_key = os.getenv('OPENAI_API_KEY')
        self.client = openai.OpenAI(api_key=self.api_key)
    
    def ask_question(self, question: str, context: Optional[str] = None) -> Dict:
        """
        Отвечает на вопросы пользователя через ИИ
        
        Args:
            question (str): Вопрос пользователя
            context (str, optional): Дополнительный контекст для ответа
            
        Returns:
            Dict: Ответ ИИ с текстом и статусом
        """
        try:
            # Подготовка системного промпта
            system_prompt = "Ты - полезный AI ассистент. Отвечай на вопросы пользователя на русском языке. Будь дружелюбным, информативным и точным."
            
            # Если есть контекст, добавляем его к промпту
            if context:
                system_prompt += f"\n\nКонтекст: {context}"
            
            # Отправка запроса к OpenAI
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {
                        "role": "system",
                        "content": system_prompt
                    },
                    {
                        "role": "user",
                        "content": question
                    }
                ],
                temperature=0.7,
                max_tokens=1000
            )
            
            # Получение ответа
            ai_response = response.choices[0].message.content
            
            return {
                "success": True,
                "answer": ai_response,
                "question": question,
                "model": "gpt-4"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка при обработке вопроса: {str(e)}",
                "question": question
            }
    

# Функция для простого использования
def ask_ai(question: str, context: Optional[str] = None) -> str:
    """
    Простая функция для получения ответа от ИИ
    
    Args:
        question (str): Вопрос пользователя
        context (str, optional): Дополнительный контекст
        
    Returns:
        str: Ответ ИИ или сообщение об ошибке
    """
    ai_service = AIChatService()
    result = ai_service.ask_question(question, context)
    
    if result["success"]:
        return result["answer"]
    else:
        return f"Ошибка: {result['error']}"

# Пример использования
if __name__ == "__main__":
    # Создаем экземпляр сервиса
    ai_chat = AIChatService()
    
    # Простой вопрос
    result = ai_chat.ask_question("Привет! Как дела?")
    print("Ответ:", result["answer"] if result["success"] else result["error"])
    
    # Вопрос с контекстом
    result = ai_chat.ask_question(
        "Что такое машинное обучение?", 
        context="Пользователь изучает программирование"
    )
    print("Ответ с контекстом:", result["answer"] if result["success"] else result["error"])
    
    # Использование простой функции
    answer = ask_ai("Расскажи про Python")
    print("Простой ответ:", answer)
