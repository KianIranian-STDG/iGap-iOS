/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import RealmSwift

class IGSettingChatClearChacheTableViewController: BaseTableViewController {
    @IBOutlet weak var lblStickers: UILabel!
    @IBOutlet weak var lblDocuments: IGLabel!
    @IBOutlet weak var lblVoices: IGLabel!
    @IBOutlet weak var lblAudios: IGLabel!
    @IBOutlet weak var lblVideos: IGLabel!
    @IBOutlet weak var lblGifs: IGLabel!
    @IBOutlet weak var lblImages: IGLabel!
    @IBOutlet weak var lblClearData: IGLabel!
    
    @IBOutlet weak var filesSizeLabel: UILabel!
    @IBOutlet weak var VideosSizeLabel: UILabel!
    @IBOutlet weak var audioAndVoicesSizeLabel: UILabel!
    @IBOutlet weak var imagesAndGIFsSize: UILabel!
    
    @IBOutlet weak var txtImages: UILabel!
    @IBOutlet weak var txtGIFs: UILabel!
    @IBOutlet weak var txtAudios: UILabel!
    @IBOutlet weak var txtVoices: UILabel!
    @IBOutlet weak var txtVideos: UILabel!
    @IBOutlet weak var txtDocuments: UILabel!
    @IBOutlet weak var txtStickers: UILabel!
    
