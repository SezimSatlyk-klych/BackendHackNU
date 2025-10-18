//
//  VoiceView.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI
import AVFoundation

// MARK: - Voice View
struct VoiceView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var voiceViewModel = VoiceViewModel()
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Voice Assistant Header
            voiceAssistantHeader
            
            // Main Content Area
            mainContentArea
            
            // Voice Input Controls
            voiceInputControls
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Voice Assistant Header
    private var voiceAssistantHeader: some View {
        VStack(spacing: 16) {
            // 3D Character Avatar
            ZStack {
                // Outer glowing ring
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 8)
                    .opacity(0.6)
                
                // Inner circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                
                // 3D Character (using SF Symbols to represent a friendly character)
                VStack(spacing: 4) {
                    // Eyes
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                    
                    // Smile
                    Path { path in
                        path.addArc(
                            center: CGPoint(x: 0, y: 0),
                            radius: 12,
                            startAngle: .degrees(0),
                            endAngle: .degrees(180),
                            clockwise: false
                        )
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 24, height: 12)
                }
            }
            
            VStack(spacing: 4) {
                Text("Voice Assistant")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Ask me anything")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.teal, Color.cyan]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Main Content Area
    private var mainContentArea: some View {
        VStack(spacing: 20) {
            // Instructions
            VStack(spacing: 8) {
                Text("Type your question or tap the")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("microphone to record")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Voice Messages (if any)
            if !voiceViewModel.messages.isEmpty {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(voiceViewModel.messages) { message in
                                VoiceMessageRow(message: message)
                                    .id(message.id)
                            }
                            
                            if voiceViewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("AI is processing...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: voiceViewModel.messages.count) { _ in
                        if let lastMessage = voiceViewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    
    // MARK: - AI Avatar View
    private var aiAvatarView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .scaleEffect(voiceViewModel.isListening ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: voiceViewModel.isListening)
            
            Text("Voice Assistant")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Tap to speak or type your message")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.blue)
                    Text("Voice Assistant")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Text("Hi \(authViewModel.currentUser?.name ?? "User"), I'm your voice assistant! You can speak to me or type your message.")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Voice Input Controls
    private var voiceInputControls: some View {
        VStack(spacing: 12) {
            // Preview Label (if needed)
            if voiceViewModel.isListening {
                HStack {
                    Spacer()
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
            }
            
            // Input Controls
            HStack(spacing: 12) {
                // Text Input Field
                TextField("Type or record your question...", text: $messageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .autocorrectionDisabled(true)
                    .onSubmit {
                        sendMessage()
                    }
                
                // Microphone Button
                Button(action: toggleVoiceRecording) {
                    Image(systemName: voiceViewModel.isListening ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(width: 36, height: 36)
                        .background(
                            voiceViewModel.isListening ? Color.red : Color.teal
                        )
                        .cornerRadius(18)
                }
                .disabled(voiceViewModel.isLoading)
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(width: 36, height: 36)
                        .background(
                            messageText.isEmpty ? Color.gray : Color.teal
                        )
                        .cornerRadius(18)
                }
                .disabled(messageText.isEmpty || voiceViewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Text Input View
    private var textInputView: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled(true)
                .onSubmit {
                    sendTextMessage()
                }
            
            Button(action: sendTextMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(messageText.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(messageText.isEmpty || voiceViewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .fixKeyboardConstraints()
    }
    
    // MARK: - Actions
    private func toggleVoiceRecording() {
        if voiceViewModel.isListening {
            voiceViewModel.stopRecording()
        } else {
            voiceViewModel.startRecording()
        }
    }
    
    private func sendTextMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            await voiceViewModel.sendMessage(message)
        }
    }
    
    // MARK: - Send Message (no parameters)
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            await voiceViewModel.sendMessage(message)
        }
    }
}

// MARK: - Voice Message Row
struct VoiceMessageRow: View {
    let message: VoiceMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("You")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
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
                    
                    HStack {
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            // Play audio response
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(maxWidth: .infinity * 0.7, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

// MARK: - Voice ViewModel
@MainActor
class VoiceViewModel: ObservableObject {
    @Published var messages: [VoiceMessage] = []
    @Published var isLoading = false
    @Published var isListening = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    func startRecording() {
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.isListening = true
                    self.setupAudioRecorder()
                    self.audioRecorder?.record()
                }
            }
        }
    }
    
    func stopRecording() {
        isListening = false
        audioRecorder?.stop()
        
        // Process recorded audio (in real app, convert to text)
        let transcribedText = "Voice message transcribed" // Placeholder
        Task {
            await sendMessage(transcribedText)
        }
    }
    
    func sendMessage(_ content: String) async {
        // Add user message
        let userMessage = VoiceMessage(
            id: UUID(),
            content: content,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        isLoading = true
        
        // Simulate AI response (in real app, integrate with OpenAI API)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay
        
        let aiResponse = generateAIResponse(for: content)
        let aiMessage = VoiceMessage(
            id: UUID(),
            content: aiResponse,
            isFromUser: false,
            timestamp: Date()
        )
        
        messages.append(aiMessage)
        isLoading = false
    }
    
    func playLastResponse() {
        // In a real app, play the AI response audio
        print("Playing last AI response audio")
    }
    
    private func setupAudioRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Could not start recording")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func generateAIResponse(for userMessage: String) -> String {
        let lowercasedMessage = userMessage.lowercased()
        
        if lowercasedMessage.contains("balance") || lowercasedMessage.contains("money") {
            return "I can help you check your current balance. Your financial information is available in the Home tab of the app."
        } else if lowercasedMessage.contains("goal") || lowercasedMessage.contains("save") {
            return "I can assist you with your financial goals. You can view and manage your goals in the Home tab under the Goals section."
        } else if lowercasedMessage.contains("transaction") || lowercasedMessage.contains("spending") {
            return "I can help you analyze your spending patterns. Check the History tab for detailed transaction information."
        } else if lowercasedMessage.contains("help") || lowercasedMessage.contains("how") {
            return "I'm your voice assistant! I can help you with balance inquiries, goal tracking, spending analysis, and financial advice. What would you like to know?"
        } else {
            return "Thank you for your message! I'm here to help you with your financial needs. You can ask me about your balance, goals, transactions, or any financial questions."
        }
    }
}

// MARK: - Voice Message Model
struct VoiceMessage: Identifiable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
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
    
    return VoiceView(authViewModel: authViewModel)
        .environmentObject(authViewModel)
}
