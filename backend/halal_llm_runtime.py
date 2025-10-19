import os
from datetime import datetime
from typing import Dict, Optional
import openai

from broker_company.models import Ingredient


class HalalRuntimeLLM:
    """Легковесный LLM-рантайм без pandas/sklearn. Только вызовы OpenAI."""

    def __init__(self, model_name: str = "gpt-3.5-turbo"):
        self.api_key = os.getenv('OPENAI_API_KEY')
        openai.api_key = self.api_key
        self.model_name = model_name

    def analyze_ingredient_halal_status(self, ingredient_name: str) -> Dict:
        """Анализ халяльности ингредиента: сначала из БД, затем LLM."""
        try:
            ing = Ingredient.objects.filter(name__icontains=ingredient_name).first()
            if ing:
                return {
                    "ingredient": ing.name,
                    "category": ing.category.get_type_display(),
                    "halal_status": ing.category.type,
                    "description": ing.description,
                    "halal_conditions": ing.halal_conditions,
                    "confidence": 0.95,
                    "source": "database"
                }

            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - эксперт по халяльности ингредиентов. Классифицируй: halal, haram, mashbooh, halal_with_conditions."},
                    {"role": "user", "content": f"Определи халяль-статус ингредиента: {ingredient_name}"}
                ],
                temperature=0.1,
                max_tokens=600
            )
            analysis = response.choices[0].message.content
            return {
                "ingredient": ingredient_name,
                "analysis": analysis,
                "confidence": 0.7,
                "source": "llm"
            }
        except Exception as e:
            return {"error": f"Ошибка анализа: {e}"}

    def grade_company_compliance(self, company_data: Dict) -> Dict:
        """LLM-оценка соответствия компании халяльным стандартам."""
        try:
            prompt = f"""
            Проанализируй компанию и дай оценку по критериям халяльности (0-100):
            Название: {company_data.get('name')}
            Отрасль: {company_data.get('industry')}
            Страна: {company_data.get('country')}
            Сертификация: {company_data.get('certification_info')}
            Производство: {company_data.get('production_info')}
            Ингредиенты: {company_data.get('ingredients_info')}
            Логистика: {company_data.get('logistics_info')}
            Ценности: {company_data.get('values_info')}
            Выведи оценки по каждому критерию, общую оценку и рекомендации.
            """
            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - эксперт по халяль-аудиту. Дай точные численные оценки и рекомендации."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.2,
                max_tokens=1200
            )
            analysis = response.choices[0].message.content
            return {
                "company_name": company_data.get('name'),
                "analysis": analysis,
                "timestamp": datetime.now().isoformat(),
                "model_used": self.model_name,
                "source": "llm"
            }
        except Exception as e:
            return {"error": f"Ошибка оценки: {e}"}

    def generate_research_report(self, topic: str) -> Dict:
        try:
            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - исследователь. Формируй структурированные отчёты с чёткими разделами."},
                    {"role": "user", "content": f"Сформируй отчёт на тему: {topic}"}
                ],
                temperature=0.3,
                max_tokens=1800
            )
            report = response.choices[0].message.content
            return {
                "topic": topic,
                "report": report,
                "timestamp": datetime.now().isoformat(),
                "word_count": len(report.split()),
                "source": "llm"
            }
        except Exception as e:
            return {"error": f"Ошибка генерации отчёта: {e}"}


