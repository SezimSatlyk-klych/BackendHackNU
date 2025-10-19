from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InvestmentViewSet, DonationViewSet

router = DefaultRouter()
router.register(r'investments', InvestmentViewSet)
router.register(r'donations', DonationViewSet)

urlpatterns = [
    path('', include(router.urls)),
]


