//
//  UserListViewModel.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

class UserListViewModel {
    
    var users: [UserRemote] = []
    
    var onDataLoaded: (() -> Void)?
    var onUserDetailLoaded: ((UserRemote) -> Void)?
    var onError: ((String) -> Void)?
    var onLogout: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    func fetchUsers() {
        onLoading?(true)
        // Structured endpoint
        NetworkManager.shared.request(endpoint: .adminList(offset: 5, limit: 5)) { (result: Result<BaseResponse<[UserRemote]>, Error>) in
            DispatchQueue.main.async {
                self.onLoading?(false)
                switch result {
                case .success(let response):
                    self.users = response.data
                    self.onDataLoaded?()
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchUserDetail(id: String) {
        onLoading?(true)
        NetworkManager.shared.request(endpoint: .userDetail(id: id)) { (result: Result<BaseResponse<UserRemote>, Error>) in
            DispatchQueue.main.async {
                self.onLoading?(false)
                switch result {
                case .success(let response):
                    self.onUserDetailLoaded?(response.data)
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func logout() {
        KeychainHelper.standard.delete(service: "bullion-ecosystem", account: "auth-token")
        onLogout?()
    }
}
