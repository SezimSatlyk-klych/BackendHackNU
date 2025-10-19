#!/usr/bin/env python3
"""
Database Population Script for ZamanBank
This script creates sample data for testing the application.
"""

import os
import sys
import django
from decimal import Decimal

# Add the backend directory to Python path
sys.path.append('/app')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from api.models import User, TransactionFrom, TransactionTo, Goal, Savings, Finance

def create_sample_data():
    """Create sample data for testing"""
    
    print("🚀 Starting database population...")
    
    # Clear existing data
    print("🧹 Clearing existing data...")
    Finance.objects.all().delete()
    Savings.objects.all().delete()
    Goal.objects.all().delete()
    TransactionTo.objects.all().delete()
    TransactionFrom.objects.all().delete()
    User.objects.all().delete()
    
    # Create Users
    print("👤 Creating users...")
    
    # Adult User 1
    user1 = User.objects.create(
        name="Aiaulym",
        surname="Abduohapova",
        type="adult",
        email="aiaulym@example.com",
        password="password123"
    )
    
    # Adult User 2
    user2 = User.objects.create(
        name="John",
        surname="Doe",
        type="adult",
        email="john@example.com",
        password="password123"
    )
    
    # Child User
    user3 = User.objects.create(
        name="Alice",
        surname="Smith",
        type="child",
        email="alice@example.com",
        password="password123"
    )
    
    print(f"✅ Created {User.objects.count()} users")
    
    # Create Transactions From (Income)
    print("💰 Creating income transactions...")
    
    transaction_from1 = TransactionFrom.objects.create(
        sum=Decimal('2500.00'),
        type="Salary"
    )
    
    transaction_from2 = TransactionFrom.objects.create(
        sum=Decimal('500.00'),
        type="Freelance"
    )
    
    transaction_from3 = TransactionFrom.objects.create(
        sum=Decimal('200.00'),
        type="Investment Return"
    )
    
    transaction_from4 = TransactionFrom.objects.create(
        sum=Decimal('100.00'),
        type="Allowance"
    )
    
    print(f"✅ Created {TransactionFrom.objects.count()} income transactions")
    
    # Create Transactions To (Expenses)
    print("💸 Creating expense transactions...")
    
    transaction_to1 = TransactionTo.objects.create(
        sum=Decimal('1200.00'),
        type="Rent"
    )
    
    transaction_to2 = TransactionTo.objects.create(
        sum=Decimal('300.00'),
        type="Groceries"
    )
    
    transaction_to3 = TransactionTo.objects.create(
        sum=Decimal('150.00'),
        type="Utilities"
    )
    
    transaction_to4 = TransactionTo.objects.create(
        sum=Decimal('200.00'),
        type="Entertainment"
    )
    
    transaction_to5 = TransactionTo.objects.create(
        sum=Decimal('50.00'),
        type="School Supplies"
    )
    
    print(f"✅ Created {TransactionTo.objects.count()} expense transactions")
    
    # Create Goals
    print("🎯 Creating financial goals...")
    
    goal1 = Goal.objects.create(
        goal_desc="Save for vacation to Europe",
        goal_sum=Decimal('5000.00'),
        goal_progress=Decimal('60.00')
    )
    
    goal2 = Goal.objects.create(
        goal_desc="Buy a new laptop",
        goal_sum=Decimal('1500.00'),
        goal_progress=Decimal('80.00')
    )
    
    goal3 = Goal.objects.create(
        goal_desc="Emergency fund",
        goal_sum=Decimal('3000.00'),
        goal_progress=Decimal('25.00')
    )
    
    goal4 = Goal.objects.create(
        goal_desc="Save for college",
        goal_sum=Decimal('10000.00'),
        goal_progress=Decimal('15.00')
    )
    
    goal5 = Goal.objects.create(
        goal_desc="Buy a bicycle",
        goal_sum=Decimal('300.00'),
        goal_progress=Decimal('100.00')
    )
    
    print(f"✅ Created {Goal.objects.count()} goals")
    
    # Create Savings
    print("💳 Creating savings records...")
    
    savings1 = Savings.objects.create(
        goal=goal1,
        sum=Decimal('3000.00')
    )
    
    savings2 = Savings.objects.create(
        goal=goal2,
        sum=Decimal('1200.00')
    )
    
    savings3 = Savings.objects.create(
        goal=goal3,
        sum=Decimal('750.00')
    )
    
    savings4 = Savings.objects.create(
        goal=goal4,
        sum=Decimal('1500.00')
    )
    
    savings5 = Savings.objects.create(
        goal=goal5,
        sum=Decimal('300.00')
    )
    
    print(f"✅ Created {Savings.objects.count()} savings records")
    
    # Create Finance records
    print("🏦 Creating finance records...")
    
    # Calculate current state (total income - total expenses)
    total_income = sum(tf.sum for tf in TransactionFrom.objects.all())
    total_expenses = sum(tt.sum for tt in TransactionTo.objects.all())
    current_balance = total_income - total_expenses
    
    finance1 = Finance.objects.create(
        current_state=current_balance,
        transaction_from=transaction_from1,
        transaction_to=transaction_to1,
        goals=goal1
    )
    
    finance2 = Finance.objects.create(
        current_state=current_balance,
        transaction_from=transaction_from2,
        transaction_to=transaction_to2,
        goals=goal2
    )
    
    finance3 = Finance.objects.create(
        current_state=current_balance,
        transaction_from=transaction_from3,
        transaction_to=transaction_to3,
        goals=goal3
    )
    
    print(f"✅ Created {Finance.objects.count()} finance records")
    
    # Display summary
    print("\n📊 Database Population Summary:")
    print(f"👤 Users: {User.objects.count()}")
    print(f"💰 Income Transactions: {TransactionFrom.objects.count()}")
    print(f"💸 Expense Transactions: {TransactionTo.objects.count()}")
    print(f"🎯 Goals: {Goal.objects.count()}")
    print(f"💳 Savings: {Savings.objects.count()}")
    print(f"🏦 Finance Records: {Finance.objects.count()}")
    print(f"💵 Current Balance: ${current_balance}")
    
    print("\n🔑 Test Accounts Created:")
    print("1. Adult User: aiaulym@example.com / password123")
    print("2. Adult User: john@example.com / password123")
    print("3. Child User: alice@example.com / password123")
    
    print("\n✅ Database population completed successfully!")

if __name__ == "__main__":
    create_sample_data()
