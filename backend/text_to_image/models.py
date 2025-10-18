from django.db import models


class ImageGeneration(models.Model):
    STATUS_CHOICES = [
        ('pending', 'В обработке'),
        ('completed', 'Завершено'),
        ('failed', 'Ошибка'),
    ]
    
    prompt = models.TextField(verbose_name='Текст для генерации')
    image_url = models.URLField(blank=True, null=True, verbose_name='URL изображения')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name='Статус')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Генерация изображения'
        verbose_name_plural = 'Генерации изображений'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Image: {self.prompt[:50]}..."