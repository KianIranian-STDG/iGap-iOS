/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import Social
import MobileCoreServices
import RealmSwift

class ShareViewController: UIViewController, UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnShareData: UIButton!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    
    class User:NSObject {
        let info      :   IGShareInfo
        @objc let name:   String!
        var section   :   Int?
        
        init(info: IGShareInfo){
            self.info = info
            self.name = info.title
        }
    }
    
    class Section  {
        var users:[User] = []
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    
    var contacts : Results<IGShareInfo>!
    var contactSections : [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var tableViewSelectedIndexPath : IndexPath?
    var selectedItemIndexes: [IndexPath]!
    
    var searchText: String?
    var browserInfo: String?
    var shareInfoList: Results<IGShareInfo>!
    var selectedItems: [IGShareInfo] = []
    var selectedChatItemsIdDic: [Int64 : IndexPath] = [:]
    var selectedContactItemsIdDic: [Int64 : IndexPath] = [:]
    var selectedCollectionDic: [Int64 : IndexPath] = [:]
    
    var shareType: String? = nil
    var shareText: String!
    var shareFile: String!
    var shareImageUrl: URL!
    var shareImageOriginal: UIImage!
    var shareVideoData: Data!
    var shareVideoName: String!
    
    let shareWebIdentifiers = [String(kUTTypePropertyList)]
    let shareGifIdentifiers = [String(kUTTypeGIF)]
    
    let shareTextIdentifiers = [String(kUTTypeText), String(kUTTypePlainText), String(kUTTypeUTF8PlainText),
                                String(kUTTypeUTF16ExternalPlainText), String(kUTTypeUTF16PlainText),
                                String(kUTTypeDelimitedText), String(kUTTypeRTF)]
    
    let shareImageIdentifiers = [String(kUTTypeImage), String(kUTTypeJPEG), String(kUTTypeJPEG2000),
                                 String(kUTTypeTIFF), String(kUTTypePICT), String(kUTTypePNG), String(kUTTypeQuickTimeImage),
                                 String(kUTTypeAppleICNS), String(kUTTypeBMP), String(kUTTypeICO), String(kUTTypeRawImage),
                                 String(kUTTypeScalableVectorGraphics)]
    
    let shareVideoIdentifiers = [String(kUTTypeMovie), String(kUTTypeVideo), String(kUTTypeQuickTimeMovie),
                                 String(kUTTypeMPEG), String(kUTTypeMPEG2Video), String(kUTTypeMPEG2TransportStream),
                                 String(kUTTypeMPEG4), String(kUTTypeAppleProtectedMPEG4Video), String(kUTTypeAVIMovie),
                                 String(kUTTypeMPEG2Video)]
    
    
    
    
    let SUITE_NAME = "group.im.iGap"
    let ID = "id"
    let TYPE = "type"
    let ROOM = "room"
    let WEB_DATA = "webData"
    let TEXT = "text"
    let IMAGE = "image"
    let IMAGE_URL = "imageUrl"
    let IMAGE_ORIGINAL = "imageOriginal"
    let VIDEO = "video"
    let VIDEO_DATA = "videoData"
    let VIDEO_NAME = "videoName"
    let GIF = "gif"
    let URL = "url"
    
    @IBAction func btnClick(_ sender: UIButton) {
        shareDataToApp()
    }
    
    @IBAction func segmentChanger(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 1) { // contacts
            let _ = fillContacts(forceFill: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.tag = 1
                self.tableView.reloadData()
            }
        } else if sender.selectedSegmentIndex == 0 { //  recent chats
            fillRecentChats()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.tag = 0
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        getTextShareData()
        getWebShareData()
        getImageShareData()
        getVideoShareData()
        
        ShareConfig.configRealm()
        checkSyncInfo()
        fillRecentChats()
        self.bottomView.isHidden = true
        super.viewDidLoad()
        
        buttonViewCustomize(button: btnShareData)
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        tableView.tag = 0
        
        (searchBar.value(forKey: "cancelButton") as? UIButton)?.isEnabled = true
    }
    
    func buttonViewCustomize(button: UIButton){
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 0.1
        button.layer.shadowOpacity = 0.1
        
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = button.frame.width / 2
    }
    
    private func checkSyncInfo(){
        let realm = try! Realm()
        let recentChats = realm.objects(IGShareInfo.self).filter(NSPredicate(format: "type != %d" , 4))
        let contacts = realm.objects(IGShareInfo.self).filter(NSPredicate(format: "type == %d" , 4))
        
        if recentChats.count == 0 || contacts.count == 0 {
            let alert = UIAlertController(title: "Hint", message: "Please open iGap for sync your info with this page!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func isContactList() -> Bool{
        return tableView.tag == 1
    }
    
    func fillRecentChats() {
        var predicate : NSPredicate!
        
        if searchText != nil && !searchText!.isEmpty {
            predicate = NSPredicate(format: "((title BEGINSWITH[c] %@) OR (title CONTAINS[c] %@)) AND (type != %d)", searchText! , searchText!, 4)
        } else {
            predicate = NSPredicate(format: "type != %d" , 4)
        }
        
        shareInfoList = try! Realm().objects(IGShareInfo.self).filter(predicate)
        tableView.reloadData()
    }
    
    func fillContacts(forceFill: Bool = false) -> [Section] {
        if self.contactSections != nil && !forceFill {
            return self.contactSections!
        }
        
        if searchText != nil && !searchText!.isEmpty {
            let predicate = NSPredicate(format: "((title BEGINSWITH[c] %@) OR (title CONTAINS[c] %@)) AND (type == %d)", searchText! , searchText!, 4)
            contacts = try! Realm().objects(IGShareInfo.self).filter(predicate)
        } else if forceFill {
            let predicate = NSPredicate(format: "(type == %d)", 4)
            contacts = try! Realm().objects(IGShareInfo.self).filter(predicate)
        }
        
        let users :[User] = contacts.map{ (info) -> User in
            let user = User(info: info)
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: User.name))
            return user
        }
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count{
            sections.append(Section())
        }
        for user in users {
            sections[user.section!].addUser(user)
        }
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: User.name)) as! [User]
        }
        self.contactSections = sections
        return self.contactSections!
    }
    
    private func enableButton(enable: Bool = true){
        DispatchQueue.main.async {
            if enable {
                UIView.transition(with: self.bottomView, duration: 0.5, options: .transitionCurlDown, animations: {
                    self.bottomView.isHidden = !enable
                })
            } else {
                UIView.transition(with: self.bottomView, duration: 0.5, options: .transitionCurlUp, animations: {
                    self.bottomView.isHidden = !enable
                })
            }
            self.btnShareData.isEnabled = enable
        }
    }
    
    private func allowShareData(itemProvider: NSItemProvider?, shareType: String) -> String? {
        
        if itemProvider == nil {return nil}
        
        switch shareType {
        case WEB_DATA:
            for webIdentifier in shareWebIdentifiers {
                if itemProvider!.hasItemConformingToTypeIdentifier(webIdentifier) {
                    return webIdentifier
                }
            }
            break
            
        case TEXT:
            for textIdentifier in shareTextIdentifiers {
                if itemProvider!.hasItemConformingToTypeIdentifier(textIdentifier) {
                    return textIdentifier
                }
            }
            break
            
        case IMAGE:
            for imageIdentifier in shareImageIdentifiers {
                if itemProvider!.hasItemConformingToTypeIdentifier(imageIdentifier) {
                    return imageIdentifier
                }
            }
            break
            
        case VIDEO:
            for videoIdentifier in shareVideoIdentifiers {
                if itemProvider!.hasItemConformingToTypeIdentifier(videoIdentifier) {
                    return videoIdentifier
                }
            }
            break
            
        case GIF:
            for gifIdentifier in shareGifIdentifiers {
                if itemProvider!.hasItemConformingToTypeIdentifier(gifIdentifier) {
                    return gifIdentifier
                }
            }
            break
            
        default:
            break
        }
        
        return nil
    }
    
    private func getTextShareData(){
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first
        
        if let identifier = allowShareData(itemProvider: itemProvider, shareType: TEXT) {
            itemProvider!.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                let text = item as! String
                self.shareType = self.TEXT
                self.shareText = text
            })
        } else {
            print("error getTextShareData")
        }
    }
    
    private func getWebShareData(){
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first
        
        if let identifier = allowShareData(itemProvider: itemProvider, shareType: WEB_DATA) {
            itemProvider!.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) -> Void in
                guard let dictionary = item as? NSDictionary else { return }
                OperationQueue.main.addOperation {
                    if let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let urlString = results["URL"] as? String,
                        let url = NSURL(string: urlString) {
                        self.shareType = self.WEB_DATA
                        self.shareText = url.absoluteString
                    }
                }
            })
        } else {
            print("error getWebShareData")
        }
    }
    
    private func getImageShareData(){
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first
        
        if let identifier = allowShareData(itemProvider: itemProvider, shareType: IMAGE) {
            itemProvider!.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) in
                
                if let url = item as? URL{
                    self.shareImageUrl = url
                }
                
                if let img = item as? UIImage{
                    self.shareImageOriginal = img
                } else if self.shareImageUrl != nil {
                    let imageData = try? Data(contentsOf: self.shareImageUrl!)
                    if let image = UIImage(data: imageData!) {
                        self.shareImageOriginal = image
                    }
                } else if let imageData = item as? Data {
                    if let image = UIImage(data: imageData) {
                        self.shareImageOriginal = image
                    }
                } else {
                    return
                }
                
                self.shareType = self.IMAGE
            })
        } else {
            print("error getImageShareData")
        }
    }
    
    private func getVideoShareData(){
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first
        if let identifier = allowShareData(itemProvider: itemProvider, shareType: VIDEO) {
            itemProvider!.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) in
                if let url = item as? URL{
                    let fileData = FileManager.default.contents(atPath: url.path)
                    self.shareVideoName = url.lastPathComponent
                    self.shareVideoData = fileData
                    self.shareType = self.VIDEO
                }
            })
        } else {
            print("error getVideoShareData")
        }
    }
    
    private func getGifShareData(){
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first
        if let identifier = allowShareData(itemProvider: itemProvider, shareType: GIF) {
            itemProvider!.loadItem(forTypeIdentifier: identifier, options: nil, completionHandler: { (item, error) in
                if let url = item as? URL{
                    let fileData = FileManager.default.contents(atPath: url.path)
                    self.shareVideoName = url.lastPathComponent
                    self.shareVideoData = fileData
                    self.shareType = self.VIDEO
                }
            })
        } else {
            print("error getGifShareData")
        }
    }
    
    private func shareDataToApp(){
        if !hasShareData() {return}
        
        if let userDefault = UserDefaults(suiteName: SUITE_NAME) {
            var dict: [[String : Any?]] = []
            
            switch self.shareType {
            case TEXT:
                for (_, info) in selectedItems.enumerated() {
                    dict.append([self.shareType!: self.shareText , ID: info.id, TYPE: info.type])
                }
                userDefault.set(dict, forKey: self.shareType!)
                userDefault.synchronize()
                break
                
            case WEB_DATA:
                for (_, info) in selectedItems.enumerated() {
                    dict.append([self.shareType!: self.shareText , ID: info.id, TYPE: info.type])
                }
                userDefault.set(dict, forKey: self.shareType!)
                userDefault.synchronize()
                break
                
            case IMAGE:
                for (_, info) in selectedItems.enumerated() {
                    dict.append([IMAGE_URL: self.shareImageUrl, IMAGE_ORIGINAL: self.shareImageOriginal , ID: info.id, TYPE: info.type])
                }
                
                let finalData = NSKeyedArchiver.archivedData(withRootObject: dict)
                
                userDefault.set(finalData, forKey: self.shareType!)
                userDefault.synchronize()
                break
                
            case VIDEO:
                for (_, info) in selectedItems.enumerated() {
                    dict.append([VIDEO_DATA: self.shareVideoData! , VIDEO_NAME: self.shareVideoName , ID: info.id, TYPE: info.type])
                }
                
                let finalData = NSKeyedArchiver.archivedData(withRootObject: dict)
                
                userDefault.set(finalData, forKey: self.shareType!)
                userDefault.synchronize()
                break
                
            default:
                break
            }
        }
        closeShareView()
    }
    
    private func closeShareView(){
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func hasShareData() -> Bool {
        if shareType == nil {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Hint", message: "Unfortunatly not detected share data!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                    self.closeShareView()
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            return false
        }
        return true
    }

    func selectItem(info: IGShareInfo, indexPath: IndexPath) {
        self.selectedItems.append(info)
        self.selectedChatItemsIdDic[info.itemId] = indexPath
        self.selectedContactItemsIdDic[info.itemId] = indexPath
        
        bottomCollectionView.performBatchUpdates({
            let index = IndexPath(row: self.selectedItems.count - 1, section: 0)
            self.selectedCollectionDic[info.itemId] = index
            self.bottomCollectionView.insertItems(at: [index])
        }, completion: nil)
        
        if bottomView.isHidden {
            enableButton()
        }
    }

    func deselectItem(indexPath: IndexPath, itemId: Int64) {
        self.selectedItems.remove(at: (indexPath.row))
        
        bottomCollectionView.performBatchUpdates({
            if let _ = self.selectedCollectionDic[itemId] {
                self.selectedCollectionDic.removeValue(forKey: itemId)
                self.bottomCollectionView.deleteItems(at: [indexPath])
            }
        }, completion: nil)
        
        self.selectedChatItemsIdDic.removeValue(forKey: itemId)
        self.selectedContactItemsIdDic.removeValue(forKey: itemId)
        
        if selectedItems.count == 0 {
            enableButton(enable: false)
        }
    }
    
    /************************************ TableView ************************************/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.tableView.tag {
        case 1:
            return self.contactSections!.count
        case 0:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.tableView.tag {
        case 1:
            return self.contactSections![section].users.count
        case 0:
            return self.shareInfoList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shareCell = tableView.dequeueReusableCell(withIdentifier: "ShareCell", for: indexPath) as! ShareCell
        var shareInfo : IGShareInfo!
        if isContactList() {
            shareInfo = self.contactSections![indexPath.section].users[indexPath.row].info
            shareCell.setShareInfo(shareInfo: shareInfo)
            if self.selectedContactItemsIdDic[shareInfo.itemId] != nil && !shareCell.isSelected {
                self.selectedContactItemsIdDic[shareInfo.itemId] = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
                }
            }
            
        } else {
            shareInfo = self.shareInfoList[indexPath.row]
            shareCell.setShareInfo(shareInfo: shareInfo)
            if self.selectedChatItemsIdDic[shareInfo.itemId] != nil && !shareCell.isSelected {
                self.selectedChatItemsIdDic[shareInfo.itemId] = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
                }
            }
        }
        
        return shareCell
    }
    
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String? {
        if self.tableView.tag == 0 {
            return ""
        } else {
            tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
            if !self.contactSections![section].users.isEmpty {
                return self.collation.sectionTitles[section]
            } else {
                return ""
            }
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.isContactList() {
            return self.collation.sectionIndexTitles
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewSelectedIndexPath = indexPath
        if let currentCell = tableView.cellForRow(at: indexPath) as! ShareCell? {
            
            if isContactList() { // contact
                if selectedContactItemsIdDic[currentCell.shareInfo.id] == nil {
                    selectItem(info: currentCell.shareInfo, indexPath: indexPath)
                }
            } else { // recent chat
                if selectedChatItemsIdDic[currentCell.shareInfo.id] == nil {
                    selectItem(info: currentCell.shareInfo, indexPath: indexPath)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if shareInfoList.count > 0 {
            if let currentCell = tableView.cellForRow(at: indexPath) as! ShareCell? {
                for  (index, info) in selectedItems.enumerated() {
                    if info.itemId == currentCell.shareInfo.itemId {
                        deselectItem(indexPath: IndexPath(row: index, section: 0), itemId: currentCell.shareInfo.itemId)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /************************************ SearchBar ************************************/
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeShareView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        (searchBar.value(forKey: "cancelButton") as? UIButton)?.isEnabled = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if self.tableView.tag == 0 { // recente chats
            fillRecentChats()
        } else { // contacts
            let _ = fillContacts(forceFill: true)
        }
        self.tableView.reloadData()
    }
}

extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BottomCellDelegate {
    
    func removeSelected(cell: ShareBottomCell) {
        let indexPath = self.bottomCollectionView.indexPath(for: cell)
        if isContactList() {
            if let indexPath = self.selectedContactItemsIdDic[cell.itemId] {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if let indexPath = self.selectedChatItemsIdDic[cell.itemId] {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        deselectItem(indexPath: indexPath!, itemId: cell.itemId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 70)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shareBottomCell", for: indexPath) as! ShareBottomCell
        cell.setInfo(info: selectedItems[indexPath.row])
        cell.tableViewSelectedIndexPath = self.tableViewSelectedIndexPath
        cell.deselectDelegate = self
        return cell
    }
}
