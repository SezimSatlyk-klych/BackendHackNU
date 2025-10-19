import openai
import os
from typing import Dict, Optional
from api.models import User, TransactionFrom, TransactionTo, Finance, Goal, Savings


class AIChatService:
    def __init__(self):
        """Инициализация AI чат сервиса"""
        self.api_key = os.getenv('OPENAI_API_KEY')
        openai.api_key = self.api_key
    
    def get_project_data_summary(self) -> str:
        """Получает сводку всех данных проекта"""
        try:
            # Получаем все данные
            users = list(User.objects.all())
            transactions_from = list(TransactionFrom.objects.all())
            transactions_to = list(TransactionTo.objects.all())
            finance_records = list(Finance.objects.all())
            goals = list(Goal.objects.all())
            savings = list(Savings.objects.all())
            
            # Подсчитываем общие суммы
            total_from = sum(t.sum for t in transactions_from)
            total_to = sum(t.sum for t in transactions_to)
            total_savings = sum(s.sum for s in savings)
            
            summary = f"""
ДАННЫЕ ПРОЕКТА HACKNU:

ПОЛЬЗОВАТЕЛИ ({len(users)}):
"""
            for user in users:
                summary += f"- {user.name} {user.surname} ({user.type}): {user.email}\n"
            
            summary += f"""
ТРАНЗАКЦИИ:
- Исходящие транзакции ({len(transactions_from)}): общая сумма {total_from}
"""
            for trans in transactions_from:
                summary += f"  * {trans.sum} - {trans.type}\n"
            
            summary += f"""
- Входящие транзакции ({len(transactions_to)}): общая сумма {total_to}
"""
            for trans in transactions_to:
                summary += f"  * {trans.sum} - {trans.type}\n"
            
            summary += f"""
ФИНАНСЫ ({len(finance_records)} записей):
"""
            for finance in finance_records:
                summary += f"- Текущее состояние: {finance.current_state}\n"
            
            summary += f"""
ЦЕЛИ ({len(goals)}):
"""
            for goal in goals:
                summary += f"- {goal.goal_desc} (цель: {goal.goal_sum}, прогресс: {goal.goal_progress}%)\n"
            
            summary += f"""
НАКОПЛЕНИЯ ({len(savings)}): общая сумма {total_savings}
"""
            for saving in savings:
                summary += f"- {saving.sum} для цели '{saving.goal.goal_desc[:30]}...'\n"
            
            summary += f"""
ИТОГО:
- Общий доход: {total_from}
- Общие расходы: {total_to}
- Общие накопления: {total_savings}
- Баланс: {total_from - total_to}
"""
            
            return summary
            
        except Exception as e:
            return f"Ошибка получения данных: {str(e)}"
    
    def ask_question(self, question: str, context: Optional[str] = None) -> Dict:
        """
        Отвечает на вопросы пользователя через ИИ, анализируя данные проекта
        
        Args:
            question (str): Вопрос пользователя
            context (str, optional): Дополнительный контекст для ответа
            
        Returns:
            Dict: Ответ ИИ с текстом и статусом
        """
        try:
            # Получаем данные проекта
            project_data = self.get_project_data_summary()
            
            # Подготовка системного промпта
            system_prompt = f"""Ты - умный AI ассистент для финансового приложения HackNU. 
Ты можешь анализировать данные пользователей, их финансовые цели, транзакции и накопления.

ДАННЫЕ ПРОЕКТА:
{project_data}

Отвечай на вопросы пользователя на русском языке. Будь дружелюбным, информативным и точным.
Можешь давать советы по финансам, анализировать прогресс целей, предлагать улучшения."""
            
            # Если есть контекст, добавляем его к промпту
            if context:
                system_prompt += f"\n\nДополнительный контекст: {context}"
            
            # Отправка запроса к OpenAI
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
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
                "model": "gpt-3.5-turbo"
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

