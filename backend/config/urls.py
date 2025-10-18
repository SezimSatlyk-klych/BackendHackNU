"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

schema_view = get_schema_view(
    openapi.Info(
        title="HackNU API",
        default_version='v1',
                description="""
                API для управления пользователями, финансами, целями и накоплениями.
                
                Дополнительные возможности:
                - AI чат для анализа финансовых данных
                - Генерация комикс-стрипов с 6 панелями из текста
                - Брокерская компания (в разработке)
                
                Все эндпоинты поддерживают полный CRUD:
                - GET (list) - получить список
                - POST (create) - создать новый объект
                - GET (retrieve) - получить конкретный объект по ID
                - PUT (update) - полностью обновить объект
                - PATCH (partial_update) - частично обновить объект
                - DELETE (destroy) - удалить объект
                """,
        contact=openapi.Contact(email="admin@hacknu.com"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='swagger'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='redoc'),
    path('api/', include('api.urls')),
    path('ai/', include('ai_integration.urls')),
    path('text-to-image/', include('text_to_image.urls')),
    path('broker/', include('broker_company.urls')),
]
