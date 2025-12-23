//
//  EnvLoader.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

class EnvLoader {
    static var baseURL: String {
        return loadEnvVar("BASE_URL") ?? "https://api-test.bullionecosystem.com"
    }
    
    private static func loadEnvVar(_ key: String) -> String? {
        // First try to read from ProcessInfo (if set in Scheme)
        if let value = ProcessInfo.processInfo.environment[key] {
            return value
        }
        
        // Fallback: Try to read from a .env file in the bundle
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil),
              let content = try? String(contentsOfFile: path) else {
            return nil
        }
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1).map { String($0) }
            if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == key {
                return parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        
        return nil
    }
}
