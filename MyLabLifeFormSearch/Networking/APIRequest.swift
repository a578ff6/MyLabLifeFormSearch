//
//  APIRequest.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation

/// API請求的協定，任何符合這個協定的型別都需要能夠提供URLRequest並解碼回應數據。
protocol APIRequest {
    /// 將在實作協定時確定具體的回應型別。
    associatedtype Response
    /// 用於實作協定的型別建立網路請求。
    var urlRequest: URLRequest { get }
    /// 用於解碼從API獲得的數據成為相關型別的實例。
    func decodeResponse(data: Data) throws -> Response
}

/// 處理API請求中可能發生的錯誤。
enum APIRequestError: Error {
    case itemNotFound
}
