//
//  APIConfiguration.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    case login
    case register
    case adminList(offset: Int, limit: Int)
    case userDetail(id: String)
    
    var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .register:
            return "/api/v1/auth/register"
        case .adminList(let offset, let limit):
            return "/api/v1/admin?offset=\(offset)&limit=\(limit)"
        case .userDetail(let id):
            return "/api/v1/admin/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        case .adminList, .userDetail:
            return .get
        }
    }
    
    var url: String {
        return EnvLoader.baseURL + path
    }
}
