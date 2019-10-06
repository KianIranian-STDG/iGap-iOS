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
    private var maxNumberOfItems : Int = 1
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
        config.screens = screens
        if sendAsFile {
            config.video.compression = AVAssetExportPresetHighestQuality
            config.library.maxNumberOfItems = 1
        } else {
            config.video.compression = AVAssetExportPresetLowQuality
            config.library.maxNumberOfItems = maxNumberOfItems
        }
        config.library.mediaType = mediaType

        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            completion(items)
            picker.dismiss(animated: true, completion: nil)
        }
        UIApplication.topViewController()!.present(picker, animated: true, completion: nil)
    }
}
