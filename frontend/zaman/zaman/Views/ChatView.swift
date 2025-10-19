//
//  ChatView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI

// MARK: - Chat View
struct ChatView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var imageViewModel = ImageGenerationViewModel()
    @State private var messageText = ""
    @State private var showingImageFullscreen = false
    
    var body: some View {
        VStack(spacing: 0) {
            // AI Assistant Header
            aiAssistantHeader
            
            // Chat Messages Area
            chatMessagesArea
            
            // Message Input
            messageInputView
        }
        .background(Color(.systemGroupedBackground))
        .overlay(
            // Image Generation Loading Overlay
            Group {
                if imageViewModel.isLoading {
                    imageGenerationLoadingOverlay
                }
            }
        )
        .sheet(isPresented: $showingImageFullscreen) {
            if let image = imageViewModel.generatedImage {
                FullscreenImageView(image: image)
            }
        }
        .alert("Error", isPresented: .constant(imageViewModel.errorMessage != nil)) {
            Button("OK") {
                imageViewModel.clearError()
            }
        } message: {
            if let error = imageViewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - AI Assistant Header
    private var aiAssistantHeader: some View {
        HStack(spacing: 12) {
            // AI Robot Icon
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20))
                    .foregroundColor(.teal)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("AI Assistant")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Always here to help")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.teal, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Chat Messages Area
    private var chatMessagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Welcome Message
                    welcomeMessage
                    
                    // Chat Messages
                    ForEach(chatViewModel.messages) { message in
                        ChatMessageRow(
                            message: message,
                            onGenerateComic: {
                                Task {
                                    await imageViewModel.generateImage(prompt: message.content)
                                }
                            }
                        )
                        .id(message.id)
                    }
                    
                    if chatViewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("AI is thinking...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Generated Comic Strip Display
                    if imageViewModel.hasGeneratedImage {
                        generatedComicSection
                    }
                    
                    // Error message display
                    if let errorMessage = chatViewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Connection issue: \(errorMessage)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                if let lastMessage = chatViewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        HStack {
            Text("Hi, how can I assist you today?")
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(18)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Message Input View
    private var messageInputView: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $messageText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .autocorrectionDisabled(true)
                .onSubmit {
                    sendMessage()
                }
            
            // Image Icon Button
            Button(action: {
                // TODO: Implement image picker functionality
                print("Image picker tapped")
            }) {
                Image(systemName: "photo")
                    .foregroundColor(.teal)
                    .font(.system(size: 18))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
            }
            
            // Send Message Button
            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
            }
            .disabled(messageText.isEmpty || chatViewModel.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .fixKeyboardConstraints()
    }
    
    // MARK: - Send Message
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            await chatViewModel.sendMessage(message)
        }
    }
    
    // MARK: - Generated Comic Section
    private var generatedComicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text("Generated Comic")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            if let image = imageViewModel.generatedImage {
                Button(action: {
                    showingImageFullscreen = true
                }) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack(spacing: 12) {
                    Button("View Fullscreen") {
                        showingImageFullscreen = true
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("Generate New") {
                        imageViewModel.resetGeneration()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Image Generation Loading Overlay
    private var imageGenerationLoadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Creating Comic...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Generating a 6-panel comic strip from the AI response")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                if imageViewModel.isGenerating {
                    ProgressView(value: imageViewModel.generationProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.white)
                        .frame(width: 200)
                    
                    Text("\(Int(imageViewModel.generationProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

// MARK: - Chat Message Row
struct ChatMessageRow: View {
    let message: ChatMessage
    let onGenerateComic: () -> Void
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.7, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("AI Assistant")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                    
                    // Generate Comic Button for AI responses
                    Button(action: onGenerateComic) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.closed.fill")
                                .font(.caption)
                            Text("Create Comic")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

// MARK: - Chat ViewModel
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    func sendMessage(_ content: String) async {
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            content: content,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Send request to AI API
            let aiResponse = try await networkService.sendAIChatMessage(question: content)
            
            let aiMessage = ChatMessage(
                id: UUID(),
                content: aiResponse.answer,
                isFromUser: false,
                timestamp: Date()
            )
            
            messages.append(aiMessage)
            
        } catch {
            // Handle error - show fallback response
            let errorMessage = ChatMessage(
                id: UUID(),
                content: "I'm sorry, I'm having trouble connecting to the AI service right now. Please try again later or check your internet connection.",
                isFromUser: false,
                timestamp: Date()
            )
            
            messages.append(errorMessage)
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Fullscreen Image View
struct FullscreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let authViewModel = AuthViewModel()
    
    // Mock data for preview
    authViewModel.currentUser = User(
        id: 1,
        name: "John",
        surname: "Doe",
        type: "adult",
        email: "john.doe@example.com"
    )
    
    return ChatView(authViewModel: authViewModel)
}
