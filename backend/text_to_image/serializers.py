from rest_framework import serializers
from .models import ImageGeneration


class ImageGenerationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImageGeneration
        fields = ['id', 'prompt', 'image_url', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'image_url', 'status', 'created_at', 'updated_at']
