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
    @State private var messageText = ""
    
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
                        ChatMessageRow(message: message)
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
}

// MARK: - Chat Message Row
struct ChatMessageRow: View {
    let message: ChatMessage
    
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
        
        // Simulate AI response (in real app, integrate with OpenAI API)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        let aiResponse = generateAIResponse(for: content)
        let aiMessage = ChatMessage(
            id: UUID(),
            content: aiResponse,
            isFromUser: false,
            timestamp: Date()
        )
        
        messages.append(aiMessage)
        isLoading = false
    }
    
    private func generateAIResponse(for userMessage: String) -> String {
        let lowercasedMessage = userMessage.lowercased()
        
        if lowercasedMessage.contains("balance") || lowercasedMessage.contains("money") {
            return "I can help you check your current balance and financial status. Your balance information is available in the Home tab."
        } else if lowercasedMessage.contains("goal") || lowercasedMessage.contains("save") {
            return "I can assist you with setting and tracking your financial goals. You can view your current goals in the Home tab under the Goals section."
        } else if lowercasedMessage.contains("transaction") || lowercasedMessage.contains("spending") {
            return "I can help you analyze your spending patterns and transaction history. Check the History tab for detailed transaction information."
        } else if lowercasedMessage.contains("help") || lowercasedMessage.contains("how") {
            return "I'm here to help you with your financial management! I can assist with balance inquiries, goal tracking, spending analysis, and general financial advice. What would you like to know?"
        } else {
            return "Thank you for your message! I'm here to help you with your financial needs. You can ask me about your balance, goals, transactions, or any other financial questions you might have."
        }
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
