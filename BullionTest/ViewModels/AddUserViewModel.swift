//
//  UserViewModel.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 21/12/25.
//

import Foundation
import UIKit

protocol AddUserViewModelDelegate: AnyObject {
    func onValidationSuccess()
    func onValidationFailure(errors: [String])
    func onPasswordValidationUpdate(isValid: Bool, message: String)
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
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return "Could not process image as JPEG."
        }
        
        // Check size (5MB = 5 * 1024 * 1024 bytes)
        let maxSizeBytes = 5 * 1024 * 1024
        if data.count > maxSizeBytes {
             // Try compressing
             if let compressedData = image.jpegData(compressionQuality: 0.5), compressedData.count <= maxSizeBytes {
                  self.photo = UIImage(data: compressedData)
                  return nil // Success after compression
             } else {
                 return "Image is too large (>5MB)."
             }
        } else {
            self.photo = image
            return nil // Success
        }
    }
    
    func submit() {
        var errors: [String] = []
        
        // 1. Photo Validation
        if photo == nil {
            errors.append("Profile photo is required.")
        }
        
        // 2. Name Validation
        if let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // valid
        } else {
            errors.append("Name is required.")
        }
        
        // 3. Gender Validation
        if genderIndex == -1 {
            errors.append("Gender is required.")
        }
        
        // 4. DOB Validation
        if let dob = dob, !dob.isEmpty {
            // valid
        } else {
            errors.append("Date of Birth is required.")
        }
        
        // 5. Email Validation
        if let email = email, !email.isEmpty {
            if !isValidEmail(email) {
                errors.append("Invalid email format.")
            }
        } else {
            errors.append("Email is required.")
        }
        
        // 6. Phone Validation
        if let phone = phone, !phone.isEmpty {
            if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: phone)) {
                 errors.append("Phone number must contain only numbers.")
            }
        } else {
            errors.append("Phone number is required.")
        }
        
        // 7. Password Validation
        if let pass = password {
            if !isValidPassword(pass) {
                errors.append("Password does not meet requirements.")
            }
        } else {
             errors.append("Password is required.") // implied by regex check usually but good to be explicit
        }
        
        // 8. Confirm Password
        if let confirm = confirmPassword, let pass = password {
            if confirm != pass {
                errors.append("Passwords do not match.")
            }
        } else if confirmPassword == nil {
             // If password was entered but confirm wasn't
             errors.append("Please confirm your password.")
        }
        
        if errors.isEmpty {
            delegate?.onValidationSuccess()
        } else {
            delegate?.onValidationFailure(errors: errors)
        }
    }
    
    // MARK: - Helpers
    
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
