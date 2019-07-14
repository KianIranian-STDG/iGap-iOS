//
//  INSPhotoViewController.swift
//  INSPhotoViewer
//
//  Created by Michal Zaborowski on 28.02.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this library except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit
import SnapKit
import AVKit
import RealmSwift

public var isVideo = false

open class INSPhotoViewController: UIViewController, UIScrollViewDelegate  {

    
    var imgVideoPlayAbs: UIImageView!
    var imgMediaAbs: IGImageView!

    var photo: INSPhotoViewable
    var attachment: IGFile?

    var longPressGestureHandler: ((UILongPressGestureRecognizer) -> ())?
    
    lazy private(set) var scalingImageView: INSScalingImageView = {
        return INSScalingImageView()
    }()
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(INSPhotoViewController.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    lazy private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(INSPhotoViewController.handleLongPressWithGestureRecognizer(_:)))
        return gesture
    }()
    
    lazy private(set) var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    lazy private(set) var btnDownLoad: UIButton = {
        let btnDownLoad = UIButton()
        btnDownLoad.layer.cornerRadius = 20.0
//        btnDownLoad.backgroundColor = .white
        btnDownLoad.alpha = 0.8
        btnDownLoad.setImage(nil, for: .normal)

        
        btnDownLoad.addTarget(self, action: #selector(INSPhotoViewController.pressed(sender:)), for: .touchUpInside)
        btnDownLoad.frame.size.height = 50
        btnDownLoad.frame.size.width = 50

        btnDownLoad.isUserInteractionEnabled = true

        return btnDownLoad


    }()

    lazy private(set) var ViewWithDownloadIndicator: IGDownloadUploadIndicatorView = {
        let ViewWithDownloadIndicator = IGDownloadUploadIndicatorView()
        ViewWithDownloadIndicator.setState(.readyToDownload)
        return ViewWithDownloadIndicator
    }()
    public init(photo: INSPhotoViewable) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scalingImageView.delegate = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        scalingImageView.delegate = self
        scalingImageView.frame = view.bounds
        scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scalingImageView)
        view.addSubview(btnDownLoad)
//        view.addSubview(ViewWithDownloadIndicator)
        view.bringSubviewToFront(btnDownLoad)

        view.addSubview(ViewWithDownloadIndicator)
        view.bringSubviewToFront(ViewWithDownloadIndicator)
//        ViewWithDownloadIndicator.center = CGPoint(x: view.bounds.midX - 50, y: view.bounds.midY - 50)
        ViewWithDownloadIndicator.frame.size.width = 100
        ViewWithDownloadIndicator.frame.size.height = 100

        if isAvatar {
        if currentIndexOfImage == nil {
            ViewWithDownloadIndicator.size = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: sizesArray[0]!)
        }
        else {
            ViewWithDownloadIndicator.size = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: sizesArray[currentIndexOfImage] ?? 0)
        }
            self.ViewWithDownloadIndicator.shouldShowSize = true

        }
        else {
           
            self.ViewWithDownloadIndicator.shouldShowSize = false

        }
        self.ViewWithDownloadIndicator.setFileType(.downloadFile)
        self.ViewWithDownloadIndicator.clipsToBounds = true
        self.ViewWithDownloadIndicator.setState(.readyToDownload)
        
        
        
        
        
        btnDownLoad.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        ViewWithDownloadIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
