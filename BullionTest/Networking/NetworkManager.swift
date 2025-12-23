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
        performRequest(endpoint: endpoint, body: body, isMultipart: false, completion: completion)
    }
    
    func multipartRequest<T: Decodable>(endpoint: APIEndpoint, params: [String: String], imageData: Data?, imageKey: String, completion: @escaping (Result<T, Error>) -> Void) {
        performRequest(endpoint: endpoint, body: params, isMultipart: true, imageData: imageData, imageKey: imageKey, completion: completion)
    }
    
    private func performRequest<T: Decodable>(endpoint: APIEndpoint, body: [String: Any]?, isMultipart: Bool, imageData: Data? = nil, imageKey: String? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint.url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add Bearer Token if available
        if let token = KeychainHelper.standard.readString(service: "bullion-ecosystem", account: "auth-token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if isMultipart {
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = createMultipartBody(params: body as? [String: String] ?? [:], imageData: imageData, imageKey: imageKey ?? "photo", boundary: boundary)
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let body = body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            }
        }
        
        print("🚀 [\(endpoint.method.rawValue)] \(url.absoluteString)")
        
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
            
            // Debug Logging with Truncation
            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let truncatedJson = self.truncateStrings(in: jsonObject)
                print("📥 Response: \(truncatedJson)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = self.parseErrorMessage(from: data) ?? "Server returned \(httpResponse.statusCode)"
                    completion(.failure(NetworkError.serverError(errorMessage)))
                    return
                }
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                if let errorMessage = self.parseErrorMessage(from: data) {
                    completion(.failure(NetworkError.serverError(errorMessage)))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }.resume()
    }
    
    private func createMultipartBody(params: [String: String], imageData: Data?, imageKey: String, boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        for (key, value) in params {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }
        
        if let data = imageData {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"photo.jpg\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            body.append(data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    private func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        if let msgEn = json["err_message_en"] as? String {
            return msgEn
        } else if let msg = json["err_message"] as? String {
            return msg
        } else if let msg = json["message"] as? String {
            return msg
        }
        return nil
    }
    
    private func truncateStrings(in dict: [String: Any]) -> [String: Any] {
        var newDict = dict
        for (key, value) in dict {
            if let str = value as? String, str.count > 100 {
                newDict[key] = String(str.prefix(100)) + "..."
            } else if let innerDict = value as? [String: Any] {
                newDict[key] = truncateStrings(in: innerDict)
            } else if let array = value as? [[String: Any]] {
                newDict[key] = array.map { truncateStrings(in: $0) }
            }
        }
        return newDict
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
