from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class CertificationBody(models.Model):
    """Органы сертификации халяльности"""
    name = models.CharField(max_length=200, verbose_name='Название организации')
    country = models.CharField(max_length=100, verbose_name='Страна')
    accreditation_number = models.CharField(max_length=100, unique=True, verbose_name='Номер аккредитации')
    website = models.URLField(blank=True, null=True, verbose_name='Веб-сайт')
    contact_email = models.EmailField(verbose_name='Email')
    is_active = models.BooleanField(default=True, verbose_name='Активен')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Орган сертификации'
        verbose_name_plural = 'Органы сертификации'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.country})"


class HalalCertificate(models.Model):
    """Сертификаты халяльности"""
    CERTIFICATE_STATUS = [
        ('active', 'Действующий'),
        ('expired', 'Истекший'),
        ('suspended', 'Приостановленный'),
        ('revoked', 'Отозванный'),
    ]
    
    certificate_number = models.CharField(max_length=100, unique=True, verbose_name='Номер сертификата')
    company_name = models.CharField(max_length=200, verbose_name='Название компании')
    product_name = models.CharField(max_length=200, verbose_name='Название продукта')
    certification_body = models.ForeignKey(CertificationBody, on_delete=models.CASCADE, verbose_name='Орган сертификации')
    issued_date = models.DateField(verbose_name='Дата выдачи')
    expiry_date = models.DateField(verbose_name='Дата истечения')
    status = models.CharField(max_length=20, choices=CERTIFICATE_STATUS, default='active', verbose_name='Статус')
    certificate_file = models.FileField(upload_to='certificates/', blank=True, null=True, verbose_name='Файл сертификата')
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Сертификат халяльности'
        verbose_name_plural = 'Сертификаты халяльности'
        ordering = ['-issued_date']
    
    def __str__(self):
        return f"{self.company_name} - {self.product_name} ({self.certificate_number})"


class IngredientCategory(models.Model):
    """Категории ингредиентов"""
    INGREDIENT_TYPE = [
        ('halal', 'Халяльный'),
        ('haram', 'Харам'),
        ('mashbooh', 'Сомнительный'),
        ('halal_with_conditions', 'Халяльный с условиями'),
    ]
    
    name = models.CharField(max_length=100, verbose_name='Название категории')
    type = models.CharField(max_length=30, choices=INGREDIENT_TYPE, verbose_name='Тип')
    description = models.TextField(verbose_name='Описание')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Категория ингредиентов'
        verbose_name_plural = 'Категории ингредиентов'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.get_type_display()})"


class Ingredient(models.Model):
    """Ингредиенты"""
    name = models.CharField(max_length=200, verbose_name='Название ингредиента')
    scientific_name = models.CharField(max_length=200, blank=True, null=True, verbose_name='Научное название')
    category = models.ForeignKey(IngredientCategory, on_delete=models.CASCADE, verbose_name='Категория')
    description = models.TextField(blank=True, null=True, verbose_name='Описание')
    common_sources = models.TextField(blank=True, null=True, verbose_name='Распространенные источники')
    halal_conditions = models.TextField(blank=True, null=True, verbose_name='Условия халяльности')
    is_active = models.BooleanField(default=True, verbose_name='Активен')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Ингредиент'
        verbose_name_plural = 'Ингредиенты'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.category.get_type_display()})"


class Supplier(models.Model):
    """Поставщики"""
    SUPPLIER_STATUS = [
        ('approved', 'Одобрен'),
        ('pending', 'На рассмотрении'),
        ('rejected', 'Отклонен'),
        ('suspended', 'Приостановлен'),
    ]
    
    name = models.CharField(max_length=200, verbose_name='Название компании')
    contact_person = models.CharField(max_length=100, verbose_name='Контактное лицо')
    email = models.EmailField(verbose_name='Email')
    phone = models.CharField(max_length=20, verbose_name='Телефон')
    address = models.TextField(verbose_name='Адрес')
    country = models.CharField(max_length=100, verbose_name='Страна')
    website = models.URLField(blank=True, null=True, verbose_name='Веб-сайт')
    halal_certificate = models.ForeignKey(HalalCertificate, on_delete=models.SET_NULL, blank=True, null=True, verbose_name='Сертификат халяльности')
    status = models.CharField(max_length=20, choices=SUPPLIER_STATUS, default='pending', verbose_name='Статус')
    halal_compliance_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка соответствия халяльности'
    )
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Поставщик'
        verbose_name_plural = 'Поставщики'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.get_status_display()})"


