/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
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
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
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
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.mail, UIActivityType.message, UIActivityType.openInIBooks, UIActivityType.postToTencentWeibo, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.print]
            } else {
                // Fallback on earlier versions
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.mail, UIActivityType.message, UIActivityType.postToTencentWeibo, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.print ]
            }
            
            viewController.present(activityVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Share Problem", message: "Unfortunately you can't share this file!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(okAction)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
