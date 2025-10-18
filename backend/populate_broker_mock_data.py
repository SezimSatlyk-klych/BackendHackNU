#!/usr/bin/env python
"""
Скрипт для создания мок данных для брокерской компании
Генерирует 20 записей для каждой модели
"""

import os
import sys
import django
from datetime import datetime, date, timedelta
from decimal import Decimal
import random

# Настройка Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from broker_company.models import (
    CertificationBody, HalalCertificate, IngredientCategory, Ingredient,
    Supplier, ProductionProcess, CompanyAssessment, InterviewQuestion,
    InterviewResponse, ComplianceAudit, Partnership
)


def create_certification_bodies():
    """Создание органов сертификации"""
    bodies_data = [
        {"name": "Исламский центр сертификации Казахстана", "country": "Казахстан", "accreditation_number": "KZ-001-2024", "contact_email": "info@halal-kz.kz"},
        {"name": "Международный центр халяль", "country": "ОАЭ", "accreditation_number": "UAE-002-2024", "contact_email": "cert@halal-uae.ae"},
        {"name": "Центр исламских стандартов Турции", "country": "Турция", "accreditation_number": "TR-003-2024", "contact_email": "standards@halal-tr.tr"},
        {"name": "Малайзийский институт халяль", "country": "Малайзия", "accreditation_number": "MY-004-2024", "contact_email": "institute@halal-my.my"},
        {"name": "Саудовский центр сертификации", "country": "Саудовская Аравия", "accreditation_number": "SA-005-2024", "contact_email": "cert@halal-sa.sa"},
        {"name": "Индонезийский совет халяль", "country": "Индонезия", "accreditation_number": "ID-006-2024", "contact_email": "council@halal-id.id"},
        {"name": "Пакистанский центр сертификации", "country": "Пакистан", "accreditation_number": "PK-007-2024", "contact_email": "center@halal-pk.pk"},
        {"name": "Бангладешский институт халяль", "country": "Бангладеш", "accreditation_number": "BD-008-2024", "contact_email": "institute@halal-bd.bd"},
        {"name": "Египетский центр стандартов", "country": "Египет", "accreditation_number": "EG-009-2024", "contact_email": "standards@halal-eg.eg"},
        {"name": "Марокканский институт халяль", "country": "Марокко", "accreditation_number": "MA-010-2024", "contact_email": "institute@halal-ma.ma"},
        {"name": "Тунисский центр сертификации", "country": "Тунис", "accreditation_number": "TN-011-2024", "contact_email": "cert@halal-tn.tn"},
        {"name": "Алжирский совет халяль", "country": "Алжир", "accreditation_number": "DZ-012-2024", "contact_email": "council@halal-dz.dz"},
        {"name": "Ливийский центр стандартов", "country": "Ливия", "accreditation_number": "LY-013-2024", "contact_email": "standards@halal-ly.ly"},
        {"name": "Суданский институт халяль", "country": "Судан", "accreditation_number": "SD-014-2024", "contact_email": "institute@halal-sd.sd"},
        {"name": "Иорданский центр сертификации", "country": "Иордания", "accreditation_number": "JO-015-2024", "contact_email": "cert@halal-jo.jo"},
        {"name": "Ливанский совет халяль", "country": "Ливан", "accreditation_number": "LB-016-2024", "contact_email": "council@halal-lb.lb"},
        {"name": "Сирийский институт халяль", "country": "Сирия", "accreditation_number": "SY-017-2024", "contact_email": "institute@halal-sy.sy"},
        {"name": "Иракский центр стандартов", "country": "Ирак", "accreditation_number": "IQ-018-2024", "contact_email": "standards@halal-iq.iq"},
        {"name": "Иранский совет халяль", "country": "Иран", "accreditation_number": "IR-019-2024", "contact_email": "council@halal-ir.ir"},
        {"name": "Афганский центр сертификации", "country": "Афганистан", "accreditation_number": "AF-020-2024", "contact_email": "cert@halal-af.af"},
    ]
    
    for data in bodies_data:
        CertificationBody.objects.create(**data)
    print(f"Создано {len(bodies_data)} органов сертификации")


