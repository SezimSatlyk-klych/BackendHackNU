from rest_framework import serializers
from .models import User, TransactionFrom, TransactionTo, Finance, Goal, Savings


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'name', 'surname', 'type', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}


class TransactionFromSerializer(serializers.ModelSerializer):
    class Meta:
        model = TransactionFrom
        fields = ['id', 'sum', 'type']


class TransactionToSerializer(serializers.ModelSerializer):
    class Meta:
        model = TransactionTo
        fields = ['id', 'sum', 'type']


class FinanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Finance
        fields = ['id', 'current_state', 'transaction_from', 'transaction_to', 'goals']


class GoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goal
        fields = ['id', 'goal_desc', 'goal_sum', 'goal_progress']


class SavingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Savings
        fields = ['id', 'goal', 'sum']

