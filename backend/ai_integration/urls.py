from django.urls import path
from . import views

urlpatterns = [
    # AI Chat endpoint
    path('chat/', views.AIChatView.as_view(), name='ai-chat'),
    
    # Voice-to-Voice endpoint (единственный voice endpoint)
    path('voice/', views.VoiceToVoiceView.as_view(), name='voice-to-voice'),
]