def create_ingredient_categories():
    """Создание категорий ингредиентов"""
    categories_data = [
        {"name": "Мясо халяль", "type": "halal", "description": "Мясо животных, зарезанных по исламским традициям"},
        {"name": "Свинина", "type": "haram", "description": "Мясо свиньи - запрещено в исламе"},
        {"name": "Алкоголь", "type": "haram", "description": "Любые алкогольные напитки и ингредиенты"},
        {"name": "Желатин животный", "type": "mashbooh", "description": "Желатин может быть халяльным или харам в зависимости от источника"},
        {"name": "Эмульгаторы", "type": "halal_with_conditions", "description": "Эмульгаторы халяльны при соблюдении определенных условий"},
        {"name": "Консерванты", "type": "halal_with_conditions", "description": "Консерванты разрешены при соблюдении халяльных стандартов"},
        {"name": "Красители", "type": "halal_with_conditions", "description": "Красители халяльны если не содержат запрещенных веществ"},
        {"name": "Ароматизаторы", "type": "mashbooh", "description": "Ароматизаторы требуют проверки источника"},
        {"name": "Ферменты", "type": "mashbooh", "description": "Ферменты могут быть получены из халяльных или харам источников"},
        {"name": "Молочные продукты", "type": "halal", "description": "Молочные продукты от халяльных животных"},
        {"name": "Рыба", "type": "halal", "description": "Рыба разрешена в исламе"},
        {"name": "Овощи", "type": "halal", "description": "Овощи разрешены"},
        {"name": "Фрукты", "type": "halal", "description": "Фрукты разрешены"},
        {"name": "Зерновые", "type": "halal", "description": "Зерновые культуры разрешены"},
        {"name": "Масла растительные", "type": "halal", "description": "Растительные масла разрешены"},
        {"name": "Специи", "type": "halal", "description": "Натуральные специи разрешены"},
        {"name": "Сахар", "type": "halal", "description": "Сахар разрешен"},
        {"name": "Соль", "type": "halal", "description": "Соль разрешена"},
        {"name": "Дрожжи", "type": "halal", "description": "Дрожжи разрешены"},
        {"name": "Крахмал", "type": "halal", "description": "Крахмал разрешен"},
    ]
    
    for data in categories_data:
        IngredientCategory.objects.create(**data)
    print(f"Создано {len(categories_data)} категорий ингредиентов")


def create_ingredients():
    """Создание ингредиентов"""
    categories = list(IngredientCategory.objects.all())
    
    ingredients_data = [
        {"name": "Говядина халяль", "scientific_name": "Bos taurus", "category": categories[0], "description": "Мясо крупного рогатого скота", "common_sources": "Фермы Казахстана, России", "halal_conditions": "Зарезана по исламским традициям"},
        {"name": "Баранина халяль", "scientific_name": "Ovis aries", "category": categories[0], "description": "Мясо овец", "common_sources": "Пастбища Центральной Азии", "halal_conditions": "Зарезана по исламским традициям"},
        {"name": "Курица халяль", "scientific_name": "Gallus gallus", "category": categories[0], "description": "Мясо домашней птицы", "common_sources": "Птицефермы", "halal_conditions": "Зарезана по исламским традициям"},
        {"name": "Свинина", "scientific_name": "Sus scrofa", "category": categories[1], "description": "Мясо свиньи", "common_sources": "Свинофермы", "halal_conditions": "Запрещено в исламе"},
        {"name": "Этиловый спирт", "scientific_name": "C2H5OH", "category": categories[2], "description": "Алкоголь", "common_sources": "Дистилляция", "halal_conditions": "Запрещен в исламе"},
        {"name": "Желатин говяжий", "scientific_name": "Gelatin", "category": categories[3], "description": "Желатин из говядины", "common_sources": "Кости крупного рогатого скота", "halal_conditions": "Должен быть из халяльного мяса"},
        {"name": "Лецитин соевый", "scientific_name": "Lecithin", "category": categories[4], "description": "Эмульгатор из сои", "common_sources": "Соевые бобы", "halal_conditions": "Разрешен если соя халяльная"},
        {"name": "Бензоат натрия", "scientific_name": "C7H5NaO2", "category": categories[5], "description": "Консервант", "common_sources": "Химический синтез", "halal_conditions": "Разрешен"},
        {"name": "Кармин", "scientific_name": "E120", "category": categories[6], "description": "Красный краситель", "common_sources": "Насекомые кошениль", "halal_conditions": "Разрешен"},
        {"name": "Ванилин", "scientific_name": "C8H8O3", "category": categories[7], "description": "Ароматизатор", "common_sources": "Ваниль или синтез", "halal_conditions": "Требует проверки источника"},
        {"name": "Пепсин", "scientific_name": "Enzyme", "category": categories[8], "description": "Фермент", "common_sources": "Желудки животных", "halal_conditions": "Должен быть из халяльных животных"},
        {"name": "Молоко коровье", "scientific_name": "Milk", "category": categories[9], "description": "Молочный продукт", "common_sources": "Коровы", "halal_conditions": "От халяльных животных"},
        {"name": "Лосось", "scientific_name": "Salmo salar", "category": categories[10], "description": "Рыба", "common_sources": "Северные моря", "halal_conditions": "Разрешена"},
        {"name": "Морковь", "scientific_name": "Daucus carota", "category": categories[11], "description": "Овощ", "common_sources": "Огороды", "halal_conditions": "Разрешена"},
        {"name": "Яблоко", "scientific_name": "Malus domestica", "category": categories[12], "description": "Фрукт", "common_sources": "Сады", "halal_conditions": "Разрешено"},
        {"name": "Пшеница", "scientific_name": "Triticum", "category": categories[13], "description": "Зерновая культура", "common_sources": "Поля", "halal_conditions": "Разрешена"},
        {"name": "Подсолнечное масло", "scientific_name": "Helianthus", "category": categories[14], "description": "Растительное масло", "common_sources": "Подсолнечник", "halal_conditions": "Разрешено"},
        {"name": "Черный перец", "scientific_name": "Piper nigrum", "category": categories[15], "description": "Специя", "common_sources": "Тропики", "halal_conditions": "Разрешен"},
        {"name": "Сахар тростниковый", "scientific_name": "Sucrose", "category": categories[16], "description": "Подсластитель", "common_sources": "Сахарный тростник", "halal_conditions": "Разрешен"},
        {"name": "Морская соль", "scientific_name": "NaCl", "category": categories[17], "description": "Приправа", "common_sources": "Море", "halal_conditions": "Разрешена"},
    ]
    
    for data in ingredients_data:
        Ingredient.objects.create(**data)
    print(f"Создано {len(ingredients_data)} ингредиентов")


