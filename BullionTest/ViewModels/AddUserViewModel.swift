//
//  UserViewModel.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 21/12/25.
//

import Foundation
import UIKit
import CryptoKit

protocol AddUserViewModelDelegate: AnyObject {
    func onValidationSuccess()
    func onValidationFailure(errors: [String])
    func onPasswordValidationUpdate(isValid: Bool, message: String)
    func onRegistrationSuccess()
    func onRegistrationFailure(message: String)
    func onLoading(_ isLoading: Bool)
}

class AddUserViewModel {
    
    // MARK: - Properties
    
    weak var delegate: AddUserViewModelDelegate?
    
    var name: String?
    var genderIndex: Int = -1 // -1 means nothing selected
    var dob: String?
    var email: String?
    var phone: String?
    var photo: UIImage?
    var address: String?
    var password: String?
    var confirmPassword: String?
    
    // MARK: - Logic
    
    func updatePassword(_ text: String) {
        self.password = text
        if isValidPassword(text) {
            delegate?.onPasswordValidationUpdate(isValid: true, message: "Password requirements met.")
        } else {
            delegate?.onPasswordValidationUpdate(isValid: false, message: "Min 8 chars, 1 capital, 1 number, alphanumeric.")
        }
    }
    
    func setPhoto(_ image: UIImage) -> String? {
        // Validate Image Size and Format (Simulated by checking data)
        // Ensure JPEG
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            return "Could not process image."
        }
        
        // Check size (5MB = 5 * 1024 * 1024 bytes)
        let maxSizeBytes = 5 * 1024 * 1024
        if data.count > maxSizeBytes {
             return "Image is too large (>5MB)."
        } else {
            self.photo = image
            return nil // Success
        }
    }
    
    func submit() {
        var errors: [String] = []
        
        // Validation logic
        if photo == nil { errors.append("Profile photo is required.") }
        if name?.trimmingCharacters(in: .whitespaces).isEmpty ?? true { errors.append("Name is required.") }
        if genderIndex == -1 { errors.append("Gender is required.") }
        if dob?.isEmpty ?? true { errors.append("Date of Birth is required.") }
        if email?.isEmpty ?? true || !isValidEmail(email ?? "") { errors.append("Valid email is required.") }
        if phone?.isEmpty ?? true { errors.append("Phone number is required.") }
        if address?.isEmpty ?? true { errors.append("Address is required.") }
        if !isValidPassword(password ?? "") { errors.append("Password does not meet requirements.") }
        if password != confirmPassword { errors.append("Passwords do not match.") }
        
        if !errors.isEmpty {
            delegate?.onValidationFailure(errors: errors)
            return
        }
        
        delegate?.onLoading(true)
        
        // Prepare API call
        let nameParts = name?.components(separatedBy: " ") ?? []
        let firstName = nameParts.first ?? ""
        let lastName = nameParts.count > 1 ? nameParts.suffix(from: 1).joined(separator: " ") : firstName
        
        let gender = genderIndex == 0 ? "male" : "female"
        
        // Convert photo to base64
        let photoBase64 = photo?.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
        
        // Format DOB for API (assuming ISO8601)
        // Original dob is "dd/MM/yy"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yy"
        let outputFormatter = ISO8601DateFormatter()
        outputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var apiDob = dob ?? ""
        if let date = inputFormatter.date(from: dob ?? "") {
            apiDob = outputFormatter.string(from: date)
        }
        
        let body: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "gender": gender,
            "date_of_birth": apiDob,
            "email": email ?? "",
            "phone": phone ?? "",
            "address": address ?? "",
            "photo": photoBase64,
            "password": sha256(password ?? "")
        ]
        
        NetworkManager.shared.request(endpoint: .register, body: body) { (result: Result<BaseResponse<LoginData>, Error>) in
            DispatchQueue.main.async {
                self.delegate?.onLoading(false)
                switch result {
                case .success(let response):
                    if response.iserror {
                        self.delegate?.onRegistrationFailure(message: response.message)
                    } else {
                        self.delegate?.onRegistrationSuccess()
                    }
                case .failure(let error):
                    self.delegate?.onRegistrationFailure(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func sha256(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ pass: String) -> Bool {
        if pass.count < 8 { return false }
        let hasCapital = pass.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = pass.range(of: "[0-9]", options: .regularExpression) != nil
        let hasAlphabet = pass.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        return hasCapital && hasNumber && hasAlphabet
    }
}
