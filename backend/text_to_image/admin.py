from django.contrib import admin
from .models import ImageGeneration


@admin.register(ImageGeneration)
class ImageGenerationAdmin(admin.ModelAdmin):
    list_display = ('id', 'prompt_short', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('prompt',)
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('-created_at',)
    
    def prompt_short(self, obj):
        return obj.prompt[:50] + "..." if len(obj.prompt) > 50 else obj.prompt
    prompt_short.short_description = 'Описание комикса'