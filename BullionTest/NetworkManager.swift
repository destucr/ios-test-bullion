//
//  NetworkManager.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received from server"
        case .decodingError: return "Failed to decode response"
        case .serverError(let message): return message
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(endpoint: APIEndpoint, body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add Bearer Token if available
        if let token = KeychainHelper.standard.readString(service: "bullion-ecosystem", account: "auth-token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        print("🚀 [\(endpoint.method.rawValue)] \(url.absoluteString)")
        if let body = body { print("📦 Body: \(body)") }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Transport Error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Debug Logging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Response: \(jsonString)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    var errorMessage = "Server returned \(httpResponse.statusCode)"
                    
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let msgEn = json["err_message_en"] as? String {
                            errorMessage = msgEn
                        } else if let msg = json["err_message"] as? String {
                            errorMessage = msg
                        } else if let msg = json["message"] as? String {
                            errorMessage = msg
                        }
                    }
                    
                    completion(.failure(NetworkError.serverError(errorMessage)))
                    return
                }
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("⚠️ Decoding Error: \(error)")
                
                // Fallback: Check if it's the specific system error even on 200 OK (if API is inconsistent)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let msgEn = json["err_message_en"] as? String {
                    completion(.failure(NetworkError.serverError(msgEn)))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
}
