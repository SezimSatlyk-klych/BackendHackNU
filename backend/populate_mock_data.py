#!/usr/bin/env python
"""
Скрипт для заполнения базы данных мок-данными
"""
import os
import sys
import django
from decimal import Decimal

# Настройка Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from api.models import User, TransactionFrom, TransactionTo, Finance, Goal, Savings


def create_mock_data():
    """Создает мок-данные для всех моделей"""
    
    print("Создание мок-данных...")
    
    # Очистка существующих данных
    print("Очистка существующих данных...")
    Savings.objects.all().delete()
    Finance.objects.all().delete()
    Goal.objects.all().delete()
    TransactionTo.objects.all().delete()
    TransactionFrom.objects.all().delete()
    User.objects.all().delete()
    
    # 1. Создание пользователей
    print("Создание пользователей...")
    users_data = [
        {"name": "Анна", "surname": "Иванова", "type": "adult", "email": "anna@example.com", "password": "anna123"},
        {"name": "Петр", "surname": "Петров", "type": "adult", "email": "petr@example.com", "password": "petr123"},
        {"name": "Мария", "surname": "Сидорова", "type": "adult", "email": "maria@example.com", "password": "maria123"},
        {"name": "Алексей", "surname": "Козлов", "type": "child", "email": "alex@example.com", "password": "alex123"},
        {"name": "София", "surname": "Морозова", "type": "child", "email": "sofia@example.com", "password": "sofia123"},
    ]
    
    users = []
    for user_data in users_data:
        user = User.objects.create(**user_data)
        users.append(user)
        print(f"Создан пользователь: {user.name} {user.surname}")
    
    # 2. Создание транзакций (откуда)
    print("Создание транзакций 'от'...")
    transactions_from_data = [
        {"sum": Decimal("5000.00"), "type": "Зарплата"},
        {"sum": Decimal("3000.00"), "type": "Фриланс"},
        {"sum": Decimal("2000.00"), "type": "Подарок"},
        {"sum": Decimal("1500.00"), "type": "Стипендия"},
        {"sum": Decimal("800.00"), "type": "Карманные деньги"},
    ]
    
    transactions_from = []
    for trans_data in transactions_from_data:
        trans = TransactionFrom.objects.create(**trans_data)
        transactions_from.append(trans)
        print(f"Создана транзакция 'от': {trans.sum} - {trans.type}")
    
    # 3. Создание транзакций (куда)
    print("Создание транзакций 'к'...")
    transactions_to_data = [
        {"sum": Decimal("2000.00"), "type": "Продукты"},
        {"sum": Decimal("1500.00"), "type": "Одежда"},
        {"sum": Decimal("1000.00"), "type": "Развлечения"},
        {"sum": Decimal("800.00"), "type": "Игрушки"},
        {"sum": Decimal("500.00"), "type": "Книги"},
    ]
    
    transactions_to = []
    for trans_data in transactions_to_data:
        trans = TransactionTo.objects.create(**trans_data)
        transactions_to.append(trans)
        print(f"Создана транзакция 'к': {trans.sum} - {trans.type}")
    
    # 4. Создание целей
    print("Создание целей...")
    goals_data = [
        {"goal_desc": "Накопить на новый ноутбук", "goal_sum": Decimal("50000.00"), "goal_progress": Decimal("25.50")},
        {"goal_desc": "Купить велосипед", "goal_sum": Decimal("15000.00"), "goal_progress": Decimal("60.00")},
        {"goal_desc": "Поездка в отпуск", "goal_sum": Decimal("80000.00"), "goal_progress": Decimal("15.75")},
        {"goal_desc": "Новая игрушка", "goal_sum": Decimal("5000.00"), "goal_progress": Decimal("80.00")},
        {"goal_desc": "Курсы программирования", "goal_sum": Decimal("25000.00"), "goal_progress": Decimal("40.00")},
    ]
    
    goals = []
    for goal_data in goals_data:
        goal = Goal.objects.create(**goal_data)
        goals.append(goal)
        print(f"Создана цель: {goal.goal_desc[:30]}...")
    
    # 5. Создание накоплений (связанных с целями)
    print("Создание накоплений...")
    savings_data = [
        {"goal": goals[0], "sum": Decimal("12750.00")},  # 25.5% от 50000
        {"goal": goals[1], "sum": Decimal("9000.00")},   # 60% от 15000
        {"goal": goals[2], "sum": Decimal("12600.00")},  # 15.75% от 80000
        {"goal": goals[3], "sum": Decimal("4000.00")},   # 80% от 5000
        {"goal": goals[4], "sum": Decimal("10000.00")},  # 40% от 25000
    ]
    
    savings = []
    for saving_data in savings_data:
        saving = Savings.objects.create(**saving_data)
        savings.append(saving)
        print(f"Создано накопление: {saving.sum} для цели '{saving.goal.goal_desc[:20]}...'")
    
    # 6. Создание финансовых записей (связанных с транзакциями и целями)
    print("Создание финансовых записей...")
    finance_data = [
        {"current_state": Decimal("25000.00"), "transaction_from": transactions_from[0], "transaction_to": transactions_to[0], "goals": goals[0]},
        {"current_state": Decimal("18000.00"), "transaction_from": transactions_from[1], "transaction_to": transactions_to[1], "goals": goals[1]},
        {"current_state": Decimal("32000.00"), "transaction_from": transactions_from[2], "transaction_to": transactions_to[2], "goals": goals[2]},
        {"current_state": Decimal("12000.00"), "transaction_from": transactions_from[3], "transaction_to": transactions_to[3], "goals": goals[3]},
        {"current_state": Decimal("15000.00"), "transaction_from": transactions_from[4], "transaction_to": transactions_to[4], "goals": goals[4]},
    ]
    
    finance_records = []
    for finance_data_item in finance_data:
        finance = Finance.objects.create(**finance_data_item)
        finance_records.append(finance)
        print(f"Создана финансовая запись: текущее состояние {finance.current_state}")
    
    print("\n" + "="*50)
    print("МОК-ДАННЫЕ УСПЕШНО СОЗДАНЫ!")
    print("="*50)
    print(f"Пользователей: {User.objects.count()}")
    print(f"Транзакций 'от': {TransactionFrom.objects.count()}")
    print(f"Транзакций 'к': {TransactionTo.objects.count()}")
    print(f"Целей: {Goal.objects.count()}")
    print(f"Накоплений: {Savings.objects.count()}")
    print(f"Финансовых записей: {Finance.objects.count()}")
    print("="*50)


if __name__ == "__main__":
    create_mock_data()
