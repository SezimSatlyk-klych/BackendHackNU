from django.db import models


class ImageGeneration(models.Model):
    STATUS_CHOICES = [
        ('pending', 'В обработке'),
        ('completed', 'Завершено'),
        ('failed', 'Ошибка'),
    ]
    
    prompt = models.TextField(verbose_name='Описание для комикса')
    image_url = models.URLField(blank=True, null=True, verbose_name='URL комикса')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name='Статус')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Генерация комикса'
        verbose_name_plural = 'Генерации комиксов'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Comic: {self.prompt[:50]}..."