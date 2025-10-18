#!/usr/bin/env python
"""
Система тренировки LLM для анализа халяльности и оценки компаний
"""

import os
import sys
import django
import json
import pandas as pd
from datetime import datetime
from typing import Dict, List, Tuple
import openai
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import numpy as np

# Настройка Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from broker_company.models import (
    CompanyAssessment, InterviewQuestion, InterviewResponse,
    HalalCertificate, Supplier, Ingredient, IngredientCategory
)


class HalalAnalysisLLM:
    """LLM система для анализа халяльности"""
    
    def __init__(self):
        self.api_key = os.getenv('OPENAI_API_KEY')
        openai.api_key = self.api_key
        self.model_name = "gpt-3.5-turbo"
        self.training_data = []
        self.evaluation_results = {}
    
    def collect_training_data(self):
        """Сбор данных для тренировки из базы данных"""
        print("Собираем данные для тренировки...")
        
        # Собираем данные оценок компаний
        assessments = CompanyAssessment.objects.all()
        for assessment in assessments:
            # Получаем ответы на вопросы интервью
            responses = InterviewResponse.objects.filter(assessment=assessment)
            
            training_example = {
                "company_name": assessment.company_name,
                "industry": assessment.industry,
                "country": assessment.country,
                "certification_score": assessment.certification_score,
                "production_score": assessment.production_score,
                "ingredients_score": assessment.ingredients_score,
                "logistics_score": assessment.logistics_score,
                "company_values_score": assessment.company_values_score,
                "overall_score": assessment.overall_score,
                "status": assessment.status,
                "interview_responses": [],
                "recommendations": assessment.recommendations
            }
            
            # Добавляем ответы на вопросы
            for response in responses:
                training_example["interview_responses"].append({
                    "question": response.question.question_text,
                    "question_category": response.question.category,
                    "answer": response.answer,
                    "score": response.score
                })
            
            self.training_data.append(training_example)
        
        print(f"Собрано {len(self.training_data)} примеров для тренировки")
        return self.training_data
    
    def prepare_training_prompts(self):
        """Подготовка промптов для тренировки"""
        print("Подготавливаем промпты для тренировки...")
        
        training_prompts = []
        
        for example in self.training_data:
            # Создаем системный промпт
            system_prompt = """Ты - эксперт по анализу халяльности и оценке компаний. 
            Твоя задача - анализировать данные компании и давать точные оценки по критериям халяльности.
            
            Критерии оценки (0-100 баллов):
            1. Сертификация - наличие и качество сертификатов халяльности
            2. Производство - соответствие производственных процессов исламским стандартам
            3. Ингредиенты - халяльность используемых ингредиентов
            4. Логистика - соблюдение халяльных стандартов при транспортировке и хранении
            5. Ценности компании - соответствие этическим принципам ислама
            
            Общая оценка рассчитывается как среднее арифметическое всех критериев."""
            
            # Создаем пользовательский промпт
            user_prompt = f"""
            Проанализируй компанию:
            Название: {example['company_name']}
            Отрасль: {example['industry']}
            Страна: {example['country']}
            
            Ответы на вопросы интервью:
            """
            
            for response in example['interview_responses']:
                user_prompt += f"""
            Вопрос ({response['question_category']}): {response['question']}
            Ответ: {response['answer']}
            """
            
            # Ожидаемый ответ
            expected_response = f"""
            Анализ компании {example['company_name']}:
            
            Оценки по критериям:
            - Сертификация: {example['certification_score']}/100
            - Производство: {example['production_score']}/100
            - Ингредиенты: {example['ingredients_score']}/100
            - Логистика: {example['logistics_score']}/100
            - Ценности компании: {example['company_values_score']}/100
            
            Общая оценка: {example['overall_score']}/100
            Статус: {example['status']}
            
            Рекомендации: {example['recommendations']}
            """
            
            training_prompts.append({
                "system": system_prompt,
                "user": user_prompt,
                "assistant": expected_response,
                "metadata": {
                    "company_name": example['company_name'],
                    "overall_score": example['overall_score'],
                    "status": example['status']
                }
            })
        
        print(f"Подготовлено {len(training_prompts)} промптов")
        return training_prompts
    
    def create_fine_tuning_dataset(self, training_prompts):
        """Создание датасета для fine-tuning"""
        print("Создаем датасет для fine-tuning...")
        
        # Разделяем данные на тренировочные и тестовые
        train_prompts, test_prompts = train_test_split(
            training_prompts, test_size=0.2, random_state=42
        )
        
        # Форматируем данные для OpenAI fine-tuning
        training_data = []
        for prompt in train_prompts:
            training_data.append({
                "messages": [
                    {"role": "system", "content": prompt["system"]},
                    {"role": "user", "content": prompt["user"]},
                    {"role": "assistant", "content": prompt["assistant"]}
                ]
            })
        
        # Сохраняем датасет
        with open('halal_training_data.jsonl', 'w', encoding='utf-8') as f:
            for item in training_data:
                f.write(json.dumps(item, ensure_ascii=False) + '\n')
        
        # Сохраняем тестовые данные
        with open('halal_test_data.jsonl', 'w', encoding='utf-8') as f:
            for prompt in test_prompts:
                f.write(json.dumps({
                    "messages": [
                        {"role": "system", "content": prompt["system"]},
                        {"role": "user", "content": prompt["user"]},
                        {"role": "assistant", "content": prompt["assistant"]}
                    ]
                }, ensure_ascii=False) + '\n')
        
        print(f"Создан датасет: {len(training_data)} тренировочных, {len(test_prompts)} тестовых примеров")
        return training_data, test_prompts
    
    def upload_training_file(self, file_path):
        """Загрузка файла для fine-tuning"""
        print(f"Загружаем файл {file_path}...")
        
        try:
            with open(file_path, 'rb') as f:
                response = openai.File.create(
                    file=f,
                    purpose='fine-tune'
                )
            
            file_id = response.id
            print(f"Файл загружен с ID: {file_id}")
            return file_id
            
        except Exception as e:
            print(f"Ошибка загрузки файла: {e}")
            return None
    
    def start_fine_tuning(self, file_id):
        """Запуск процесса fine-tuning"""
        print(f"Запускаем fine-tuning для файла {file_id}...")
        
        try:
            response = openai.FineTuningJob.create(
                training_file=file_id,
                model="gpt-3.5-turbo",
                hyperparameters={
                    "n_epochs": 3,
                    "batch_size": 1,
                    "learning_rate_multiplier": 1.0
                }
            )
            
            job_id = response.id
            print(f"Fine-tuning запущен с ID: {job_id}")
            return job_id
            
        except Exception as e:
            print(f"Ошибка запуска fine-tuning: {e}")
            return None
    
    def check_fine_tuning_status(self, job_id):
        """Проверка статуса fine-tuning"""
        try:
            response = openai.FineTuningJob.retrieve(job_id)
            status = response.status
            
            print(f"Статус fine-tuning: {status}")
            
            if status == "succeeded":
                model_id = response.fine_tuned_model
                print(f"Модель успешно обучена: {model_id}")
                return model_id
            elif status == "failed":
                print("Fine-tuning завершился с ошибкой")
                return None
            else:
                print("Fine-tuning еще выполняется...")
                return "in_progress"
                
        except Exception as e:
            print(f"Ошибка проверки статуса: {e}")
            return None
    
    def evaluate_model(self, model_id, test_prompts):
        """Оценка качества обученной модели"""
        print(f"Оцениваем модель {model_id}...")
        
        predictions = []
        actual_scores = []
        
        for prompt in test_prompts:
            try:
                # Получаем предсказание от модели
                response = openai.ChatCompletion.create(
                    model=model_id,
                    messages=[
                        {"role": "system", "content": prompt["system"]},
                        {"role": "user", "content": prompt["user"]}
                    ],
                    temperature=0.1,
                    max_tokens=1000
                )
                
                prediction = response.choices[0].message.content
                predictions.append(prediction)
                
                # Извлекаем ожидаемую оценку
                expected_score = prompt["metadata"]["overall_score"]
                actual_scores.append(expected_score)
                
            except Exception as e:
                print(f"Ошибка при получении предсказания: {e}")
                continue
        
        # Анализируем результаты
        self.evaluation_results = {
            "model_id": model_id,
            "total_predictions": len(predictions),
            "predictions": predictions,
            "actual_scores": actual_scores,
            "timestamp": datetime.now().isoformat()
        }
        
        print(f"Получено {len(predictions)} предсказаний")
        return self.evaluation_results
    
    def analyze_ingredient_halal_status(self, ingredient_name):
        """Анализ халяльности ингредиента"""
        try:
            # Ищем ингредиент в базе данных
            ingredient = Ingredient.objects.filter(name__icontains=ingredient_name).first()
            
            if ingredient:
                return {
                    "ingredient": ingredient.name,
                    "category": ingredient.category.get_type_display(),
                    "halal_status": ingredient.category.type,
                    "description": ingredient.description,
                    "halal_conditions": ingredient.halal_conditions,
                    "confidence": 0.95
                }
            
            # Если не найден в базе, используем LLM для анализа
            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - эксперт по халяльности ингредиентов. Определи статус ингредиента: halal (разрешен), haram (запрещен), mashbooh (сомнительный), halal_with_conditions (разрешен с условиями)."},
                    {"role": "user", "content": f"Проанализируй халяльность ингредиента: {ingredient_name}"}
                ],
                temperature=0.1
            )
            
            analysis = response.choices[0].message.content
            
            return {
                "ingredient": ingredient_name,
                "analysis": analysis,
                "confidence": 0.7,
                "source": "LLM_analysis"
            }
            
        except Exception as e:
            return {"error": f"Ошибка анализа: {e}"}
    
    def grade_company_compliance(self, company_data):
        """Оценка соответствия компании халяльным стандартам"""
        try:
            prompt = f"""
            Проанализируй компанию и дай оценку по критериям халяльности (0-100 баллов):
            
            Название: {company_data.get('name', 'Не указано')}
            Отрасль: {company_data.get('industry', 'Не указано')}
            Страна: {company_data.get('country', 'Не указано')}
            
            Данные о сертификации: {company_data.get('certification_info', 'Не указано')}
            Производственные процессы: {company_data.get('production_info', 'Не указано')}
            Используемые ингредиенты: {company_data.get('ingredients_info', 'Не указано')}
            Логистика: {company_data.get('logistics_info', 'Не указано')}
            Ценности компании: {company_data.get('values_info', 'Не указано')}
            
            Дай детальную оценку по каждому критерию и общую рекомендацию.
            """
            
            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - эксперт по оценке соответствия халяльным стандартам. Дай точную оценку по каждому критерию."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.1,
                max_tokens=1500
            )
            
            analysis = response.choices[0].message.content
            
            return {
                "company_name": company_data.get('name'),
                "analysis": analysis,
                "timestamp": datetime.now().isoformat(),
                "model_used": self.model_name
            }
            
        except Exception as e:
            return {"error": f"Ошибка оценки: {e}"}
    
    def generate_research_report(self, topic):
        """Генерация исследовательского отчета"""
        try:
            prompt = f"""
            Создай детальный исследовательский отчет на тему: {topic}
            
            Отчет должен включать:
            1. Введение и актуальность темы
            2. Анализ существующих стандартов халяльности
            3. Методология исследования
            4. Результаты и выводы
            5. Рекомендации
            6. Заключение
            
            Используй научный стиль изложения и ссылки на источники.
            """
            
            response = openai.ChatCompletion.create(
                model=self.model_name,
                messages=[
                    {"role": "system", "content": "Ты - исследователь в области халяльности. Создавай качественные научные отчеты."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=2000
            )
            
            report = response.choices[0].message.content
            
            return {
                "topic": topic,
                "report": report,
                "timestamp": datetime.now().isoformat(),
                "word_count": len(report.split())
            }
            
        except Exception as e:
            return {"error": f"Ошибка генерации отчета: {e}"}
    
    def save_model_results(self, results):
        """Сохранение результатов работы модели"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"halal_llm_results_{timestamp}.json"
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"Результаты сохранены в файл: {filename}")
        return filename


def main():
    """Основная функция для тренировки LLM"""
    print("🚀 Запускаем систему тренировки LLM для анализа халяльности...")
    
    # Создаем экземпляр системы
    llm_system = HalalAnalysisLLM()
    
    # Собираем данные
    training_data = llm_system.collect_training_data()
    
    if not training_data:
        print("❌ Нет данных для тренировки!")
        return
    
    # Подготавливаем промпты
    training_prompts = llm_system.prepare_training_prompts()
    
    # Создаем датасет
    train_data, test_data = llm_system.create_fine_tuning_dataset(training_prompts)
    
    print("✅ Система готова к тренировке!")
    print("📊 Статистика:")
    print(f"   - Тренировочных примеров: {len(train_data)}")
    print(f"   - Тестовых примеров: {len(test_data)}")
    print(f"   - Всего данных: {len(training_data)}")
    
    # Сохраняем результаты
    results = {
        "training_data_count": len(training_data),
        "training_prompts_count": len(training_prompts),
        "train_data_count": len(train_data),
        "test_data_count": len(test_data),
        "timestamp": datetime.now().isoformat()
    }
    
    llm_system.save_model_results(results)
    
    print("\n🎯 Следующие шаги:")
    print("1. Загрузите файл halal_training_data.jsonl в OpenAI")
    print("2. Запустите fine-tuning")
    print("3. Используйте обученную модель для анализа")


if __name__ == "__main__":
    main()