//        view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        activityIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        activityIndicator.sizeToFit()

        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)
        

        
        if let image = photo.image {
            self.scalingImageView.image = image
            self.loadBtnDownload(state: false)
            self.ViewWithDownloadIndicator.removeFromSuperview()


            self.activityIndicator.stopAnimating()
        }
        else if let thumbnailImage = photo.thumbnailImage {
            self.scalingImageView.image = thumbnailImage
            self.activityIndicator.stopAnimating()
            if self.photo.file?.typeRaw == 2 {
                if let attachment = self.photo.file {
                    let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
                    manageAttachment()

                    if fileExist {
                            ViewWithDownloadIndicator.removeFromSuperview()
                            self.btnDownLoad.removeFromSuperview()
                            makeVideoPlayView()
                        ViewWithDownloadIndicator.setState(.ready)
                        return
                    }
                    else {
                        self.scalingImageView.image = self.photo.thumbnailImage
                        
                        ViewWithDownloadIndicator.setFileType(.downloadFile)
                        self.loadBtnDownload(state: true)

                    }
                }
            }
            else {
                self.loadBtnDownload(state: true)

            }
        }
        else {
            if self.photo.file?.typeRaw == 2 {
                print("ISVIDEO")
//                self.loadBtnDownload(state: false)
                if let attachment = self.photo.file {
                    let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
                    if fileExist {
                        if self.photo.file?.typeRaw == 2 {
//                            self.scalingImageView.imageView.setThumbnail(for: self.photo.file!)
//                            print(

                            self.scalingImageView.image = self.photo.thumbnailImage

                            
                            ViewWithDownloadIndicator.removeFromSuperview()
                            self.btnDownLoad.removeFromSuperview()
                            makeVideoPlayView()
                        }
                        
                        ViewWithDownloadIndicator.setState(.ready)

                        return
                    }
                    else {
                        self.scalingImageView.image = self.photo.thumbnailImage

                        ViewWithDownloadIndicator.setFileType(.downloadFile)
                        self.loadBtnDownload(state: true)

                    }
                }
//                makeVideoPlayView()
            }
            else {
                loadThumbnailImage()

            }
        }


    }
    
    private func manageAttachment(file: IGFile? = nil){
        
//        self.view.bringSubviewToFront(ViewWithDownloadIndicator)
//        self.ViewWithDownloadIndicator.isUserInteractionEnabled = true
        
        
        
        if var attachment = photo.file {
            
            if let attachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {

            } else {
                self.attachment = attachment.detach()
                let attachmentRef = ThreadSafeReference(to: attachment)
                IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
               
            }
            

            
            /* Rx Start */
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: attachment.primaryKeyId!) {
                attachment = variableInCache.value

                let string : String! = self.photo.file?.primaryKeyId
                if let disposable = IGGlobal.dispoasDicString[string] {
                    IGGlobal.dispoasDicString.removeValue(forKey: string)
                    disposable.dispose()
                }

                let subscriber = variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
//                        self.updateAttachmentDownloadUploadIndicatorView()
                        self.ViewWithDownloadIndicator.setPercentage(event.element?.downloadUploadPercent ?? 0.0)

                    }
                })
                IGGlobal.dispoasDicString[string] = subscriber
            }
            /* Rx End */


            
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {

        if let attachment = self.photo.file {
            let fileExist = IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size)
            if fileExist {
                if attachment.typeRaw == 2  {
                    makeVideoPlayView()
                }
                
                ViewWithDownloadIndicator.setState(.ready)
               
                if attachment.typeRaw == 0 {
                    self.scalingImageView.imageView.setThumbnail(for: attachment)
                }
                return
            }
            
            if !fileExist {
                ViewWithDownloadIndicator.setFileType(.downloadFile)
            }
            ViewWithDownloadIndicator.setState(attachment.status)
            //if attachment.status == .downloading  {
                print("DOWNLOAD PERCENT :" , attachment.downloadUploadPercent)
                ViewWithDownloadIndicator.setPercentage(attachment.downloadUploadPercent)
            //}
        }
    }
    func makeVideoPlayView(){
        if imgVideoPlayAbs == nil {
            imgVideoPlayAbs = UIImageView()
            imgVideoPlayAbs.image = UIImage(named: "IG_Music_Player_Play")
            imgVideoPlayAbs.image = imgVideoPlayAbs.image!.withRenderingMode(.alwaysTemplate)
            self.scalingImageView.image = self.photo.thumbnailImage

            imgVideoPlayAbs.tintColor = UIColor.white.withAlphaComponent(0.8)
            imgVideoPlayAbs.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            imgVideoPlayAbs.layer.cornerRadius = 10
            self.view.addSubview(imgVideoPlayAbs)
            self.view.bringSubviewToFront(imgVideoPlayAbs)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playTapped(_:)))
            imgVideoPlayAbs.isUserInteractionEnabled = true
            imgVideoPlayAbs.addGestureRecognizer(tapGestureRecognizer)

            
        }
        
        imgVideoPlayAbs?.snp.makeConstraints { (make) in
            make.width.equalTo(35)
            make.height.equalTo(35)
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
    }
    
    func removeVideoPlayView(){
        imgVideoPlayAbs?.removeFromSuperview()
        imgVideoPlayAbs = nil
    }

    @objc private func playTapped(_ recognizer: UITapGestureRecognizer) {
        print("PLAY TAPPED")
        
        if let path = self.photo.file?.path() {
            let player = AVPlayer(url: path)
            let avController = AVPlayerViewController()
            avController.player = player
            player.play()
            present(avController, animated: true, completion: nil)
        }
    }

    @objc func pressed(sender: UIButton!) {
        print("|||||TAPPED|||||")

        
        loadFullSizeImage()
        
    }
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scalingImageView.frame = view.bounds
    }
    private func loadBtnDownload(state : Bool!) {
        
        btnDownLoad.isHidden = !state
        btnDownLoad.isUserInteractionEnabled = state
        if state {
            self.view.addSubview(btnDownLoad)
        }
        else {
            self.btnDownLoad.removeFromSuperview()
            
        }
    }
    private func loadBtnDownloadPause(state : String!) {
        
        if state == "Stop"{
            self.view.addSubview(btnDownLoad)
            self.view.bringSubviewToFront(btnDownLoad)
            btnDownLoad.setImage(UIImage(named: "IG_STOP_PLAYER"), for: .normal)
            
        }
        else {
            self.view.addSubview(btnDownLoad)
            self.view.bringSubviewToFront(btnDownLoad)
            btnDownLoad.setImage(nil, for: .normal)

        }
    }

    private func loadThumbnailImage() {
        
        view.addSubview(btnDownLoad)
        view.bringSubviewToFront(btnDownLoad)

        photo.loadThumbnailImageWithCompletionHandler { [weak self] (image , error) -> () in
            
            let completeLoading = {
                self?.scalingImageView.image = image
                if image != nil {
                    self?.activityIndicator.stopAnimating()
                }
                self?.loadBtnDownload(state: true)
//                self?.loadFullSizeImage()
            }
            
            if Thread.isMainThread {
                completeLoading()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completeLoading()
                })
            }
        }
    }
    
    private func loadFullSizeImage() {
        view.addSubview(activityIndicator)

//        loadBtnDownload(state: false)
        
        activityIndicator.removeFromSuperview()
        self.activityIndicator.stopAnimating()
        self.ViewWithDownloadIndicator.setState(.downloading)
        self.view.bringSubviewToFront(ViewWithDownloadIndicator)
        self.photo.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
            let completeLoading = {
                if self?.photo.file?.typeRaw == 2 {
                    
                    self?.makeVideoPlayView()
                    self?.scalingImageView.imageView.setThumbnail(for: (self?.photo.file)!)

//                    self?.loadBtnDownload(state: false)

                }
                else {
//                    self?.activityIndicator.stopAnimating()
                    
                    self?.scalingImageView.image = image
//                    self?.loadBtnDownload(state: false)

                }

            }
            
            if Thread.isMainThread {
                completeLoading()
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    completeLoading()
                })
            }
        })
    }
    
    @objc private func handleLongPressWithGestureRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            longPressGestureHandler?(recognizer)
        }
    }
    
    
    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scalingImageView.imageView)
        var newZoomScale = scalingImageView.maximumZoomScale
        
        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01 {
            newZoomScale = scalingImageView.minimumZoomScale
        }
        
        let scrollViewSize = scalingImageView.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        scalingImageView.zoom(to: rectToZoom, animated: true)
    }
    
    // MARK:- UIScrollViewDelegate
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scalingImageView.imageView
    }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }
}

extension INSPhotoViewController: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGDownloadUploadIndicatorView) {
        
        if let attachment = self.photo.file {
            if attachment.status == .ready || attachment.status == .readyToDownload{
                IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in }, failure: {})
            }
        }
    }
}
