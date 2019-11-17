/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

/* A Class for call popular methods */
class IGHelperPopular {
    
    internal static let shareLinkPrefixGroup = "Open this link to join my iGap Group"
    internal static let shareLinkPrefixChannel = "Open this link to join my iGap Channel"
    
    internal static func shareText(message: String, viewController: UIViewController){
        let textToShare = [message]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    internal static func shareAttachment(url: URL?, viewController: UIViewController){
        
        if url != nil , let urlData = NSData(contentsOf: (url)!){
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let docDirectory = paths[0]
            let filePath = "\(docDirectory)/\(url!.lastPathComponent)"
            urlData.write(toFile: filePath, atomically: true)
            // file saved
            
            let link = NSURL(fileURLWithPath: filePath)
            
            let objectsToShare = [link] //comment!, imageData!, myWebsite!]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.setValue("ShareFile", forKey: "subject")
            
            //New Excluded Activities Code
            if #available(iOS 9.0, *) {
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
            } else {
                // Fallback on earlier versions
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
            }
            
            viewController.present(activityVC, animated: true, completion: nil)
        } else {
            
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "Share Problem", showIconView: true, showDoneButton: false, showCancelButton: true, message: "Unfortunately you can't share this file!", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

        }
    }
}
