from rest_framework import viewsets
from drf_yasg.utils import swagger_auto_schema
from .models import Investment, Donation
from .serializers import InvestmentSerializer, DonationSerializer


class InvestmentViewSet(viewsets.ModelViewSet):
    queryset = Investment.objects.all()
    serializer_class = InvestmentSerializer

    @swagger_auto_schema(tags=['Инвестиции'])
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)

    @swagger_auto_schema(tags=['Инвестиции'])
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class DonationViewSet(viewsets.ModelViewSet):
    queryset = Donation.objects.all()
    serializer_class = DonationSerializer

    @swagger_auto_schema(tags=['Пожертвования'])
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)

    @swagger_auto_schema(tags=['Пожертвования'])
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)

