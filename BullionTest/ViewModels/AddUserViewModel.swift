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
    
    var userId: String? // If present, we are in Edit Mode
    var name: String?
    var genderIndex: Int = -1 // -1 means nothing selected
    var dob: String?
    var email: String?
    var phone: String?
    var photo: UIImage?
    var address: String?
    var password: String?
    var confirmPassword: String?
    
    var isEditMode: Bool { userId != nil }
    
    // MARK: - Logic
    
    func populate(with user: UserRemote) {
        self.userId = user._id
        self.name = user.displayName
        self.email = user.email
        self.phone = user.phone
        self.address = user.address
        
        if let gender = user.gender?.lowercased() {
            self.genderIndex = (gender == "male") ? 0 : 1
        }
        
        if let dobString = user.date_of_birth {
            // ISO -> dd MMMM yyyy
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dobString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "dd MMMM yyyy"
                self.dob = displayFormatter.string(from: date)
            }
        }
        
        if let photoBase64 = user.photo, !photoBase64.isEmpty {
            let cleanBase64 = photoBase64.components(separatedBy: ",").last ?? photoBase64
            if let data = Data(base64Encoded: cleanBase64) {
                self.photo = UIImage(data: data)
            }
        }
    }
    
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
        if !isEditMode && photo == nil { errors.append("Profile photo is required.") }
        if name?.trimmingCharacters(in: .whitespaces).isEmpty ?? true { errors.append("Name is required.") }
        if genderIndex == -1 { errors.append("Gender is required.") }
        if dob?.isEmpty ?? true { errors.append("Date of Birth is required.") }
        if email?.isEmpty ?? true || !isValidEmail(email ?? "") { errors.append("Valid email is required.") }
        if phone?.isEmpty ?? true { errors.append("Phone number is required.") }
        if address?.isEmpty ?? true { errors.append("Address is required.") }
        
        if !isEditMode {
            if !isValidPassword(password ?? "") { errors.append("Password does not meet requirements.") }
            if password != confirmPassword { errors.append("Passwords do not match.") }
        }
        
        if !errors.isEmpty {
            delegate?.onValidationFailure(errors: errors)
            return
        }
        
        delegate?.onLoading(true)
        
        // Prepare API call
        let nameParts = name?.trimmingCharacters(in: .whitespaces).components(separatedBy: " ") ?? []
        let firstName = nameParts.first ?? ""
        let lastName = nameParts.count > 1 ? nameParts.suffix(from: 1).joined(separator: " ") : ""
        
        let gender = genderIndex == 0 ? "male" : "female"
        
        // Format DOB for API (e.g., 1995-08-31T00:00:00.000Z)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMMM yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Parse as UTC midnight
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        outputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var apiDob = dob ?? ""
        if let date = inputFormatter.date(from: dob ?? "") {
            apiDob = outputFormatter.string(from: date)
        }
        
        var params: [String: String] = [
            "first_name": firstName,
            "last_name": lastName,
            "gender": gender,
            "date_of_birth": apiDob,
            "email": email ?? "",
            "phone": phone ?? "",
            "address": address ?? ""
        ]
        
        if !isEditMode {
            params["password"] = sha256(password ?? "")
        }
        
        let photoData = photo?.jpegData(compressionQuality: 0.5)
        let endpoint: APIEndpoint = isEditMode ? .updateUser(id: userId!) : .register
        
        NetworkManager.shared.multipartRequest(endpoint: endpoint, params: params, imageData: photoData, imageKey: "photo") { (result: Result<BaseResponse<LoginData>, Error>) in
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
