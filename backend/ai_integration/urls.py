from django.urls import path
from . import views
from .audio_view import VoiceToVoiceAudioView

urlpatterns = [
    # AI Chat endpoint
    path('chat/', views.AIChatView.as_view(), name='ai-chat'),
    
    # Voice-to-Voice endpoint (JSON response with base64)
    path('voice/', views.VoiceToVoiceView.as_view(), name='voice-to-voice'),
    
    # Voice-to-Voice endpoint (возвращает готовый аудио файл)
    path('voice/audio/', VoiceToVoiceAudioView.as_view(), name='voice-to-voice-audio'),
]