class ProductionProcess(models.Model):
    """Производственные процессы"""
    PROCESS_TYPE = [
        ('manufacturing', 'Производство'),
        ('packaging', 'Упаковка'),
        ('storage', 'Хранение'),
        ('transportation', 'Транспортировка'),
        ('quality_control', 'Контроль качества'),
    ]
    
    name = models.CharField(max_length=200, verbose_name='Название процесса')
    process_type = models.CharField(max_length=30, choices=PROCESS_TYPE, verbose_name='Тип процесса')
    description = models.TextField(verbose_name='Описание процесса')
    equipment_used = models.TextField(verbose_name='Используемое оборудование')
    halal_compliance_measures = models.TextField(verbose_name='Меры обеспечения халяльности')
    potential_risks = models.TextField(blank=True, null=True, verbose_name='Потенциальные риски')
    mitigation_strategies = models.TextField(blank=True, null=True, verbose_name='Стратегии снижения рисков')
    is_active = models.BooleanField(default=True, verbose_name='Активен')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Производственный процесс'
        verbose_name_plural = 'Производственные процессы'
        ordering = ['name']
    
    def __str__(self):
        return f"{self.name} ({self.get_process_type_display()})"


class CompanyAssessment(models.Model):
    """Оценка компании"""
    ASSESSMENT_STATUS = [
        ('pending', 'На рассмотрении'),
        ('in_progress', 'В процессе'),
        ('completed', 'Завершена'),
        ('failed', 'Не пройдена'),
    ]
    
    company_name = models.CharField(max_length=200, verbose_name='Название компании')
    contact_person = models.CharField(max_length=100, verbose_name='Контактное лицо')
    email = models.EmailField(verbose_name='Email')
    phone = models.CharField(max_length=20, verbose_name='Телефон')
    industry = models.CharField(max_length=100, verbose_name='Отрасль')
    country = models.CharField(max_length=100, verbose_name='Страна')
    website = models.URLField(blank=True, null=True, verbose_name='Веб-сайт')
    
    # Оценки по критериям (0-100)
    certification_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка сертификации'
    )
    production_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка производства'
    )
    ingredients_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка ингредиентов'
    )
    logistics_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка логистики'
    )
    company_values_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка ценностей компании'
    )
    
    overall_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Общая оценка'
    )
    
    status = models.CharField(max_length=20, choices=ASSESSMENT_STATUS, default='pending', verbose_name='Статус')
    assessment_date = models.DateField(blank=True, null=True, verbose_name='Дата оценки')
    assessor_name = models.CharField(max_length=100, blank=True, null=True, verbose_name='Оценщик')
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    recommendations = models.TextField(blank=True, null=True, verbose_name='Рекомендации')
    
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Оценка компании'
        verbose_name_plural = 'Оценки компаний'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.company_name} - {self.get_status_display()} ({self.overall_score}%)"


class InterviewQuestion(models.Model):
    """Вопросы для интервью"""
    QUESTION_CATEGORY = [
        ('certification', 'Сертификация'),
        ('production', 'Производство'),
        ('ingredients', 'Ингредиенты'),
        ('logistics', 'Логистика'),
        ('company_values', 'Ценности компании'),
        ('general', 'Общие вопросы'),
    ]
    
    QUESTION_TYPE = [
        ('multiple_choice', 'Множественный выбор'),
        ('yes_no', 'Да/Нет'),
        ('text', 'Текстовый ответ'),
        ('rating', 'Оценка по шкале'),
    ]
    
    category = models.CharField(max_length=30, choices=QUESTION_CATEGORY, verbose_name='Категория')
    question_type = models.CharField(max_length=20, choices=QUESTION_TYPE, verbose_name='Тип вопроса')
    question_text = models.TextField(verbose_name='Текст вопроса')
    options = models.JSONField(blank=True, null=True, verbose_name='Варианты ответов')
    weight = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(10)],
        default=1,
        verbose_name='Вес вопроса'
    )
    is_active = models.BooleanField(default=True, verbose_name='Активен')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Вопрос интервью'
        verbose_name_plural = 'Вопросы интервью'
        ordering = ['category', 'weight']
    
    def __str__(self):
        return f"{self.get_category_display()}: {self.question_text[:50]}..."


