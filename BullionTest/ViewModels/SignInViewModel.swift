//
//  SignInViewModel.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 21/12/25.
//

import Foundation
import CryptoKit

struct LoginData: Decodable {
    let token: String
    let name: String?
    let email: String?
}

class SignInViewModel {
    
    var email: String?
    var password: String?
    
    var onSignInSuccess: (() -> Void)?
    var onSignInFailure: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    func signIn() {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            onSignInFailure?("Please enter email and password.")
            return
        }
        
        onLoading?(true)
        let hashedPassword = sha256(password)
        
        let body: [String: Any] = [
            "email": email,
            "password": hashedPassword
        ]
        
        // Use structured endpoint with BaseResponse wrapper
        NetworkManager.shared.request(endpoint: .login, body: body) { (result: Result<BaseResponse<LoginData>, Error>) in
            DispatchQueue.main.async {
                self.onLoading?(false)
                switch result {
                case .success(let response):
                    // Check if iserror is true despite 200 OK (common API pattern)
                    if response.iserror {
                        self.onSignInFailure?(response.message)
                        return
                    }
                    
                    // Save token securely
                    KeychainHelper.standard.save(response.data.token, service: "bullion-ecosystem", account: "auth-token")
                    self.onSignInSuccess?()
                    
                case .failure(let error):
                    self.onSignInFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    private func sha256(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
