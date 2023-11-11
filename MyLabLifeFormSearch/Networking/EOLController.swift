//
//  EOLController.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import Foundation

/// 負責處理與EOL API的所有互動。
class EOLController {
    /// Singleton Pattern，確保整個 App 中只有一個EOLController的實例。（共享訪問）
    static let shared = EOLController()
    
    /// 泛型方法 sendRequest 處理符合APIRequest協定的任何請求。
    /// Request: APIRequest 確保傳入的請求符合 APIRequest 協定。
    func sendRequest<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIRequestError.itemNotFound
        }
        
        let decodedResponse = try request.decodeResponse(data: data)
        return(decodedResponse)
    }
}


/// Data擴展，增加方法來美化打印JSON數據。
extension Data {
    func prettyPrintedJSONString() {
        // 嘗試將Data對象轉換為JSON對象。
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              // 嘗試將JSON對象轉換為格式化後的JSON數據。
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              // 嘗試將JSON數據轉換為漂亮格式的JSON字符串。
              let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
            print("解析JSON對象失敗。")
            return
        }
        print(prettyJSONString)
    }
}

