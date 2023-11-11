//
//  EOLSearchTableViewController.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import UIKit

// EOLSearchTableViewController 負責顯示從 EOL API 搜索到的項目。
class EOLSearchTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    // cell id。
    struct PropertyKeys {
        static let itemCell = "ItemCell"
    }
    
    /// 用於處理異步API請求的任務。
    var searchTask: Task<Void, Never>? = nil
    /// 用於儲存搜索結果的陣列。
    var items = [EOLItem]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - 搜索功能實作
    
    /// fetchMatchingItems 負責發送搜索請求並更新視圖。
    func fetchMatchIngItems() {
        
        self.items = []                 // 清空當前搜索結果。
        self.tableView.reloadData()     // 重新加載表格視圖以清空顯示。
        
        /// 獲取搜索欄的文字。
        let searchTerm = searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            let searchRequest = EOLSearchAPIRequest(searchTerm: searchTerm)
            searchTask?.cancel()    // 取消之前的搜索任務。
            searchTask = Task {
                do {
                    let searchResults = try await EOLController.shared.sendRequest(searchRequest)
                    self.items = searchResults.results      // 更新搜索結果。
                    self.tableView.reloadData()             // 重新加載表格視圖以顯示新結果。
                } catch {
                    print(error)
                }
                searchTask = nil            // 清空搜索任務。
            }
        }
    }
    
    // MARK: - Segue 處理
    
    // 當使用者選擇某個搜索結果時，進行畫面轉換並傳遞相關數據。
    @IBSegueAction func showItemDetails(_ coder: NSCoder, sender: Any?) -> EOLItemViewController? {
        
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        // 獲取選中的項目。
        let item = items[indexPath.row]
        // 傳遞數據到EOLItemViewController。
        return EOLItemViewController(coder: coder, item: item)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // 配置每行的內容。
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemCell, for: indexPath)
        
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.commonName
        content.secondaryText = item.scientificName
        cell.contentConfiguration = content

        return cell
    }

    // MARK: - Table View Delegate
    // 當某行被選中時的處理。
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// MARK: - Extension UISearchBarDelegate

extension EOLSearchTableViewController: UISearchBarDelegate {
    
    // 搜索欄中的搜索按鈕被點擊時的處理。
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchMatchIngItems()
        searchBar.resignFirstResponder()
    }
}
