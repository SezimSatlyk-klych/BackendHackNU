from django.db import models


class User(models.Model):
    TYPE_CHOICES = [
        ('adult', 'Взрослый'),
        ('child', 'Ребенок'),
    ]
    
    name = models.CharField(max_length=100)
    surname = models.CharField(max_length=100)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    
    def __str__(self):
        return f"{self.name} {self.surname}"


class TransactionFrom(models.Model):
    sum = models.DecimalField(max_digits=10, decimal_places=2)
    type = models.CharField(max_length=100)
    
    def __str__(self):
        return f"From: {self.sum} - {self.type}"


class TransactionTo(models.Model):
    sum = models.DecimalField(max_digits=10, decimal_places=2)
    type = models.CharField(max_length=100)
    
    def __str__(self):
        return f"To: {self.sum} - {self.type}"


class Goal(models.Model):
    goal_desc = models.TextField()
    goal_sum = models.DecimalField(max_digits=10, decimal_places=2)
    goal_progress = models.DecimalField(max_digits=5, decimal_places=2)
    
    def __str__(self):
        return f"Goal: {self.goal_desc[:50]}"


class Savings(models.Model):
    goal = models.ForeignKey(Goal, on_delete=models.CASCADE)
    sum = models.DecimalField(max_digits=10, decimal_places=2)
    
    def __str__(self):
        return f"Savings: {self.sum}"


class Finance(models.Model):
    current_state = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_from = models.ForeignKey(TransactionFrom, on_delete=models.CASCADE)
    transaction_to = models.ForeignKey(TransactionTo, on_delete=models.CASCADE)
    goals = models.ForeignKey(Goal, on_delete=models.CASCADE)
    
    def __str__(self):
        return f"Finance: {self.current_state}"

