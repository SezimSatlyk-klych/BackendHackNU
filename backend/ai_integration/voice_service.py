import os
import io
import base64
import tempfile
import requests
from typing import Dict, Optional, Tuple
import openai
import speech_recognition as sr
from pydub import AudioSegment
from pydub.utils import which

# Устанавливаем путь к ffmpeg
AudioSegment.converter = "/usr/local/bin/ffmpeg"
AudioSegment.ffmpeg = "/usr/local/bin/ffmpeg"
AudioSegment.ffprobe = "/usr/local/bin/ffprobe"

class VoiceService:
    def __init__(self):
        """Инициализация Voice сервиса"""
        self.openai_api_key = os.getenv('OPENAI_API_KEY')
        self.elevenlabs_api_key = os.getenv('ELEVENLABS_API_KEY')
        self.elevenlabs_voice_id = '21m00Tcm4TlvDq8ikWAM'  # Стандартный голос ElevenLabs
        
        # Инициализация клиентов
        self.openai_client = openai.OpenAI(api_key=self.openai_api_key)
        
        # Инициализация распознавания речи
        self.recognizer = sr.Recognizer()
    
    def speech_to_text(self, audio_file) -> Dict:
        """
        Конвертирует аудио в текст используя OpenAI Whisper API
        
        Args:
            audio_file: Файл аудио (может быть base64 или файл)
            
        Returns:
            Dict: Результат с текстом или ошибкой
        """
        try:
            # Если это base64 строка, декодируем
            if isinstance(audio_file, str):
                audio_data = base64.b64decode(audio_file)
                with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_file:
                    temp_file.write(audio_data)
                    temp_audio_path = temp_file.name
            else:
                # Если это файл, сохраняем во временный файл
                with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_file:
                    for chunk in audio_file.chunks():
                        temp_file.write(chunk)
                    temp_audio_path = temp_file.name
            
            # Конвертируем в WAV если нужно
            audio = AudioSegment.from_file(temp_audio_path)
            wav_path = temp_audio_path.replace('.wav', '_converted.wav')
            audio.export(wav_path, format="wav")
            
            # Используем OpenAI Whisper API для распознавания речи
            with open(wav_path, 'rb') as audio_file_obj:
                transcript = self.openai_client.audio.transcriptions.create(
                    model="whisper-1",
                    file=audio_file_obj,
                    language="ru"  # Русский язык
                )
            
            # Удаляем временные файлы
            os.unlink(temp_audio_path)
            os.unlink(wav_path)
            
            return {
                "success": True,
                "text": transcript.text,
                "language": "ru-RU",
                "model": "whisper-1"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка при обработке аудио: {str(e)}"
            }
    
    def text_to_speech(self, text: str, voice_id: Optional[str] = None) -> Dict:
        """
        Конвертирует текст в речь
        
        Args:
            text (str): Текст для озвучивания
            voice_id (str, optional): ID голоса ElevenLabs
            
        Returns:
            Dict: Результат с аудио данными или ошибкой
        """
        try:
            voice_id = voice_id or self.elevenlabs_voice_id
            
            # Используем ElevenLabs API через requests
            url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
            
            headers = {
                "Accept": "audio/mpeg",
                "Content-Type": "application/json",
                "xi-api-key": self.elevenlabs_api_key
            }
            
            data = {
                "text": text,
                "model_id": "eleven_multilingual_v2",
                "voice_settings": {
                    "stability": 0.5,
                    "similarity_boost": 0.5
                }
            }
            
            response = requests.post(url, json=data, headers=headers)
            
            if response.status_code == 200:
                # Конвертируем в base64
                audio_base64 = base64.b64encode(response.content).decode('utf-8')
                
                return {
                    "success": True,
                    "audio_base64": audio_base64,
                    "voice_id": voice_id,
                    "text": text,
                    "model": "eleven_multilingual_v2"
                }
            else:
                return {
                    "success": False,
                    "error": f"ElevenLabs API error: {response.status_code} - {response.text}"
                }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка при генерации речи: {str(e)}"
            }
    
    def process_voice_to_voice(self, audio_file, context: Optional[str] = None) -> Dict:
        """
        Полный цикл: голос -> текст -> AI ответ -> голос
        
        Args:
            audio_file: Аудио файл с вопросом
            context (str, optional): Дополнительный контекст
            
        Returns:
            Dict: Результат с аудио ответом и промежуточными данными
        """
        try:
            # Шаг 1: Голос в текст
            stt_result = self.speech_to_text(audio_file)
            if not stt_result["success"]:
                return stt_result
            
            question_text = stt_result["text"]
            
            # Шаг 2: AI обработка
            ai_result = self._get_ai_response(question_text, context)
            if not ai_result["success"]:
                return ai_result
            
            ai_response_text = ai_result["answer"]
            
            # Шаг 3: Текст в голос
            tts_result = self.text_to_speech(ai_response_text)
            if not tts_result["success"]:
                return tts_result
            
            return {
                "success": True,
                "original_question": question_text,
                "ai_response": ai_response_text,
                "audio_response_base64": tts_result["audio_base64"],
                "voice_id": tts_result["voice_id"],
                "model": "gpt-4 + whisper-1 + elevenlabs"
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка в процессе voice-to-voice: {str(e)}"
            }
    
    def _get_ai_response(self, question: str, context: Optional[str] = None) -> Dict:
        """
        Получает ответ от AI
        
        Args:
            question (str): Вопрос
            context (str, optional): Контекст
            
        Returns:
            Dict: Ответ AI
        """
        try:
            system_prompt = "Ты - полезный AI ассистент. Отвечай на вопросы пользователя на русском языке. Будь дружелюбным, информативным и точным."
            
            if context:
                system_prompt += f"\n\nКонтекст: {context}"
            
            response = self.openai_client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": question}
                ],
                temperature=0.7,
                max_tokens=1000
            )
            
            ai_response = response.choices[0].message.content
            
            return {
                "success": True,
                "answer": ai_response,
                "question": question
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": f"Ошибка AI: {str(e)}"
            }


# Функции для простого использования
def speech_to_text_simple(audio_file) -> str:
    """Простая функция для конвертации речи в текст"""
    service = VoiceService()
    result = service.speech_to_text(audio_file)
    return result["text"] if result["success"] else f"Ошибка: {result['error']}"

def text_to_speech_simple(text: str, voice_id: Optional[str] = None) -> str:
    """Простая функция для конвертации текста в речь"""
    service = VoiceService()
    result = service.text_to_speech(text, voice_id)
    return result["audio_base64"] if result["success"] else f"Ошибка: {result['error']}"

def voice_to_voice_simple(audio_file, context: Optional[str] = None) -> Dict:
    """Простая функция для полного цикла voice-to-voice"""
    service = VoiceService()
    return service.process_voice_to_voice(audio_file, context)
