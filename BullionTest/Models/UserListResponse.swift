//
//  UserListResponse.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

struct UserListResponse: Decodable {
    let status: Int
    let message: String
    let data: UserListData
}

struct UserListData: Decodable {
    let users: [UserRemote]
}

struct UserRemote: Decodable {
    let _id: String
    let name: String?
    let first_name: String?
    let last_name: String?
    let email: String
    let gender: String?
    let date_of_birth: String?
    let phone: String?
    let photo: String?
    let address: String?
    
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        let first = first_name ?? ""
        let last = last_name ?? ""
        let full = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Unknown" : full
    }
}
