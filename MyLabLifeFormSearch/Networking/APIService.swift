//
//  APIService.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation
import UIKit


/// 實現 APIRequest 協定，專門用來處理對「EOL Search API」的請求。
struct EOLSearchAPIRequest: APIRequest {
    // 儲存搜索條件。
    let searchTerm: String
    
    // urlRequest 根據搜索條件構建的網路請求。
    var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: "https://eol.org/api/search/1.0.json")!
        urlComponents.queryItems = [
            "q": searchTerm,
            "page": "1"
        ].map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        return URLRequest(url: urlComponents.url!)
    }
    
    // 將回應數據轉換為 SearchResponse 結構體，以便後續使用。
    func decodeResponse(data: Data) throws -> SearchResponse {
        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse
    }
}

/// 實現了 APIRequest 協定，用於從EOL Pages API獲取生物的詳細資訊。
struct EOLItemDetailAPIRequest: APIRequest {
    
    // EOLItem 來獲取特定生物的詳細資訊
    let item: EOLItem
    
    // urlRequest 根據生物的ID和需要的查詢參數，建構網路請求
    var urlRequest: URLRequest {
        // EX: https://eol.org/api/pages/1.0/46577088.json?taxonomy=true&images_per_page=1&language=en
        var urlComponents = URLComponents(string: "https://eol.org/api/pages/1.0/\(item.id).json")!
        urlComponents.queryItems = [
            "taxonomy": "true",             // 啟用分類資訊
            "images_per_page": "1",         // 限制圖像數量
            "language": "en"                // 設定語言為英文
        ].map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        return URLRequest(url: urlComponents.url!)
    }
    
    // 將回應數據轉換為 EOLItemDetail 結構體，以便後續使用。
    func decodeResponse(data: Data) throws -> EOLItemDetail {
        let itemDetail = try JSONDecoder().decode(EOLItemDetail.self, from: data)
        return itemDetail
    }
    
}

/// 實現了 APIRequest 協定，用於從EOL HierarchyAPI獲取生物的詳細分類。
struct EOLHierarchyAPIRequest: APIRequest {
    
    // 使用 identifier 來指定要查詢的生物分類詳細資訊
    let identifier: Int
    
    // urlRequest 根據ID和需要的查詢參數，建構網路請求。
    var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: "https://eol.org/api/hierarchy_entries/1.0/" + "\(identifier)" + ".json")!
        urlComponents.queryItems = [
            "language": "en"                        // 設定查詢語言為英文
        ].map({ URLQueryItem(name: $0.key, value: $0.value) })
        
        return URLRequest(url: urlComponents.url!)
    }
    
    // 解碼 API 回傳的 JSON 數據成為 EOLHierarchy
    func decodeResponse(data: Data) throws -> EOLHierarchy {
        let itemDetail = try JSONDecoder().decode(EOLHierarchy.self, from: data)
        return itemDetail
    }
}

/// 將從 EOL API獲取的「圖片URL」轉換成App中可以使用的「UIImage」
struct EOLImageAPIRequest: APIRequest {
    
    // 表示在處理圖片數據時可能發生的錯誤。
    enum ResponseError: Error {
        case invalidImageData
    }
    
    // 圖片的URL地址。
    let url: URL
    
    // URL 封裝成 URLRequest。
    var urlRequest: URLRequest {
        return URLRequest(url: url)
    }
    
    // 從 API 獲得的數據解碼成 UIImage。
    func decodeResponse(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ResponseError.invalidImageData
        }
        
        return image
    }
    
}
