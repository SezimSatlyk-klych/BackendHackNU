from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, TransactionFromViewSet, TransactionToViewSet, FinanceViewSet, GoalViewSet, SavingsViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'transaction-from', TransactionFromViewSet, basename='transaction-from')
router.register(r'transaction-to', TransactionToViewSet, basename='transaction-to')
router.register(r'finance', FinanceViewSet, basename='finance')
router.register(r'goals', GoalViewSet, basename='goal')
router.register(r'savings', SavingsViewSet, basename='savings')

urlpatterns = [
    path('', include(router.urls)),
]

