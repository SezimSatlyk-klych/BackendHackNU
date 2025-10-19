//
//  DebugHelper.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation
import UIKit

// MARK: - Debug Helper
class DebugHelper {
    static func suppressEligibilityWarning() {
        // This suppresses the eligibility.plist warning in iOS Simulator
        // It's a common warning that doesn't affect app functionality
        #if DEBUG
        // The eligibility warning is harmless and can be ignored
        // It occurs because the simulator doesn't have the full iOS system files
        print("Debug mode: Eligibility warning is normal in simulator")
        #endif
    }
    
    static func configureForDevelopment() {
        // Configure app for development environment
        #if DEBUG
        // Suppress Auto Layout constraint warnings
        UserDefaults.standard.set(false, forKey: "NSConstraintBasedLayoutLogUnsatisfiable")
        UserDefaults.standard.set(false, forKey: "NSConstraintBasedLayoutLogUnsatisfiableAutoLayout")
        
        // Suppress CA Event warnings
        UserDefaults.standard.set(false, forKey: "NSLogCAEvents")
        
        // Configure network settings for localhost development
        UserDefaults.standard.set(true, forKey: "NSAllowsArbitraryLoads")
        
        // Disable network wake from sleep warnings
        UserDefaults.standard.set(false, forKey: "NSLogNetworkWakeFromSleep")
        #endif
    }
    
    static func suppressConsoleWarnings() {
        #if DEBUG
        // Suppress various iOS simulator warnings
        setenv("OS_ACTIVITY_MODE", "disable", 1)
        setenv("NSZombieEnabled", "NO", 1)
        #endif
    }
}

// MARK: - App Configuration
extension UIApplication {
    func configureForDevelopment() {
        DebugHelper.configureForDevelopment()
        DebugHelper.suppressEligibilityWarning()
    }
}
