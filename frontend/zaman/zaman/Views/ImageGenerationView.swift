//
//  ImageGenerationView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Image Generation View
struct ImageGenerationView: View {
    @StateObject private var imageViewModel = ImageGenerationViewModel()
    @State private var promptText = ""
    @State private var showingImageFullscreen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Prompt Input
                    promptInputSection
                    
                    // Generate Button
                    generateButtonSection
                    
                    // Status Section
                    statusSection
                    
                    // Generated Image
                    if imageViewModel.hasGeneratedImage {
                        generatedImageSection
                    }
                    
                    Spacer()
                }
                .padding()
                .disabled(imageViewModel.isLoading)
                
                // Loading Overlay
                if imageViewModel.isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("AI Image Generator")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: .constant(imageViewModel.errorMessage != nil)) {
                Button("OK") {
                    imageViewModel.clearError()
                }
            } message: {
                if let error = imageViewModel.errorMessage {
                    Text(error)
                }
            }
            .sheet(isPresented: $showingImageFullscreen) {
                if let image = imageViewModel.generatedImage {
                    FullscreenImageView(image: image)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("AI Comic Creator")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Transform your ideas into 6-panel comic strips with AI")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Prompt Input Section
    private var promptInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe your comic story:")
                .font(.headline)
            
            TextEditor(text: $promptText)
                .frame(minHeight: 100)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Generate Button Section
    private var generateButtonSection: some View {
        Button(action: {
            Task {
                await imageViewModel.generateImage(prompt: promptText)
            }
        }) {
            HStack {
                if imageViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "wand.and.stars")
                }
                
                Text(imageViewModel.isLoading ? "Creating..." : "Create Comic")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if imageViewModel.isLoading {
                        Color(.systemGray4)
                    } else {
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(promptText.isEmpty || imageViewModel.isLoading)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(spacing: 12) {
            if imageViewModel.isGenerating {
                // Progress Bar
                VStack(spacing: 8) {
                    ProgressView(value: imageViewModel.generationProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.blue)
                    
                    Text(imageViewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if imageViewModel.currentGeneration != nil {
                // Status Text
                HStack {
                    Image(systemName: imageViewModel.hasGeneratedImage ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundColor(imageViewModel.hasGeneratedImage ? .green : .orange)
                    
                    Text(imageViewModel.progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Generated Image Section
    private var generatedImageSection: some View {
        VStack(spacing: 16) {
            Text("Your Comic")
                .font(.headline)
            
            if let image = imageViewModel.generatedImage {
                Button(action: {
                    showingImageFullscreen = true
                }) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("View Fullscreen") {
                        showingImageFullscreen = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Generate New") {
                        imageViewModel.resetGeneration()
                        promptText = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Creating your comic...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("AI is crafting your 6-panel comic strip")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}


// MARK: - Preview
#Preview {
    ImageGenerationView()
}