    var selectedRows: [Int] = []
    var selectedSize: Int64 = 0
    var imagesSize: Int64 = 0
    var gifsSize: Int64 = 0
    var videosSize: Int64 = 0
    var audiosSize: Int64 = 0
    var voicesSize: Int64 = 0
    var documentsSize: Int64 = 0
    var stickersSize: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        tableView.backgroundColor = UIColor(named: themeColor.tableViewBackground.rawValue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imagesSize = self.computeFileSize(fileType: IGFile.FileType.image.rawValue)
            self.txtImages.text = self.convertFileSize(fileSize: self.imagesSize)
            
            self.gifsSize = self.computeFileSize(fileType: IGFile.FileType.gif.rawValue)
            self.txtGIFs.text = self.convertFileSize(fileSize: self.gifsSize)
            
            self.videosSize = self.computeFileSize(fileType: IGFile.FileType.video.rawValue)
            self.txtVideos.text = self.convertFileSize(fileSize: self.videosSize)
            
            self.audiosSize = self.computeFileSize(fileType: IGFile.FileType.audio.rawValue)
            self.txtAudios.text = self.convertFileSize(fileSize: self.audiosSize)
            
            self.voicesSize = self.computeFileSize(fileType: IGFile.FileType.voice.rawValue)
            self.txtVoices.text = self.convertFileSize(fileSize: self.voicesSize)
            
            self.documentsSize = self.computeFileSize(fileType: IGFile.FileType.file.rawValue)
            self.txtDocuments.text = self.convertFileSize(fileSize: self.documentsSize)
            
            self.documentsSize = self.computeFileSize(fileType: IGFile.FileType.file.rawValue)
            self.txtDocuments.text = self.convertFileSize(fileSize: self.documentsSize)
            
            self.stickersSize = self.computeFileSize(fileType: IGFile.FileType.sticker.rawValue)
            self.txtStickers.text = self.convertFileSize(fileSize: self.stickersSize)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.imagesSize != 0 || self.gifsSize != 0 || self.videosSize != 0 || self.audiosSize != 0 || self.voicesSize != 0 || self.documentsSize != 0 || self.stickersSize != 0 {
                    self.tableView.allowsMultipleSelection = true
                    self.tableView.allowsMultipleSelectionDuringEditing = true
                    self.tableView.setEditing(true, animated: true)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblDocuments.text = "DOCUMENTS".localized
        lblVideos.text = "VIDEOS".localized
        lblImages.text = "IMAGES".localized
        lblVoices.text = "VOICES".localized
        lblAudios.text = "AUDIOS".localized
        lblGifs.text = "GIFS".localized
        lblStickers.text = "STICKERS".localized
        lblClearData.text = "SETTING_CC_CLEAR_DATA".localized
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_CACHE_SETTINGS".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section {
        case 0:
            numberOfRows = 7
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if selectedRows.firstIndex(of: indexPath.row) == nil {
                selectedRows.append(indexPath.row)
            }
        } else if indexPath.section == 1  {
            showConfirmDeleteAlertView()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let index = selectedRows.firstIndex(of: indexPath.row) {
                selectedRows.remove(at: index)
            }
        } else if indexPath.section == 1  {
            showConfirmDeleteAlertView()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func showConfirmDeleteAlertView() {
        
        computeSelectedData()
        if selectedSize == 0 {
            return
        }
        
        let alert = UIAlertController(title: "MSG_SURE_TO_DELETE_CACHE".localized, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "BTN_DELETE".localized, style: .destructive , handler: { (alert: UIAlertAction) -> Void in
            DispatchQueue.main.async {
                self.removeSelectedData()
                self.navigationController?.popViewController(animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func computeSelectedData(){
        selectedSize = 0
        for row in selectedRows {
            switch row {
            case ClearCache.IMAGES.rawValue:
                selectedSize = selectedSize + imagesSize
                break
                
            case ClearCache.GIFS.rawValue:
                selectedSize = selectedSize + gifsSize
                break
                
            case ClearCache.VIDEOS.rawValue:
                selectedSize = selectedSize + videosSize
                break
                
            case ClearCache.AUDIOS.rawValue:
                selectedSize = selectedSize + audiosSize
                break
                
            case ClearCache.VOICES.rawValue:
                selectedSize = selectedSize + voicesSize
                break
                
            case ClearCache.DOCUMENTS.rawValue:
                selectedSize = selectedSize + documentsSize
                break
                
            case ClearCache.STICKERS.rawValue:
                selectedSize = selectedSize + stickersSize
                break
            default:
                break
            }
        }
    }
    
    private func removeSelectedData(){
        for row in selectedRows {
            switch row {
            case ClearCache.IMAGES.rawValue:
                self.removeFiles(fileType: IGFile.FileType.image.rawValue)
                break
                
            case ClearCache.GIFS.rawValue:
                self.removeFiles(fileType: IGFile.FileType.gif.rawValue)
                break
                
            case ClearCache.VIDEOS.rawValue:
                self.removeFiles(fileType: IGFile.FileType.video.rawValue)
                break
                
            case ClearCache.AUDIOS.rawValue:
                self.removeFiles(fileType: IGFile.FileType.audio.rawValue)
                break
                
            case ClearCache.VOICES.rawValue:
                self.removeFiles(fileType: IGFile.FileType.voice.rawValue)
                break
                
            case ClearCache.DOCUMENTS.rawValue:
                self.removeFiles(fileType: IGFile.FileType.file.rawValue)
                break
                
            case ClearCache.STICKERS.rawValue:
                self.removeFiles(fileType: IGFile.FileType.sticker.rawValue)
                break
            default:
                break
            }
        }
    }
    
    private func computeFileSize(fileType: Int) -> Int64 {
        var size: Int64 = 0
        for file in try! Realm().objects(IGFile.self).filter(NSPredicate(format: "typeRaw = %d", fileType)) {
            if IGGlobal.isFileExist(path: file.path(), fileSize: file.size) {
                size = size + Int64(file.size)
            }
        }
        return size
    }
    
    private func removeFiles(fileType: Int) {
        for file in try! Realm().objects(IGFile.self).filter(NSPredicate(format: "typeRaw = %d", fileType)) {
            if IGGlobal.isFileExist(path: file.path(), fileSize: file.size) {
                IGGlobal.removeFile(path: file.path())
                IGAttachmentManager.sharedManager.variablesCache.removeObject(forKey: file.cacheID! as NSString)
                IGFactory.shared.removeFileNameOnDisk(primaryKeyId: file.cacheID!)
            }
        }
    }
    
    private func convertFileSize(fileSize: Int64) -> String {
        let size = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: Int(fileSize))
        if size.isEmpty {
            return "0 KB"
        }
        return size
    }
}