def create_halal_certificates():
    """Создание сертификатов халяльности"""
    bodies = list(CertificationBody.objects.all())
    
    certificates_data = []
    for i in range(20):
        body = random.choice(bodies)
        issued_date = date.today() - timedelta(days=random.randint(30, 365))
        expiry_date = issued_date + timedelta(days=365)
        
        certificates_data.append({
            "certificate_number": f"HAL-{body.country[:2].upper()}-{i+1:04d}-2024",
            "company_name": f"Компания {i+1}",
            "product_name": f"Продукт {i+1}",
            "certification_body": body,
            "issued_date": issued_date,
            "expiry_date": expiry_date,
            "status": random.choice(['active', 'expired', 'suspended']),
            "notes": f"Сертификат для продукта {i+1}"
        })
    
    for data in certificates_data:
        HalalCertificate.objects.create(**data)
    print(f"Создано {len(certificates_data)} сертификатов халяльности")


def create_suppliers():
    """Создание поставщиков"""
    certificates = list(HalalCertificate.objects.all())
    countries = ["Казахстан", "Россия", "Турция", "ОАЭ", "Малайзия", "Индонезия", "Пакистан", "Бангладеш", "Египет", "Марокко"]
    
    suppliers_data = []
    for i in range(20):
        suppliers_data.append({
            "name": f"Поставщик {i+1}",
            "contact_person": f"Контактное лицо {i+1}",
            "email": f"supplier{i+1}@example.com",
            "phone": f"+7{random.randint(7000000000, 7999999999)}",
            "address": f"Адрес {i+1}, Город {i+1}",
            "country": random.choice(countries),
            "website": f"https://supplier{i+1}.com",
            "halal_certificate": random.choice(certificates) if certificates else None,
            "status": random.choice(['approved', 'pending', 'rejected', 'suspended']),
            "halal_compliance_score": random.randint(0, 100),
            "notes": f"Примечания для поставщика {i+1}"
        })
    
    for data in suppliers_data:
        Supplier.objects.create(**data)
    print(f"Создано {len(suppliers_data)} поставщиков")


def create_production_processes():
    """Создание производственных процессов"""
    process_types = ['manufacturing', 'packaging', 'storage', 'transportation', 'quality_control']
    
    processes_data = []
    for i in range(20):
        process_type = random.choice(process_types)
        processes_data.append({
            "name": f"Процесс {i+1}",
            "process_type": process_type,
            "description": f"Описание процесса {i+1} типа {process_type}",
            "equipment_used": f"Оборудование для процесса {i+1}",
            "halal_compliance_measures": f"Меры обеспечения халяльности для процесса {i+1}",
            "potential_risks": f"Потенциальные риски процесса {i+1}",
            "mitigation_strategies": f"Стратегии снижения рисков для процесса {i+1}",
            "is_active": random.choice([True, False])
        })
    
    for data in processes_data:
        ProductionProcess.objects.create(**data)
    print(f"Создано {len(processes_data)} производственных процессов")


