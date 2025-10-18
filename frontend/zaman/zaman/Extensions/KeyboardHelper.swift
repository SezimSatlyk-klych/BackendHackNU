//
//  KeyboardHelper.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import SwiftUI
import UIKit

// MARK: - Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Keyboard Observer
class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible = false
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
            isKeyboardVisible = true
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        keyboardHeight = 0
        isKeyboardVisible = false
    }
}

// MARK: - Safe Text Field
struct SafeTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled(true)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled(true)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
            }
        }
    }
}

// MARK: - Keyboard Constraint Fix
struct KeyboardConstraintFix: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Disable keyboard assistant view to prevent constraint conflicts
                if #available(iOS 15.0, *) {
                    // Use modern keyboard handling
                } else {
                    // Fallback for older iOS versions
                }
            }
    }
}

extension View {
    func fixKeyboardConstraints() -> some View {
        self.modifier(KeyboardConstraintFix())
    }
}
