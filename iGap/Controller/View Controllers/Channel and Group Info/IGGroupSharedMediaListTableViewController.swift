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
import SwiftProtobuf
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGGroupSharedMediaListTableViewController: BaseTableViewController {

    @IBOutlet weak var sizeOfSharedVideos: UILabel!
    @IBOutlet weak var sizeOfSharedImage: UILabel!
    @IBOutlet weak var sizeOfSharedAudiosLabel: UILabel!
    @IBOutlet weak var sizeOfSharedFiles: UILabel!
    @IBOutlet weak var sizeOfSharedLinksLabel: UILabel!
    @IBOutlet weak var sizeOfSharedVoice: UILabel!
    @IBOutlet weak var lblImages: UILabel!
    @IBOutlet weak var lblAudios: UILabel!
    @IBOutlet weak var lblVideos: UILabel!
    @IBOutlet weak var lblFiles: UILabel!
    @IBOutlet weak var lblVoices: UILabel!
    @IBOutlet weak var lblLinks: UILabel!

    var selectedRowNum : Int!
    var room: IGRoom?
    var hud = MBProgressHUD()
    var sharedMediaImageFile: [IGRoomMessage] = []
    var sharedMediaAudioFile: [IGRoomMessage] = []
    var sharedMediaVideoFile: [IGRoomMessage] = []
    var sharedMediaLinkFile:  [IGRoomMessage] = []
    var sharedMediaFile:      [IGRoomMessage] = []
    var sharedMediaVoiceFile: [IGRoomMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigation()
        getCountOfImages()
        getCountOfAudio()
        getCountOfVideos()
        getCountOfFile()
        getCountOfVoices()
        getCountOfLinks()
        getCountOfSahredMediaFiles()
    }
    
    private func initNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SHAREDMEDIA".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        lblLinks.text = "LINKS".localizedNew
        lblVideos.text = "VIDEOS".localizedNew
        lblImages.text = "IMAGES".localizedNew
        lblVoices.text = "VOICES".localizedNew
        lblAudios.text = "AUDIOS".localizedNew
        lblFiles.text = "FILES".localizedNew

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedRowNum = indexPath.row
            switch indexPath.row {
            case 0:
                if sharedMediaImageFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false

                self.performSegue(withIdentifier: "showImagesAndVideoSharedMediaCollection", sender: self)
                }
                break
            case 1:
                if sharedMediaAudioFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 2:
                if sharedMediaVideoFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showImagesAndVideoSharedMediaCollection", sender: self)
                }
                break
            case 3:
                if sharedMediaFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 4:
                if sharedMediaVoiceFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }
                break
            case 5:
                if sharedMediaLinkFile.count != 0 {
                    self.tableView.isUserInteractionEnabled = false
                    self.performSegue(withIdentifier: "showLinksAndAudioSharedMediaTableview", sender: self)
                }

            default:
                break
            }
        }
    }
    
    func getCountOfSahredMediaFiles() {
        if let selectedRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGClientCountRoomHistoryRequest.Generator.generate(roomID: selectedRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientCountRoomHistory as IGPClientCountRoomHistoryResponse:
                        let response = IGClientCountRoomHistoryRequest.Handler.interpret(response: clientCountRoomHistory)
                        _ = response.media
                        let audio = response.audio
                        let video = response.video
                        let url = response.url
                        let file = response.file
                        _  = response.gif
                        let image = response.image
                        let voice = response.voice
                        self.sizeOfSharedVideos.text = "\(video)".inLocalizedLanguage()
                        self.sizeOfSharedFiles.text = "\(file)".inLocalizedLanguage()
                        self.sizeOfSharedImage.text = "\(image)".inLocalizedLanguage()
                        self.sizeOfSharedVoice.text = "\(voice)".inLocalizedLanguage()
                        self.sizeOfSharedAudiosLabel.text = "\(audio)".inLocalizedLanguage()
                        self.sizeOfSharedLinksLabel.text = "\(url)".inLocalizedLanguage()
                        self.hud.hide(animated: true)
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        self.hud.hide(animated: true)
                        
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfImages() {
        
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .image).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaImageFile.append(msg)
                            self.tableView.reloadData()
                        }
                        break
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedImage.text = "\(0)"
                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfAudio() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .audio).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaAudioFile.append(msg)
                        }
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedAudiosLabel.text = "\(0)"
                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfVideos() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .video).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaVideoFile.append(msg)
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedVideos.text = "\(0)"

                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfFile() {
        
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .file).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaFile.append(msg)
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedFiles.text = "\(0)"
                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfVoices() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .voice).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaVoiceFile.append(msg)
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedVoice.text = "\(0)"
                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getCountOfLinks() {
        if let selectedRoom = room {
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: 0, filter: .url).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientSearchRoomHistoryResponse as IGPClientSearchRoomHistoryResponse:
                        let response =  IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse , roomId: selectedRoom.id)
                        for message in response.messages.reversed() {
                            let msg = IGRoomMessage(igpMessage: message, roomId: selectedRoom.id)
                            self.sharedMediaLinkFile.append(msg)
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clientSearchRoomHistoryNotFound:
                    DispatchQueue.main.async {
                        self.sizeOfSharedLinksLabel.text = "\(0)"
                    }
                    break
                default:
                    break
                }
                
            }).send()
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImagesAndVideoSharedMediaCollection" {
            let destination = segue.destination as! IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController
            
            destination.room = room
            switch selectedRowNum {
            case 0:
                destination.navigationTitle = "IMAGES".localizedNew
                destination.sharedMedia = sharedMediaImageFile
                destination.sharedMediaFilter = .image
            case 2:
                destination.navigationTitle = "VIDEOS".localizedNew
                destination.sharedMedia = sharedMediaVideoFile
                destination.sharedMediaFilter = .video
            default:
                break
            }
        }
        
        if segue.identifier == "showLinksAndAudioSharedMediaTableview" {
            let destination = segue.destination as! IGChannelAndGroupSharedMediaAudioAndLinkTableViewController
            destination.room = room
            switch selectedRowNum {
            case 1:
                destination.navigationTitle = "AUDIOS".localizedNew
                destination.sharedMedia = sharedMediaAudioFile
                destination.sharedMediaFilter = .audio
            case 3:
                destination.navigationTitle = "FILES".localizedNew
                destination.sharedMedia = sharedMediaFile
                destination.sharedMediaFilter = .file
            case 4:
                destination.navigationTitle = "VOICES".localizedNew
                destination.sharedMedia = sharedMediaVoiceFile
                destination.sharedMediaFilter = .voice
            case 5:
                destination.navigationTitle = "LINKS".localizedNew
                destination.sharedMedia = sharedMediaLinkFile
                destination.sharedMediaFilter = .url
            default:
                break
            }
        }
    }
}
