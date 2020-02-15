/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation
import AVFoundation

enum NodeRepeatType {
    case none
    case single
    case all
}

protocol IGNodeMusicPlayerDelegate {
    //var mustBeSettable: Int { get set }
    func player(_ player:IGNodeMusicPlayer, didStartPlaying item:AVPlayerItem)
    func player(_ player:IGNodeMusicPlayer, didPausePlaying item:AVPlayerItem)
    func player(_ player:IGNodeMusicPlayer, didStopPlaying item:AVPlayerItem)
}

//func ==(lhs: IGMusicPlayerDelegate, rhs: IGMusicPlayerDelegate) -> Bool {
//    return lhs. == rhs.identifier()
//}
//
//func !=(lhs: IGMusicPlayerDelegate, rhs: IGMusicPlayerDelegate) -> Bool {
//    return lhs.identifier() != rhs.identifier()
//}


class IGNodeMusicPlayer {
    static let sharedPlayer = IGNodeMusicPlayer()
    
    private var player = AVQueuePlayer()
    private var mediaList = [AVPlayerItem]()
    private var filesList = [IGFile]()
    private var currentItems: AVPlayerItem?
    private var currentFile: IGFile?
    private var repeatState: RepeatType = .none
    private var shuffle: Bool = false
    private var currentTime : CMTime?
    
    private var watchers = [IGNodeMusicPlayerDelegate]() //player can have more than one delegate (watcher)
    
    private init() {
        
    }
    
    func play(index: Int, from list: Array<IGFile>) {
        if #available(iOS 10.0, *) {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)), mode: .default,options: [])
        } else {
            // Fallback on earlier versions
        }
        guard let url = list.first?.localUrl else {
            return
        }
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.insert(playerItem, after:nil)
        player.play()
    }
    
    func resume() {
    }
    
    func getCurrentTime() -> CMTime {
        return player.currentTime()
    }
    
    func pause() {
        player.pause()
    }
    
    
    func next() {
    }
    
    func previuos() {
    }
    
    func seekToTime(value : CMTime) {
        player.currentItem?.seek(to: value ,completionHandler: nil)
    }

    
    func setShuffle(_ shuffle:Bool) {
    }
    
    func setRepeat(_ repeatState:RepeatType) {
    }
    
    func addWatcher(_ watcher:IGNodeMusicPlayerDelegate) -> Int {
        watchers.append(watcher)
        return watchers.count - 1
    }
    
    func removeWatcher(at index:Int) {
        watchers.remove(at: index)
    }
    
    func checkPlayerControlStatus() -> Bool {
        if player.rate > 0 {
            return true
        } else {
            return false
        }
    }
    
    func removeItemsFromList() {
        IGGlobal.songState = .ended
        player.removeAllItems()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

