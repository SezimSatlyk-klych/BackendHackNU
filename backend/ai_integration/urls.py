from django.urls import path
from . import views

urlpatterns = [
    # AI Chat endpoint
    path('chat/', views.AIChatView.as_view(), name='ai-chat'),
    
    # Voice-to-Voice endpoint временно отключен из-за проблем с зависимостями
    # path('voice/', views.VoiceToVoiceView.as_view(), name='voice-to-voice'),
]