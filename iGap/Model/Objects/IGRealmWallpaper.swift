/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGRealmWallpaper: Object {
    
    var file                        : List<IGFile>           = List<IGFile>()
    var color                       : List<IGRealmString>    = List<IGRealmString>()
    @objc dynamic var type                        : IGPInfoWallpaper.IGPType.RawValue = IGPInfoWallpaper.IGPType.chatBackground.rawValue
    @objc dynamic var selectedFile  : NSData!
    @objc dynamic var selectedColor : String!
    
    convenience init(wallpapers: [IGPWallpaper] , typeOfWallpaper: IGPInfoWallpaper.IGPType! = .chatBackground) {
        self.init()
        
        for wallpaper in wallpapers {
            let predicate = NSPredicate(format: "cacheID ==[c] %@", wallpaper.igpFile.igpCacheID)
            if let file = try! Realm().objects(IGFile.self).filter(predicate).first {
                self.file.append(file)
            } else {
                self.file.append(IGFile(igpFile : wallpaper.igpFile, type: .image))
            }
            
            let predicateString = NSPredicate(format: "innerString ==[c] %@", wallpaper.igpColor)
            if let color = try! Realm().objects(IGRealmString.self).filter(predicateString).first {
                self.color.append(color)
            } else {
                self.color.append(IGRealmString(string: wallpaper.igpColor))
            }
        }
        self.type = typeOfWallpaper!.rawValue
    }
    
    public static func fetchProfileWallpaper() -> IGFile? {
        let predicateWallpaper = NSPredicate(format: "type = %d", IGPInfoWallpaper.IGPType.profileWallpaper.rawValue)
        if let profileWallpaperList = IGDatabaseManager.shared.realm.objects(IGRealmWallpaper.self).filter(predicateWallpaper).first, let profileWallpaper = profileWallpaperList.file.first {
            return profileWallpaper
        }
        return nil
    }
}
