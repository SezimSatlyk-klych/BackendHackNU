from django.contrib import admin
from .models import User, TransactionFrom, TransactionTo, Finance, Goal, Savings

admin.site.register(User)
admin.site.register(TransactionFrom)
admin.site.register(TransactionTo)
admin.site.register(Finance)
admin.site.register(Goal)
admin.site.register(Savings)