class InterviewResponse(models.Model):
    """Ответы на вопросы интервью"""
    assessment = models.ForeignKey(CompanyAssessment, on_delete=models.CASCADE, verbose_name='Оценка компании')
    question = models.ForeignKey(InterviewQuestion, on_delete=models.CASCADE, verbose_name='Вопрос')
    answer = models.TextField(verbose_name='Ответ')
    score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка ответа'
    )
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    
    class Meta:
        verbose_name = 'Ответ на вопрос'
        verbose_name_plural = 'Ответы на вопросы'
        unique_together = ['assessment', 'question']
        ordering = ['question__category', 'question__weight']
    
    def __str__(self):
        return f"{self.assessment.company_name} - {self.question.get_category_display()}"


class ComplianceAudit(models.Model):
    """Аудит соответствия"""
    AUDIT_STATUS = [
        ('scheduled', 'Запланирован'),
        ('in_progress', 'В процессе'),
        ('completed', 'Завершен'),
        ('failed', 'Не пройден'),
    ]
    
    AUDIT_TYPE = [
        ('initial', 'Первичный'),
        ('periodic', 'Периодический'),
        ('follow_up', 'Повторный'),
        ('surprise', 'Внеплановый'),
    ]
    
    company_assessment = models.ForeignKey(CompanyAssessment, on_delete=models.CASCADE, verbose_name='Оценка компании')
    audit_type = models.CharField(max_length=20, choices=AUDIT_TYPE, verbose_name='Тип аудита')
    scheduled_date = models.DateField(verbose_name='Запланированная дата')
    actual_date = models.DateField(blank=True, null=True, verbose_name='Фактическая дата')
    auditor_name = models.CharField(max_length=100, verbose_name='Аудитор')
    status = models.CharField(max_length=20, choices=AUDIT_STATUS, default='scheduled', verbose_name='Статус')
    
    # Результаты аудита
    compliance_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        verbose_name='Оценка соответствия'
    )
    non_compliances = models.TextField(blank=True, null=True, verbose_name='Несоответствия')
    corrective_actions = models.TextField(blank=True, null=True, verbose_name='Корректирующие действия')
    next_audit_date = models.DateField(blank=True, null=True, verbose_name='Дата следующего аудита')
    
    audit_report = models.FileField(upload_to='audit_reports/', blank=True, null=True, verbose_name='Отчет об аудите')
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Аудит соответствия'
        verbose_name_plural = 'Аудиты соответствия'
        ordering = ['-scheduled_date']
    
    def __str__(self):
        return f"{self.company_assessment.company_name} - {self.get_audit_type_display()} ({self.scheduled_date})"


class Partnership(models.Model):
    """Партнерские отношения"""
    PARTNERSHIP_STATUS = [
        ('proposed', 'Предложено'),
        ('negotiating', 'Переговоры'),
        ('active', 'Активное'),
        ('suspended', 'Приостановлено'),
        ('terminated', 'Завершено'),
    ]
    
    PARTNERSHIP_TYPE = [
        ('supplier', 'Поставщик'),
        ('distributor', 'Дистрибьютор'),
        ('manufacturer', 'Производитель'),
        ('service_provider', 'Поставщик услуг'),
    ]
    
    company_assessment = models.ForeignKey(CompanyAssessment, on_delete=models.CASCADE, verbose_name='Оценка компании')
    partnership_type = models.CharField(max_length=30, choices=PARTNERSHIP_TYPE, verbose_name='Тип партнерства')
    status = models.CharField(max_length=20, choices=PARTNERSHIP_STATUS, default='proposed', verbose_name='Статус')
    
    start_date = models.DateField(blank=True, null=True, verbose_name='Дата начала')
    end_date = models.DateField(blank=True, null=True, verbose_name='Дата окончания')
    contract_value = models.DecimalField(max_digits=15, decimal_places=2, blank=True, null=True, verbose_name='Стоимость контракта')
    
    terms_and_conditions = models.TextField(blank=True, null=True, verbose_name='Условия и положения')
    halal_requirements = models.TextField(verbose_name='Требования халяльности')
    monitoring_frequency = models.CharField(max_length=50, verbose_name='Частота мониторинга')
    
    contact_person = models.CharField(max_length=100, verbose_name='Контактное лицо')
    contact_email = models.EmailField(verbose_name='Email')
    contact_phone = models.CharField(max_length=20, verbose_name='Телефон')
    
    notes = models.TextField(blank=True, null=True, verbose_name='Примечания')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')
    
    class Meta:
        verbose_name = 'Партнерство'
        verbose_name_plural = 'Партнерства'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.company_assessment.company_name} - {self.get_partnership_type_display()} ({self.get_status_display()})"