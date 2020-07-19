/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import YPImagePicker

/** Global Class for Pick Image & Video */
class IGHelperMediaPicker {

    static let shared = IGHelperMediaPicker()
    
    private var sendAsFile = false
    private var screens : [YPPickerScreen] = [.library, .video, .photo]
    private var maxNumberOfItems : Int = 10
    private var mediaType : YPlibraryMediaType = .photoAndVideo
    
    func setSendAsFile(_ sendAsFile: Bool) -> IGHelperMediaPicker {
        self.sendAsFile = sendAsFile
        return self
    }
    
    func setScreens(_ screens: [YPPickerScreen]) -> IGHelperMediaPicker {
        self.screens = screens
        return self
    }
    
    func setMaxNumberOfItems(_ maxNumberOfItems: Int) -> IGHelperMediaPicker {
        self.maxNumberOfItems = maxNumberOfItems
        return self
    }
    
    func setMediaType(_ mediaType: YPlibraryMediaType) -> IGHelperMediaPicker {
        self.mediaType = mediaType
        return self
    }
    
    public func pick(completion: @escaping ([YPMediaItem])->()){
        var config = YPImagePickerConfiguration()

        /************************* manage strings *************************/
        config.wordings.libraryTitle = IGStringsManager.Gallery.rawValue.localized
        config.wordings.cameraTitle = IGStringsManager.Camera.rawValue.localized
        config.wordings.next = IGStringsManager.GlobalNext.rawValue.localized
        config.wordings.albumsTitle = IGStringsManager.Albums.rawValue.localized
        config.wordings.cancel = IGStringsManager.GlobalCancel.rawValue.localized
        config.wordings.cover = IGStringsManager.ChooseFrame.rawValue.localized
        config.wordings.crop = IGStringsManager.Clip.rawValue.localized
        config.wordings.done = IGStringsManager.GlobalOK.rawValue.localized
        config.wordings.filter = IGStringsManager.Filter.rawValue.localized
        config.wordings.ok = IGStringsManager.GlobalOK.rawValue.localized
        config.wordings.processing = IGStringsManager.Processing.rawValue.localized
        config.wordings.save = IGStringsManager.GlobalSave.rawValue.localized
        config.wordings.trim = IGStringsManager.Trim.rawValue.localized
        config.wordings.videoTitle = IGStringsManager.Video.rawValue.localized
        config.wordings.warningMaxItemsLimit = IGStringsManager.ErrorMAxSelect.rawValue.localized
        /*
        config.wordings.videoDurationPopup.title = ""
        config.wordings.videoDurationPopup.tooLongMessage = ""
        config.wordings.videoDurationPopup.tooShortMessage = ""
        config.wordings.permissionPopup.cancel = IGStringsManager.GlobalCancel.rawValue.localized
        config.wordings.permissionPopup.grantPermission = ""
        config.wordings.permissionPopup.message = ""
        config.wordings.permissionPopup.title = ""
        */
            
        config.screens = screens
        if sendAsFile {
            config.video.compression = AVAssetExportPresetHighestQuality
            config.library.maxNumberOfItems = 1
        } else {
            config.video.compression = AVAssetExportPresetMediumQuality
            config.library.maxNumberOfItems = maxNumberOfItems
        }
        config.library.mediaType = mediaType
        config.video.minimumTimeLimit = 1
        config.video.recordingTimeLimit = Double.infinity
        config.video.libraryTimeLimit = Double.infinity
        config.video.trimmerMaxDuration = Double.infinity

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            picker.dismiss(animated: true, completion: {
                completion(items)
            })
        }
        config.colors.tintColor = .white // Right bar buttons (actions)
        if let navigationBar = picker.navigationController?.navigationBar {
            var updatedFrame = navigationBar.bounds
            updatedFrame.size.height += navigationBar.frame.origin.y
            let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: [ThemeManager.currentTheme.NavigationFirstColor, ThemeManager.currentTheme.NavigationSecondColor], startPoint: .centerLeft, endPoint: .centerRight)
            navigationBar.isTranslucent = false
            navigationBar.setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
        }
        
        UIApplication.topViewController()!.present(picker, animated: true, completion: nil)
    }
}