def create_interview_questions():
    """Создание вопросов интервью"""
    categories = ['certification', 'production', 'ingredients', 'logistics', 'company_values', 'general']
    question_types = ['multiple_choice', 'yes_no', 'text', 'rating']
    
    questions_data = []
    for i in range(20):
        category = random.choice(categories)
        question_type = random.choice(question_types)
        
        question_texts = {
            'certification': f"Есть ли у вашей компании сертификат халяльности? (Вопрос {i+1})",
            'production': f"Какие меры вы принимаете для обеспечения халяльности производства? (Вопрос {i+1})",
            'ingredients': f"Как вы проверяете халяльность используемых ингредиентов? (Вопрос {i+1})",
            'logistics': f"Как вы обеспечиваете халяльность при транспортировке? (Вопрос {i+1})",
            'company_values': f"Какие этические принципы соблюдает ваша компания? (Вопрос {i+1})",
            'general': f"Расскажите о вашей компании и продукции? (Вопрос {i+1})"
        }
        
        options = None
        if question_type == 'multiple_choice':
            options = ["Да", "Нет", "Частично", "Не знаю"]
        elif question_type == 'yes_no':
            options = ["Да", "Нет"]
        elif question_type == 'rating':
            options = ["1", "2", "3", "4", "5"]
        
        questions_data.append({
            "category": category,
            "question_type": question_type,
            "question_text": question_texts[category],
            "options": options,
            "weight": random.randint(1, 10),
            "is_active": random.choice([True, False])
        })
    
    for data in questions_data:
        InterviewQuestion.objects.create(**data)
    print(f"Создано {len(questions_data)} вопросов интервью")


def create_company_assessments():
    """Создание оценок компаний"""
    industries = ["Пищевая промышленность", "Сельское хозяйство", "Переработка мяса", "Молочная промышленность", "Кондитерская", "Напитки", "Косметика", "Фармацевтика"]
    countries = ["Казахстан", "Россия", "Турция", "ОАЭ", "Малайзия", "Индонезия", "Пакистан", "Бангладеш", "Египет", "Марокко"]
    statuses = ['pending', 'in_progress', 'completed', 'failed']
    
    assessments_data = []
    for i in range(20):
        assessment_date = date.today() - timedelta(days=random.randint(1, 90))
        
        assessments_data.append({
            "company_name": f"Компания {i+1}",
            "contact_person": f"Контактное лицо {i+1}",
            "email": f"company{i+1}@example.com",
            "phone": f"+7{random.randint(7000000000, 7999999999)}",
            "industry": random.choice(industries),
            "country": random.choice(countries),
            "website": f"https://company{i+1}.com",
            "certification_score": random.randint(0, 100),
            "production_score": random.randint(0, 100),
            "ingredients_score": random.randint(0, 100),
            "logistics_score": random.randint(0, 100),
            "company_values_score": random.randint(0, 100),
            "overall_score": random.randint(0, 100),
            "status": random.choice(statuses),
            "assessment_date": assessment_date,
            "assessor_name": f"Оценщик {i+1}",
            "notes": f"Примечания для компании {i+1}",
            "recommendations": f"Рекомендации для компании {i+1}"
        })
    
    for data in assessments_data:
        CompanyAssessment.objects.create(**data)
    print(f"Создано {len(assessments_data)} оценок компаний")


def create_interview_responses():
    """Создание ответов на вопросы интервью"""
    assessments = list(CompanyAssessment.objects.all())
    questions = list(InterviewQuestion.objects.all())
    
    responses_data = []
    for i in range(20):
        assessment = random.choice(assessments)
        question = random.choice(questions)
        
        responses_data.append({
            "assessment": assessment,
            "question": question,
            "answer": f"Ответ на вопрос {question.id} от компании {assessment.company_name}",
            "score": random.randint(0, 100),
            "notes": f"Примечания к ответу {i+1}"
        })
    
    for data in responses_data:
        InterviewResponse.objects.create(**data)
    print(f"Создано {len(responses_data)} ответов на вопросы")


