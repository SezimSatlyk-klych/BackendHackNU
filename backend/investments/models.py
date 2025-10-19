from django.db import models
from broker_company.models import CompanyAssessment
from api.models import User


class Investment(models.Model):
    """Инвестиция пользователя в компанию из брокерского каталога."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='investments')
    company = models.ForeignKey(CompanyAssessment, on_delete=models.CASCADE, related_name='investments')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    note = models.TextField(blank=True, null=True)

    class Meta:
        verbose_name = 'Инвестиция'
        verbose_name_plural = 'Инвестиции'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user_id} -> {self.company_id}: {self.amount}"


class Donation(models.Model):
    """Пожертвование пользователя (например, на благотворительность)."""
    PURPOSES = [
        ('zakat', 'Закят'),
        ('sadaqah', 'Садака'),
        ('waqf', 'Вакф'),
        ('other', 'Другое'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='donations')
    purpose = models.CharField(max_length=20, choices=PURPOSES, default='other')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    note = models.TextField(blank=True, null=True)

    class Meta:
        verbose_name = 'Пожертвование'
        verbose_name_plural = 'Пожертвования'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user_id} {self.purpose}: {self.amount}"

# Create your models here.
