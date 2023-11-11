//
//  EOLItem.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation

// EX: - https://eol.org/api/search/1.0.json?q=Yellow%20Tang&page=1

/// SearchResponse 從 EOL API Search 請求返回的響應。
struct SearchResponse: Codable {
    var results: [EOLItem]
}

/// EOL Search 結果中的單個項目。
struct EOLItem: Codable {
    /// EOL數據庫中該項目的唯一識別碼。
    var id: Int
    /// 該生物的學名。
    var scientificName: String
    /// 該生物的常見名稱或俗稱。
    var commonName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case scientificName = "title"
        case commonName = "content"
    }
}


