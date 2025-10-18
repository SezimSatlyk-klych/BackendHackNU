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
        Генерирует изображение по текстовому описанию в стиле комикса
        
        Args:
            prompt (str): Описание изображения
            
        Returns:
            Dict: Результат генерации с URL изображения или ошибкой
        """
        try:
            # Добавляем стиль комикса с 6 панелями к промпту
            comic_prompt = f"{prompt}, comic strip with 6 panels arranged in 2 rows and 3 columns, comic book style, vibrant colors, bold outlines, dynamic composition, speech bubbles, sequential storytelling, detailed illustration, classic comic layout"
            
            # Используем DALL-E для генерации изображения
            response = openai.Image.create(
                prompt=comic_prompt,
                n=1,  # Количество изображений
                size="1024x1024",  # Размер изображения
                response_format="url"  # Получить URL
            )
            
            # Получаем URL изображения
            image_url = response['data'][0]['url']
            
            return {
                "success": True,
                "image_url": image_url,
                "prompt": prompt,
                "comic_prompt": comic_prompt
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка генерации изображения: {str(e)}",
                "prompt": prompt
            }
    
    def process_generation_request(self, generation_id: int) -> bool:
        """
        Обрабатывает запрос на генерацию изображения
        
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
            
            # Генерируем изображение
            result = self.generate_image(generation.prompt)
            
            if result["success"]:
                # Обновляем запись с результатом
                generation.image_url = result["image_url"]
                generation.status = 'completed'
                generation.save()
                return True
            else:
                # Обновляем статус на ошибку
                generation.status = 'failed'
                generation.save()
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
def generate_image_from_text(prompt: str) -> str:
    """
    Простая функция для генерации изображения
    
    Args:
        prompt (str): Описание изображения
        
    Returns:
        str: URL изображения или сообщение об ошибке
    """
    service = ImageGenerationService()
    result = service.generate_image(prompt)
    
    if result["success"]:
        return result["image_url"]
    else:
        return f"Ошибка: {result['error']}"


# Пример использования
if __name__ == "__main__":
    # Создаем экземпляр сервиса
    image_service = ImageGenerationService()
    
    # Генерируем изображение
    result = image_service.generate_image("A beautiful sunset over mountains")
    print("Результат:", result)
    
    # Использование простой функции
    url = generate_image_from_text("A cute cat")
    print("URL изображения:", url)
