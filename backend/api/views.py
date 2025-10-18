from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import User, TransactionFrom, TransactionTo, Finance, Goal, Savings
from .serializers import UserSerializer, TransactionFromSerializer, TransactionToSerializer, FinanceSerializer, GoalSerializer, SavingsSerializer


class UserViewSet(viewsets.ModelViewSet):
    """CRUD операции для пользователей"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    
    @swagger_auto_schema(
        operation_description="Получить список всех пользователей",
        responses={200: UserSerializer(many=True)}
    )
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Создать нового пользователя",
        request_body=UserSerializer,
        responses={201: UserSerializer}
    )
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Получить конкретного пользователя по ID",
        responses={200: UserSerializer}
    )
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Полностью обновить пользователя",
        request_body=UserSerializer,
        responses={200: UserSerializer}
    )
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Частично обновить пользователя",
        request_body=UserSerializer,
        responses={200: UserSerializer}
    )
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(
        operation_description="Удалить пользователя",
        responses={204: 'Пользователь успешно удален'}
    )
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)
    
    @swagger_auto_schema(
        method='post',
        operation_description="Логин пользователя (Basic Auth)",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['email', 'password'],
            properties={
                'email': openapi.Schema(type=openapi.TYPE_STRING, description='Email'),
                'password': openapi.Schema(type=openapi.TYPE_STRING, description='Пароль'),
            },
        ),
        responses={
            200: openapi.Response(
                description="Успешный логин",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'id': openapi.Schema(type=openapi.TYPE_INTEGER),
                        'name': openapi.Schema(type=openapi.TYPE_STRING),
                        'surname': openapi.Schema(type=openapi.TYPE_STRING),
                        'email': openapi.Schema(type=openapi.TYPE_STRING),
                        'type': openapi.Schema(type=openapi.TYPE_STRING),
                    }
                )
            ),
            400: 'Email и пароль обязательны',
            401: 'Неверный email или пароль',
        }
    )
    @action(detail=False, methods=['post'])
    def login(self, request):
        """Эндпоинт для логина"""
        email = request.data.get('email')
        password = request.data.get('password')
        
        if not email or not password:
            return Response(
                {'error': 'Email и пароль обязательны'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email, password=password)
            return Response({
                'id': user.id,
                'name': user.name,
                'surname': user.surname,
                'email': user.email,
                'type': user.type
            }, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response(
                {'error': 'Неверный email или пароль'},
                status=status.HTTP_401_UNAUTHORIZED
            )


class TransactionFromViewSet(viewsets.ModelViewSet):
    """CRUD операции для TransactionFrom"""
    queryset = TransactionFrom.objects.all()
    serializer_class = TransactionFromSerializer
    
    @swagger_auto_schema(operation_description="Получить список всех TransactionFrom")
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Создать новый TransactionFrom")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Получить конкретный TransactionFrom")
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Обновить TransactionFrom")
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Частично обновить TransactionFrom")
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Удалить TransactionFrom")
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)


class TransactionToViewSet(viewsets.ModelViewSet):
    """CRUD операции для TransactionTo"""
    queryset = TransactionTo.objects.all()
    serializer_class = TransactionToSerializer
    
    @swagger_auto_schema(operation_description="Получить список всех TransactionTo")
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Создать новый TransactionTo")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Получить конкретный TransactionTo")
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Обновить TransactionTo")
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Частично обновить TransactionTo")
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Удалить TransactionTo")
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)


class FinanceViewSet(viewsets.ModelViewSet):
    """CRUD операции для Finance"""
    queryset = Finance.objects.all()
    serializer_class = FinanceSerializer
    
    @swagger_auto_schema(operation_description="Получить список всех Finance")
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Создать новый Finance")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Получить конкретный Finance")
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Обновить Finance")
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Частично обновить Finance")
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Удалить Finance")
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)


class GoalViewSet(viewsets.ModelViewSet):
    """CRUD операции для Goal"""
    queryset = Goal.objects.all()
    serializer_class = GoalSerializer
    
    @swagger_auto_schema(operation_description="Получить список всех Goal")
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Создать новый Goal")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Получить конкретный Goal")
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Обновить Goal")
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Частично обновить Goal")
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Удалить Goal")
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)


class SavingsViewSet(viewsets.ModelViewSet):
    """CRUD операции для Savings"""
    queryset = Savings.objects.all()
    serializer_class = SavingsSerializer
    
    @swagger_auto_schema(operation_description="Получить список всех Savings")
    def list(self, request, *args, **kwargs):
        return super().list(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Создать новый Savings")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Получить конкретный Savings")
    def retrieve(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Обновить Savings")
    def update(self, request, *args, **kwargs):
        return super().update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Частично обновить Savings")
    def partial_update(self, request, *args, **kwargs):
        return super().partial_update(request, *args, **kwargs)
    
    @swagger_auto_schema(operation_description="Удалить Savings")
    def destroy(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)

