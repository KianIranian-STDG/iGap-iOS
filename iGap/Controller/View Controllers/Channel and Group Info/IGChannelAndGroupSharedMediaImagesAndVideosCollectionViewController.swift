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
///import INSPhotoGallery
import AVKit
import AVFoundation


private let reuseIdentifier = "SharedMediaImageAndVideoCell"

class IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController: UICollectionViewController , UIGestureRecognizerDelegate {
    
    var sharedMedia: [IGRoomMessage] = []
    var room: IGRoom?
    var hud = MBProgressHUD()
    var shareMediaMessage : Results<IGRoomMessage>!
    var notificationToken: NotificationToken?
    var isFetchingFiles: Bool = false
    var navigationTitle : String!
    var sharedMediaFilter : IGSharedMediaFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let thisRoom = room {
            let messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND isFromSharedMedia == true", thisRoom.id)
            shareMediaMessage =  try! Realm().objects(IGRoomMessage.self).filter(messagePredicate)
            self.notificationToken = shareMediaMessage.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.collectionView?.reloadData()
                    break
                case .update(_, _, _, _):
                    // Query messages have changed, so apply them to the TableView
                    self.collectionView?.reloadData()
                    break
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                    break
                }
            }
        }
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: navigationTitle )
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        let screenRect : CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView?.collectionViewLayout = layout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let current : String = SMLangUtil.loadLanguage()


    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sharedMedia.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SharedMediaImageAndVideoCell", for: indexPath) as! IGChannelAndGroupInfoSharedMediaImagesAndVideosCollectionViewCell
        
        let roomMessage = sharedMedia[indexPath.row]
        
        if roomMessage.type == .image || roomMessage.type == .imageAndText {
            if let sharedAttachment = roomMessage.attachment {
                if sharedAttachment.type == .image {
                    cell.sharedMediaImageView.setThumbnail(for: sharedAttachment)
                    cell.videoSizeLabel.isHidden = true
                    sharedMediaFilter = .image
                    cell.setMediaIndicator(message: roomMessage)
                }
            }
        } else if roomMessage.type == .video || roomMessage.type == .videoAndText {
            if let sharedAttachment = roomMessage.attachment {
                if sharedAttachment.type == .video {
                    cell.sharedMediaImageView.setThumbnail(for: sharedAttachment)
                    cell.videoSizeLabel.text = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: sharedAttachment.size)
                    cell.videoSizeLabel.isHidden = false
                    sharedMediaFilter = .video
                    cell.setMediaIndicator(message: roomMessage)
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var mediaPagerType: MediaPagerType = .image
        if sharedMedia[indexPath.row].type == .video || sharedMedia[indexPath.row].type == .videoAndText {
            mediaPagerType = .video
        }
        
        let mediaPager = IGMediaPager.instantiateFromAppStroryboard(appStoryboard: .Main)
        mediaPager.hidesBottomBarWhenPushed = true
        mediaPager.ownerId = self.room?.id
        mediaPager.messageId = sharedMedia[indexPath.row].id
        mediaPager.mediaPagerType = mediaPagerType
        self.navigationController!.pushViewController(mediaPager, animated: false)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if isFetchingFiles == false {
                loadMoreDataFromServer()
                self.collectionView?.reloadData()
            }
        }
    }
    
    func loadMoreDataFromServer() {
        if let selectedRoom = room {
            isFetchingFiles = true
            self.hud.mode = .indeterminate
            IGClientSearchRoomHistoryRequest.Generator.generate(roomId: selectedRoom.id, offset: Int32(sharedMedia.count), filter: sharedMediaFilter!).successPowerful({ (protoResponse, requestWrapper) in
                if let clientSearchRoomHistoryResponse = protoResponse as? IGPClientSearchRoomHistoryResponse, let request = requestWrapper.message as? IGPClientSearchRoomHistory {
                    let response = IGClientSearchRoomHistoryRequest.Handler.interpret(response: clientSearchRoomHistoryResponse, roomId: request.igpRoomID)
                    IGRoomMessage.managePutOrUpdate(roomId: request.igpRoomID, messages: response.messages, options: IGStructMessageOption(isFromShareMedia: true)) { // need to write messages in database for work with them at "IGMediaPager"
                        DispatchQueue.main.async {
                            for message in response.messages.reversed() {
                                let msg = IGRoomMessage(igpMessage: message, roomId: request.igpRoomID)
                                self.sharedMedia.append(msg)
                            }
                            self.isFetchingFiles = false
                            self.collectionView?.reloadData()
                        }
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.isFetchingFiles = false
                    break

                default:
                    break
                }
                
            }).send()
        }
    }
}

extension IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeIneset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return edgeIneset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect : CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenRect.size.width
        let cellWidth = screenWidth / 3.0
        let size = CGSize(width: cellWidth, height: cellWidth)
        
        return size
    }
}

