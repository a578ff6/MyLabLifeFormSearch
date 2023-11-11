//
//  EOLItemDetail.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation


/// 對應從EOL Pages API獲得的JSON數據。
struct EOLItemDetail: Codable {
    /// 生物的詳細資訊
    var details: EOLItemDetails
    
    enum CodingKeys: String, CodingKey {
        case details = "taxonConcept"
    }
}

/// 包含生物的學名、分類概念和相關數據對象。
struct EOLItemDetails: Codable {
    /// 學名
    var scientificName: String
    /// 分類概念
    var taxonConcepts: [TaxonConcept]?
    /// 包含圖像等數據的對象
    var dataObjects: [DataObject]?
}

/// 對應分類概念資訊。
struct TaxonConcept: Codable {
    /// 資訊來源
    var accordingTo: String?
    /// 分類概念的id
    var identifier: Int
    
    enum CodingKeys: String, CodingKey {
        case accordingTo = "nameAccordingTo"
        case identifier
    }
}

/// 包含了與生物相關的媒體數據。
struct DataObject: Codable {
    /// 媒體類型
    var mimeType: String?
    /// 版權訊息
    var license: String?
    /// 版權持有者
    var rightsHolder: String?
    /// 圖像的URL
    var eolMediaURL: URL?
    /// 貢獻者資訊
    var agents: [Agent]?
}

/// 對應與媒體數據相關的貢獻者訊息。
struct Agent: Codable {
    /// 完整名稱
    var fullName: String?
    /// 貢獻者角色
    var role: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case role
    }
}
