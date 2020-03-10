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
import Files
import Digger

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
    
    private func initTheme() {
        lblStickers.textColor = ThemeManager.currentTheme.LabelColor
        lblDocuments.textColor = ThemeManager.currentTheme.LabelColor
        lblVoices.textColor = ThemeManager.currentTheme.LabelColor
        lblAudios.textColor = ThemeManager.currentTheme.LabelColor
        lblVideos.textColor = ThemeManager.currentTheme.LabelColor
        lblGifs.textColor = ThemeManager.currentTheme.LabelColor
        lblImages.textColor = ThemeManager.currentTheme.LabelColor
        lblClearData.textColor = ThemeManager.currentTheme.LabelColor
        filesSizeLabel.textColor = ThemeManager.currentTheme.LabelColor
        VideosSizeLabel.textColor = ThemeManager.currentTheme.LabelColor
        audioAndVoicesSizeLabel.textColor = ThemeManager.currentTheme.LabelColor
        imagesAndGIFsSize.textColor = ThemeManager.currentTheme.LabelColor
        txtImages.textColor = ThemeManager.currentTheme.LabelColor
        txtGIFs.textColor = ThemeManager.currentTheme.LabelColor
        txtAudios.textColor = ThemeManager.currentTheme.LabelColor
        txtVoices.textColor = ThemeManager.currentTheme.LabelColor
        txtVideos.textColor = ThemeManager.currentTheme.LabelColor
        txtDocuments.textColor = ThemeManager.currentTheme.LabelColor
        txtStickers.textColor = ThemeManager.currentTheme.LabelColor
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
    }

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
        tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.imagesSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.IMAGE_DIR)
            self.txtImages.text = self.convertFileSize(fileSize: self.imagesSize)
            
            self.gifsSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.GIF_DIR)
            self.txtGIFs.text = self.convertFileSize(fileSize: self.gifsSize)
            
            self.videosSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.VIDEO_DIR)
            self.txtVideos.text = self.convertFileSize(fileSize: self.videosSize)
            
            self.audiosSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.AUDIO_DIR)
            self.txtAudios.text = self.convertFileSize(fileSize: self.audiosSize)
            
            self.voicesSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.VOICE_DIR)
            self.txtVoices.text = self.convertFileSize(fileSize: self.voicesSize)
            
            self.documentsSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.FILE_DIR)
            self.txtDocuments.text = self.convertFileSize(fileSize: self.documentsSize)
            
            self.stickersSize = self.sizeOfFolder(IGGlobal.APP_DIR + IGGlobal.STICKER_DIR)
            self.txtStickers.text = self.convertFileSize(fileSize: self.stickersSize)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if self.imagesSize != 0 || self.gifsSize != 0 || self.videosSize != 0 || self.audiosSize != 0 || self.voicesSize != 0 || self.documentsSize != 0 || self.stickersSize != 0 {
                    self.tableView.allowsMultipleSelection = true
                    self.tableView.allowsMultipleSelectionDuringEditing = true
                    self.tableView.setEditing(true, animated: true)
                }
            }
        }
        initTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblDocuments.text = IGStringsManager.Documents.rawValue.localized
        lblVideos.text = IGStringsManager.Videos.rawValue.localized
        lblImages.text = IGStringsManager.Images.rawValue.localized
        lblVoices.text = IGStringsManager.Voices.rawValue.localized
        lblAudios.text = IGStringsManager.Audios.rawValue.localized
        lblGifs.text = IGStringsManager.Gifs.rawValue.localized
        lblStickers.text = IGStringsManager.Sticker.rawValue.localized
        lblClearData.text = IGStringsManager.ClearDataUsage.rawValue.localized
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

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
        
        let alert = UIAlertController(title: IGStringsManager.AreYouSure.rawValue.localized, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: IGStringsManager.Delete.rawValue.localized, style: .destructive , handler: { (alert: UIAlertAction) -> Void in
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
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.IMAGE_DIR)
                break
                
            case ClearCache.GIFS.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.GIF_DIR)
                break
                
            case ClearCache.VIDEOS.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.VIDEO_DIR)
                break
                
            case ClearCache.AUDIOS.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.AUDIO_DIR)
                break
                
            case ClearCache.VOICES.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.VOICE_DIR)
                break
                
            case ClearCache.DOCUMENTS.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.FILE_DIR)
                break
                
            case ClearCache.STICKERS.rawValue:
                self.removeFolder(IGGlobal.APP_DIR + IGGlobal.STICKER_DIR)
                break
            default:
                break
            }
        }
        
        IGAppManager.sharedManager.createAppDirectories()
    }
    
    private func sizeOfFolder(_ folderPath: String) -> Int64 {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            var folderSize: Int64 = 0
            for content in contents {
                do {
                    let fullContentPath = folderPath + "/" + content
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fullContentPath)
                    folderSize += fileAttributes[FileAttributeKey.size] as? Int64 ?? 0
                } catch _ {
                    continue
                }
            }

            return folderSize

        } catch let error {
            print(error.localizedDescription)
            return 0
        }
    }
    
    
    private func removeFolder(_ folderPath: String) {
        IGAttachmentManager.sharedManager.variablesCache.removeAllObjects()
        IGDownloadManager.sharedManager.pauseAllDownloads(removePauseListCDN: true)
        IGUploadManager.sharedManager.pauseAllUploads()
        DiggerCache.cleanDownloadFiles()
        try? FileManager.default.removeItem(atPath: folderPath)
    }
    
    private func convertFileSize(fileSize: Int64) -> String {
        let size = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: fileSize)
        if size.isEmpty {
            return "0 KB"
        }
        return size
    }
}
