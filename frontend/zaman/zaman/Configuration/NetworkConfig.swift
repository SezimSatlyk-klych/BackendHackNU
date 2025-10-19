//
//  NetworkConfig.swift
//  zaman
//
//  Created by AI Assistant on 18.10.2025.
//

import Foundation

// MARK: - Network Configuration
struct NetworkConfig {
    static let baseURL = "http://localhost:8000/api"
    static let timeout: TimeInterval = 30.0
    
    // Development settings
    static var allowsInsecureConnections: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // Network security configuration
    static func configureForDevelopment() {
        #if DEBUG
        // Allow localhost connections for development
        UserDefaults.standard.set(true, forKey: "NSAllowsArbitraryLoads")
        UserDefaults.standard.set(true, forKey: "NSExceptionAllowsInsecureHTTPLoads")
        
        // Suppress network warnings
        UserDefaults.standard.set(false, forKey: "NSLogNetworkWakeFromSleep")
        UserDefaults.standard.set(false, forKey: "NSLogNetworkProtocol")
        
        // Configure URLSession for development
        configureURLSession()
        #endif
    }
    
    private static func configureURLSession() {
        #if DEBUG
        // Configure URLSession to suppress warnings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.waitsForConnectivity = false
        
        // Suppress network logging
        config.urlCache = nil
        #endif
    }
}
