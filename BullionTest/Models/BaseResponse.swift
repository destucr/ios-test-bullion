//
//  BaseResponse.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let status: Int
    let iserror: Bool
    let message: String
    let data: T
}
