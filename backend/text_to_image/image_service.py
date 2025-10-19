import openai
import os
import requests
from typing import Dict, Optional
from django.conf import settings
from .models import ImageGeneration


class ImageGenerationService:
    def __init__(self):
        """Инициализация сервиса генерации изображений"""
        self.api_key = os.getenv('OPENAI_API_KEY')
        openai.api_key = self.api_key
    
    def generate_image(self, prompt: str) -> Dict:
        """
        Генерирует комикс-стрип по текстовому описанию
        
        Args:
            prompt (str): Описание для создания комикса
            
        Returns:
            Dict: Результат генерации с URL изображения или ошибкой
        """
        try:
            # Проверяем наличие API ключа
            if not self.api_key:
                return {
                    "success": False,
                    "error": "OpenAI API key not configured",
                    "prompt": prompt
                }
            
            # Создаем упрощенный промпт для комикса
            comic_prompt = f"Comic strip with 6 panels (2 rows x 3 columns) showing: {prompt}. Comic book style, bold outlines, vibrant colors, speech bubbles, sequential storytelling"
            
            print(f"🎨 Generating comic with prompt: {comic_prompt[:100]}...")
            
            # Используем DALL-E для генерации комикса
            response = openai.Image.create(
                prompt=comic_prompt,
                n=1,  # Количество изображений
                size="1024x1024",  # Размер изображения
                response_format="url"  # Получить URL
            )
            
            # Получаем URL изображения
            image_url = response['data'][0]['url']
            print(f"✅ Comic generated successfully: {image_url}")
            
            return {
                "success": True,
                "image_url": image_url,
                "prompt": prompt,
                "comic_prompt": comic_prompt
            }
            
        except Exception as e:
            error_msg = f"Ошибка генерации комикса: {str(e)}"
            print(f"❌ Comic generation failed: {error_msg}")
            return {
                "success": False,
                "error": error_msg,
                "prompt": prompt
            }
    
    def process_generation_request(self, generation_id: int) -> bool:
        """
        Обрабатывает запрос на генерацию комикса
        
        Args:
            generation_id (int): ID записи ImageGeneration
            
        Returns:
            bool: True если успешно, False если ошибка
        """
        try:
            # Получаем запись из базы
            generation = ImageGeneration.objects.get(id=generation_id)
            
            # Обновляем статус на "processing"
            generation.status = 'processing'
            generation.save()
            
            # Генерируем комикс
            print(f"🎨 Starting comic generation for prompt: {generation.prompt[:50]}...")
            result = self.generate_image(generation.prompt)
            
            if result["success"]:
                # Обновляем запись с результатом
                generation.image_url = result["image_url"]
                generation.status = 'completed'
                generation.save()
                print(f"✅ Comic generation completed for ID {generation_id}")
                return True
            else:
                # Обновляем статус на ошибку
                generation.status = 'failed'
                generation.save()
                print(f"❌ Comic generation failed for ID {generation_id}: {result.get('error', 'Unknown error')}")
                return False
                
        except ImageGeneration.DoesNotExist:
            return False
        except Exception as e:
            # Обновляем статус на ошибку
            try:
                generation = ImageGeneration.objects.get(id=generation_id)
                generation.status = 'failed'
                generation.save()
            except:
                pass
            return False


# Функция для простого использования
def generate_comic_from_text(prompt: str) -> str:
    """
    Простая функция для генерации комикса
    
    Args:
        prompt (str): Описание для создания комикса
        
    Returns:
        str: URL комикса или сообщение об ошибке
    """
    service = ImageGenerationService()
    result = service.generate_image(prompt)
    
    if result["success"]:
        return result["image_url"]
    else:
        return f"Ошибка генерации комикса: {result['error']}"


# Пример использования
if __name__ == "__main__":
    # Создаем экземпляр сервиса
    comic_service = ImageGenerationService()
    
    # Генерируем комикс
    result = comic_service.generate_image("A superhero saving the city from a monster")
    print("Результат:", result)
    
    # Использование простой функции
    url = generate_comic_from_text("A funny story about a robot learning to cook")
    print("URL комикса:", url)