def create_compliance_audits():
    """Создание аудитов соответствия"""
    assessments = list(CompanyAssessment.objects.all())
    audit_types = ['initial', 'periodic', 'follow_up', 'surprise']
    audit_statuses = ['scheduled', 'in_progress', 'completed', 'failed']
    
    audits_data = []
    for i in range(20):
        assessment = random.choice(assessments)
        scheduled_date = date.today() + timedelta(days=random.randint(1, 90))
        actual_date = scheduled_date + timedelta(days=random.randint(-5, 5)) if random.choice([True, False]) else None
        
        audits_data.append({
            "company_assessment": assessment,
            "audit_type": random.choice(audit_types),
            "scheduled_date": scheduled_date,
            "actual_date": actual_date,
            "auditor_name": f"Аудитор {i+1}",
            "status": random.choice(audit_statuses),
            "compliance_score": random.randint(0, 100),
            "non_compliances": f"Несоответствия для аудита {i+1}",
            "corrective_actions": f"Корректирующие действия для аудита {i+1}",
            "next_audit_date": scheduled_date + timedelta(days=365),
            "notes": f"Примечания к аудиту {i+1}"
        })
    
    for data in audits_data:
        ComplianceAudit.objects.create(**data)
    print(f"Создано {len(audits_data)} аудитов соответствия")


def create_partnerships():
    """Создание партнерств"""
    assessments = list(CompanyAssessment.objects.all())
    partnership_types = ['supplier', 'distributor', 'manufacturer', 'service_provider']
    partnership_statuses = ['proposed', 'negotiating', 'active', 'suspended', 'terminated']
    
    partnerships_data = []
    for i in range(20):
        assessment = random.choice(assessments)
        start_date = date.today() + timedelta(days=random.randint(1, 30))
        end_date = start_date + timedelta(days=random.randint(365, 1095))
        
        partnerships_data.append({
            "company_assessment": assessment,
            "partnership_type": random.choice(partnership_types),
            "status": random.choice(partnership_statuses),
            "start_date": start_date,
            "end_date": end_date,
            "contract_value": Decimal(str(random.randint(10000, 1000000))),
            "terms_and_conditions": f"Условия партнерства {i+1}",
            "halal_requirements": f"Требования халяльности для партнерства {i+1}",
            "monitoring_frequency": random.choice(["Ежемесячно", "Ежеквартально", "Ежегодно"]),
            "contact_person": f"Контактное лицо партнерства {i+1}",
            "contact_email": f"partnership{i+1}@example.com",
            "contact_phone": f"+7{random.randint(7000000000, 7999999999)}",
            "notes": f"Примечания к партнерству {i+1}"
        })
    
    for data in partnerships_data:
        Partnership.objects.create(**data)
    print(f"Создано {len(partnerships_data)} партнерств")


def main():
    """Основная функция для создания всех мок данных"""
    print("Начинаем создание мок данных для брокерской компании...")
    
    # Очистка существующих данных
    print("Очищаем существующие данные...")
    Partnership.objects.all().delete()
    ComplianceAudit.objects.all().delete()
    InterviewResponse.objects.all().delete()
    CompanyAssessment.objects.all().delete()
    InterviewQuestion.objects.all().delete()
    ProductionProcess.objects.all().delete()
    Supplier.objects.all().delete()
    HalalCertificate.objects.all().delete()
    Ingredient.objects.all().delete()
    IngredientCategory.objects.all().delete()
    CertificationBody.objects.all().delete()
    
    # Создание данных в правильном порядке (с учетом зависимостей)
    create_certification_bodies()
    create_ingredient_categories()
    create_ingredients()
    create_halal_certificates()
    create_suppliers()
    create_production_processes()
    create_interview_questions()
    create_company_assessments()
    create_interview_responses()
    create_compliance_audits()
    create_partnerships()
    
    print("\n✅ Все мок данные успешно созданы!")
    print(f"📊 Статистика:")
    print(f"   - Органы сертификации: {CertificationBody.objects.count()}")
    print(f"   - Сертификаты халяльности: {HalalCertificate.objects.count()}")
    print(f"   - Категории ингредиентов: {IngredientCategory.objects.count()}")
    print(f"   - Ингредиенты: {Ingredient.objects.count()}")
    print(f"   - Поставщики: {Supplier.objects.count()}")
    print(f"   - Производственные процессы: {ProductionProcess.objects.count()}")
    print(f"   - Оценки компаний: {CompanyAssessment.objects.count()}")
    print(f"   - Вопросы интервью: {InterviewQuestion.objects.count()}")
    print(f"   - Ответы на вопросы: {InterviewResponse.objects.count()}")
    print(f"   - Аудиты соответствия: {ComplianceAudit.objects.count()}")
    print(f"   - Партнерства: {Partnership.objects.count()}")


if __name__ == "__main__":
    main()
