//
//  ImageGenerationViewModel.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Image Generation ViewModel
@MainActor
class ImageGenerationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var currentGeneration: ImageGeneration?
    @Published var generatedImage: UIImage?
    @Published var errorMessage: String?
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    
    private let networkService = NetworkService.shared
    private var pollingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Image Generation Methods
    
    func generateImage(prompt: String) async {
        isLoading = true
        errorMessage = nil
        isGenerating = true
        generationProgress = 0.0
        
        do {
            print("🎨 ImageGeneration: Starting image generation with prompt: \(prompt)")
            
            // Create the generation request
            let generation = try await networkService.createImageGeneration(prompt: prompt)
            currentGeneration = generation
            
            print("✅ ImageGeneration: Generation created with ID: \(generation.id)")
            
            // Start polling for completion
            startPollingForCompletion(generationId: generation.id)
            
        } catch {
            print("❌ ImageGeneration: Error creating generation: \(error)")
            errorMessage = "Failed to start image generation: \(error.localizedDescription)"
            isLoading = false
            isGenerating = false
        }
    }
    
    private func startPollingForCompletion(generationId: Int) {
        print("🔄 ImageGeneration: Starting polling for generation ID: \(generationId)")
        
        // Start with a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.pollGenerationStatus(generationId: generationId)
        }
    }
    
    private func pollGenerationStatus(generationId: Int) {
        Task {
            do {
                let generation = try await networkService.fetchImageGeneration(id: generationId)
                currentGeneration = generation
                
                print("📊 ImageGeneration: Status update - \(generation.status.rawValue)")
                
                switch generation.status {
                case .completed:
                    if let imageUrl = generation.imageUrl {
                        await loadGeneratedImage(from: imageUrl)
                    }
                    stopPolling()
                    isGenerating = false
                    isLoading = false
                    generationProgress = 1.0
                    
                case .failed:
                    errorMessage = "Image generation failed"
                    stopPolling()
                    isGenerating = false
                    isLoading = false
                    generationProgress = 0.0
                    
                case .pending, .processing:
                    // Continue polling for both pending and processing states
                    generationProgress = min(generationProgress + 0.1, 0.9)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.pollGenerationStatus(generationId: generationId)
                    }
                }
                
            } catch {
                print("❌ ImageGeneration: Error polling status: \(error)")
                errorMessage = "Failed to check generation status: \(error.localizedDescription)"
                stopPolling()
                isGenerating = false
                isLoading = false
            }
        }
    }
    
    private func loadGeneratedImage(from urlString: String) async {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid image URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                generatedImage = image
                print("✅ ImageGeneration: Image loaded successfully")
            } else {
                errorMessage = "Failed to create image from data"
            }
        } catch {
            print("❌ ImageGeneration: Error loading image: \(error)")
            errorMessage = "Failed to load generated image: \(error.localizedDescription)"
        }
    }
    
    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    // MARK: - Force Generation
    
    func forceGeneration() async {
        guard let generation = currentGeneration else { return }
        
        do {
            let response = try await networkService.forceImageGeneration(id: generation.id)
            print("🔄 ImageGeneration: Force generation response: \(response.message)")
            
            // Restart polling
            startPollingForCompletion(generationId: generation.id)
            
        } catch {
            print("❌ ImageGeneration: Error forcing generation: \(error)")
            errorMessage = "Failed to force generation: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Reset Methods
    
    func resetGeneration() {
        currentGeneration = nil
        generatedImage = nil
        errorMessage = nil
        isGenerating = false
        isLoading = false
        generationProgress = 0.0
        stopPolling()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var hasGeneratedImage: Bool {
        return generatedImage != nil
    }
    
    var canForceGeneration: Bool {
        return (currentGeneration?.status == .pending || currentGeneration?.status == .processing) && !isGenerating
    }
    
    var statusText: String {
        guard let generation = currentGeneration else { return "Ready" }
        return generation.status.displayName
    }
    
    var progressText: String {
        if isGenerating {
            return "Generating... \(Int(generationProgress * 100))%"
        } else if hasGeneratedImage {
            return "Completed"
        } else {
            return statusText
        }
    }
}
