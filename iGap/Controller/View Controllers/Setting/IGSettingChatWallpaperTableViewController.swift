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

class IGSettingChatWallpaperTableViewController: BaseTableViewController, UINavigationControllerDelegate{
    
    var imagePicker = UIImagePickerController()
    var isColorPage    : Bool!
    var wallpaperLocal : NSData?
    
    @IBOutlet weak var lblWallpaperLibrary : UILabel!
    @IBOutlet weak var lblSolidColors : UILabel!
    @IBOutlet weak var lblPhotos : UILabel!
    @IBOutlet weak var lblReset : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
//        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblReset.text = IGStringsManager.Reset.rawValue.localized
        lblPhotos.text = IGStringsManager.Gallery.rawValue.localized
        lblSolidColors.text = IGStringsManager.SolidColors.rawValue.localized
        lblWallpaperLibrary.text = IGStringsManager.ChatBG.rawValue.localized
    }
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.ChatBG.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            numberOfRows = 3
        } else if section == 1 {
            numberOfRows = 1
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // show wallpaper
                isColorPage = false
                performSegue(withIdentifier: "showWallpaperListPage", sender: self)
                break
                
            case 1: // show solid color
                isColorPage = true
                performSegue(withIdentifier: "showWallpaperListPage", sender: self)
                break
                
            case 2:
                GoToPhotoLibrary()
                break
                
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                resetWallpaper()
                break
                
            default:
                break
            }
        }
    }
    
    func GoToPhotoLibrary(){
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func resetWallpaper(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let resetWallpaper = UIAlertAction(title: IGStringsManager.Reset.rawValue.localized, style: .destructive, handler: { (action) in
            IGWallpaperPreview.chatSolidColor = nil
            IGWallpaperPreview.chatWallpaper = nil
            IGFactory.shared.setWallpaperFile(wallpaper: nil)
            IGFactory.shared.setWallpaperSolidColor(solidColor: nil)
        })
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alert.addAction(resetWallpaper)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: {})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWallpaperListPage" {
            let wallpaperList = segue.destination as! IGSettingChatWallpaperLibraryCollectionViewController
            wallpaperList.isColorPage = self.isColorPage
        } else if segue.identifier == "showWallpaperPreview" {
            let wallpaperPreview = segue.destination as! IGWallpaperPreview
            wallpaperPreview.wallpaperLocal = self.wallpaperLocal
        }
    }
}

extension IGSettingChatWallpaperTableViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if imagePicker.sourceType == .photoLibrary {
            if let imageUrl = info["UIImagePickerControllerImageURL"] as? URL {
                
                self.wallpaperLocal = NSData(contentsOf: imageUrl)
                self.isColorPage = false
                performSegue(withIdentifier: "showWallpaperPreview", sender: self)
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
