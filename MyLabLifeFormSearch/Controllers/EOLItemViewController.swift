//
//  EOLItemViewController.swift
//  MyLabLifeFormSearch
//
//  Created by 曹家瑋 on 2023/11/10.
//

import UIKit
import SafariServices

@MainActor
class EOLItemViewController: UIViewController {

    @IBOutlet weak var eolImageVIew: UIImageView!
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var licenseButton: UIButton!
    // 分類資訊。
    @IBOutlet weak var taxonomySourceLabel: UILabel!
    @IBOutlet weak var scientificNameLabel: UILabel!
    @IBOutlet weak var kingdomLabel: UILabel!
    @IBOutlet weak var phylumLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    @IBOutlet weak var genusLabel: UILabel!
    
    var loadInfoTask: Task<Void, Never>? = nil

    /// 存儲和處理關於獲取的「生物圖像」的版權許可資訊。
    var license: String? = nil
    
    /// 從 EOLSearchTableViewController 傳遞過來的生物項目資料。
    let item: EOLItem
    
    init?(coder: NSCoder,item: EOLItem) {
        self.item = item
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = item.commonName
        
        // 啟動異步任務以載入「詳細資料」和「圖像」。
        loadInfoTask = Task {
            do {
                // 載入生物的詳細資料。
                let itemDetailRequest = EOLItemDetailAPIRequest(item: item)
                let details = try await EOLController.shared.sendRequest(itemDetailRequest)
                
                let taxonConcept = details.details.taxonConcepts?.first
                let dataObject = details.details.dataObjects?.first
                
                // 以異步方式加載分類訊息和圖像。
                // async let 提供更有效率的方法來處理「同時」發送多個非同步請求的情況
                async let hierarchy = classificationDetails(for: taxonConcept)
                async let image = image(for: dataObject)
                
                // 更新界面。
                updat(hierarchy: try await hierarchy, image: try await image)
                
                // 更新學名和分類來源Label。
                scientificNameLabel.text = details.details.scientificName
                taxonomySourceLabel.text = details.details.taxonConcepts?.first?.accordingTo ?? ""
                
                // 更新媒體版權詳細資訊。
                updateMediaDetail(with: dataObject)
                
                loadInfoTask = nil

            } catch {
                print(error)
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadInfoTask?.cancel()  // 取消異步任務。
    }
    
    // MARK: - Update UI Methods

    /// 更新分類資訊和圖片。
    func updat(hierarchy: EOLHierarchy?, image: UIImage?) {
        if let hierarchy = hierarchy {
            updateClassificationDetails(with: hierarchy)
        }
        
        if let image = image {
            eolImageVIew.image = image
        }
    }
    
    
    /// 透過id獲取分類資訊。
    func classificationDetails(for taxonConcept: TaxonConcept?) async throws -> EOLHierarchy? {
        
        guard let taxonConcept = taxonConcept else { return nil }
        
        let hierarchyRequest = EOLHierarchyAPIRequest(identifier: taxonConcept.identifier)
        let hierarchy = try await EOLController.shared.sendRequest(hierarchyRequest)
        
        // 回傳獲得的分類詳細資訊。
        return hierarchy
    }
    
    /// 更新分類詳細資訊。
    func updateClassificationDetails(with hierarchy: EOLHierarchy) {
        // 如果 EOLHierarchy 結構中有 ancestors 數據，則進行下列操作。
        if let ancestors = hierarchy.ancestors {
            // 針對每個分類階級（如 kingdom, phylum 等），找到對應的學名並更新相應的Label。
            kingdomLabel.text = ancestors.first(where: {$0.taxonRank == "kindom"})?.scientificName
            phylumLabel.text = ancestors.first(where: {$0.taxonRank == "phylum"})?.scientificName
            classLabel.text = ancestors.first(where: {$0.taxonRank == "class"})?.scientificName
            orderLabel.text = ancestors.first(where: {$0.taxonRank == "order"})?.scientificName
            familyLabel.text = ancestors.first(where: {$0.taxonRank == "family"})?.scientificName
            genusLabel.text = ancestors.first(where: {$0.taxonRank == "genus"})?.scientificName
        }
    }
    
    /// 取得圖片
    func image(for dataObject: DataObject?) async throws -> UIImage? {
        // 檢查是否有提供 mediaURL。
        guard let mediaURL = dataObject?.eolMediaURL else { return nil }
        
        // 建立圖片請求。
        let imageRequest = EOLImageAPIRequest(url: mediaURL)
        // 異步等待發送請求並獲得圖片。如果過程中有任何錯誤，將會拋出異常。
        let image = try await EOLController.shared.sendRequest(imageRequest)
        
        return image
    }
    
    /// 更新媒體版權和授權訊息
    func updateMediaDetail(with dataObject: DataObject?) {
        // 檢查 dataObject 是否存在，若不存在則不執行後續程式碼。
        guard let dataObject = dataObject else { return }
        
        // 使用 Nil-Coalescing Operator 提供預設值
        let rightsHolderText = dataObject.rightsHolder
        let agentText = dataObject.agents?.first.flatMap({ agent in
            [agent.fullName, agent.role].compactMap { $0 }.joined(separator: ",")
        })
        
        // 用 coalescing operator 選擇顯示 rightsHolder 或 agent 的資訊
        attributionLabel.text = rightsHolderText ?? agentText
        
        // 檢查 license，如果有，則更新 licenseButton。
        if let license = dataObject.license {
            self.license = license
            var config = UIButton.Configuration.plain()
            config.title = license
            config.buttonSize = .small
            config.titleAlignment = .center
            licenseButton.configuration = config
            licenseButton.isEnabled = true
        }
    }
    
    // MARK: - Actions

    // 開啟網頁
    @IBAction func licenseButtonTapped(_ sender: UIButton) {
        if let licenseString = license,
           let url = URL(string: licenseString) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
}





