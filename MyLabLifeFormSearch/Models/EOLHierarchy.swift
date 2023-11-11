//
//  EOLHierarchy.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation


/// 從 EOL 的 hierarchy_entries API 獲得的分類資訊
struct EOLHierarchy: Codable {
    var ancestors: [Ancestor]?
}

/// 描述單一Ancestor
struct Ancestor: Codable {
    /// 學名
    var scientificName: String
    /// 分類等級，例如 "species"、"genus" 等，可能在某些結果中不存在。
    var taxonRank: String?
}


