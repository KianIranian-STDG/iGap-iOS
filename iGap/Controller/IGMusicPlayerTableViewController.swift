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
import SwiftEventBus


class IGMusicPlayerTableViewController: UITableViewController {
    let cellID = "musicCell"
    var sliderValueIsChanging : Bool = false
    var musics : [Music] = [
        Music(MusicName: "MUSIC1", MusicArtist: "ARTIST1", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC2", MusicArtist: "ARTIST2", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC3", MusicArtist: "ARTIST3", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC4", MusicArtist: "ARTIST4", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC5", MusicArtist: "ARTIST5", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC6", MusicArtist: "ARTIST6", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC7", MusicArtist: "ARTIST7", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC8", MusicArtist: "ARTIST8", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC9", MusicArtist: "ARTIST9", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC10", MusicArtist: "ARTIST10", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC11", MusicArtist: "ARTIST11", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC12", MusicArtist: "ARTIST12", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC13", MusicArtist: "ARTIST13", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC14", MusicArtist: "ARTIST14", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC15", MusicArtist: "ARTIST15", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC16", MusicArtist: "ARTIST16", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC17", MusicArtist: "ARTIST17", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC18", MusicArtist: "ARTIST18", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC19", MusicArtist: "ARTIST19", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC20", MusicArtist: "ARTIST20", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC21", MusicArtist: "ARTIST21", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC22", MusicArtist: "ARTIST22", MusicTotalTime: 0.0),
        Music(MusicName: "MUSIC23", MusicArtist: "ARTIST23", MusicTotalTime: 0.0)
        
    ]
    var currentTime: Float = 0
    var isShortFormEnabled = true
    var headerHeight = 200
    var defaultHeight = 300
    let headerView = UIView()
    var sharedMedia: [IGRoomMessage] = []
    var room: IGRoom?
    var sharedMediaFilter : IGSharedMediaFilter? = .audio
    var shareMediaMessage : Results<IGRoomMessage>!
    var notificationToken: NotificationToken?
    var isFetchingFiles: Bool = false
    private var latestTimeValue: String?
    private var latestSliderValue: Float?
    private var player = IGMusicPlayer.sharedPlayer

    override func viewDidLoad() {
        super.viewDidLoad()
        initTableViewCell()
        
        tableView.tableHeaderView = headerView
        headerView.backgroundColor = UIColor(named: themeColor.modalViewBackgroundColor.rawValue)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: CGFloat(headerHeight)).isActive = true
        headerView.widthAnchor.constraint(equalToConstant: self.tableView.frame.size.width).isActive = true
        panModalSetNeedsLayoutUpdate()
        initPlayerHeaderItems()
        fetchData()
        initEventBus()
        fetchFirstData()
 
        
        
        
    }
    private func fetchFirstData() {
        
        let labels = self.headerView.subviews.flatMap { $0 as? UILabel }
        let timeM = Int(IGGlobal.topBarSongTime / 60)
        let timeS = Int(IGGlobal.topBarSongTime.truncatingRemainder(dividingBy: 60.0))
        
        for label in labels {
            if label.tag == IGTagManager.lblFinalTime {
                label.text = String(timeM).inLocalizedLanguage() + ":" + String(timeS).inLocalizedLanguage()
            }
        }
        
    }
    private func initEventBus() {
        SwiftEventBus.onMainThread(self, name: EventBusManager.updateMediaTimer) { result in
//            print(result?.object as! Float)
                        self.updateProgressView(currentTime: result?.object as! Float)
        }
        SwiftEventBus.onMainThread(self, name: EventBusManager.updateBottomPlayerButtonsState) { result in
//            print(result?.object as! Bool)
            self.updateButtonState(state: result?.object as! Bool)
            
            
        }
        
    }
    
    
    private func fetchData() {
        
        if let thisRoom = room {
            let messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND isFromSharedMedia == true AND typeRaw == audio OR typeRaw == audioAndText", thisRoom.id)
            shareMediaMessage =  try! Realm().objects(IGRoomMessage.self).filter(messagePredicate)
            self.notificationToken = shareMediaMessage.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.tableView.reloadWithAnimation()
                    break
                case .update(_, _, _, _):
                    // Query messages have changed, so apply them to the TableView
                    self.tableView.reloadWithAnimation()
                    break
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                    break
                }
            }
        }
    }
    
    // MARK: - Development Funcs
    private func initTableViewCell() {
        tableView.register(MusicCell.self, forCellReuseIdentifier: cellID)
        
    }
    private func initPlayerHeaderItems() {
        let tmpStackButtons = self.createButtonHolderStack(headerView: self.headerView)
        self.createMusicButtonsInStack(buttonStack: tmpStackButtons)
        self.createMusicDataAboveStack(buttonStack: tmpStackButtons, headerView: self.headerView, currentTime: 0, finalTime: 0, sliderValue: 0)
        self.updateMusicData(currentTime: 0, finalTime: 0, sliderValue: 0, musicName: "", musicArtist: "")
        self.updateSLiderState(currentTime: 0, finalTime: 0, sliderValue: 0)
    }
    private func updateButtonState(state : Bool!) {

        let stacks = self.headerView.subviews.flatMap { $0 as? UIStackView }
        
        for stack in stacks {
            if stack.tag == IGTagManager.srackBottonsHolderTag {
                print(stack.arrangedSubviews)
                print(stack.subviews)
                let btns = stack.arrangedSubviews.flatMap { $0 as? UIButton }
                for btn  in btns {
                    if btn.tag == IGTagManager.btnPlayTag {
                        switch IGGlobal.songState {
                        case .ended :
                            btn.setTitle("🎗", for: .normal)
                            break
                        case .playing :
                            btn.setTitle("🎖", for: .normal)
                            break
                        case .paused :
                            btn.setTitle("🎗", for: .normal)
                            break
                        default:
                            break
                        }

                    }

                }

            }

        }
    }
    func updateProgressView(currentTime : Float!){
        if !currentTime.isNaN  {
        IGGlobal.isPaused = false
            
        let timeM = Int(currentTime / 60)
        let timeS = Int(currentTime.truncatingRemainder(dividingBy: 60.0))
        let percent = ((currentTime * 100) / (IGGlobal.topBarSongTime)) / 100
        self.currentTime = currentTime
        updateSLiderState(currentTime: currentTime, finalTime: (IGGlobal.topBarSongTime), sliderValue: percent)
        }
    }
    
    private func updateMusicData(musicCover: UIImage? = nil,currentTime : Float!,finalTime : Float!,sliderValue: Float!,musicName: String!,musicArtist: String!) {
        
        let labels = self.headerView.subviews.flatMap { $0 as? UILabel }
        
        let imageViews = self.headerView.subviews.flatMap { $0 as? UIImageView }
        for label in labels {
            if label.tag == IGTagManager.lblMusicName {
                label.text = IGGlobal.topBarSongName
            }
            if label.tag == IGTagManager.lblMusicArtist {
                label.text = IGGlobal.topBarSongSinger
            }
            
            
        }
//        for imageView in imageViews {
//            if imageView.tag == IGTagManager.imgMusicCover {
//                imageView.image = UIImage(named: "AppIcon")
//            }
//        }
        
        
        
    }
    private func updateSLiderState(currentTime : Float!,finalTime : Float!,sliderValue: Float) {
        let labels = self.headerView.subviews.flatMap { $0 as? UILabel }
        let sliders = self.headerView.subviews.flatMap { $0 as? UISlider }
        let timeM = Int(currentTime / 60)
        let timeS = Int(currentTime.truncatingRemainder(dividingBy: 60.0))
        
        for label in labels {
            if label.tag == IGTagManager.lblCurrentTime {
                if !(sliderValueIsChanging) {

                label.text = String(timeM).inLocalizedLanguage() + ":" + String(timeS).inLocalizedLanguage()
                }
            }
        }
        for slider in sliders {
            if slider.tag == IGTagManager.sliderMusic {
                if !(sliderValueIsChanging) {
                slider.setValue(sliderValue, animated: true)
                 }
            }
        }
        print(currentTime)
        if IGGlobal.songState == .ended {

            let stacks = self.headerView.subviews.flatMap { $0 as? UIStackView }
            
            for stack in stacks {
                if stack.tag == IGTagManager.srackBottonsHolderTag {
                    let btns = stack.arrangedSubviews.flatMap { $0 as? UIButton }
                    for btn  in btns {
                        if btn.tag == IGTagManager.btnPlayTag {
                            switch IGGlobal.songState {
                            case .ended :
                                btn.setTitle("🎗", for: .normal)
                                break
                            case .playing :
                                btn.setTitle("🎖", for: .normal)
                                break
                            case .paused :
                                btn.setTitle("🎗", for: .normal)
                                break
                            default:
                                break
                            }

                        }

                    }

                }

            }
        }

    }
    private func createButtonHolderStack(headerView: UIView!) -> UIStackView {
        let stackButtonHolder = UIStackView()
        headerView.addSubview(stackButtonHolder)
        stackButtonHolder.tag = IGTagManager.srackBottonsHolderTag
        stackButtonHolder.translatesAutoresizingMaskIntoConstraints = false
        stackButtonHolder.heightAnchor.constraint(equalToConstant: 80).isActive = true
        stackButtonHolder.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        stackButtonHolder.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: 0).isActive = true
        stackButtonHolder.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 0).isActive = true
        stackButtonHolder.axis = .horizontal
        stackButtonHolder.alignment = .fill
        stackButtonHolder.distribution = .fillProportionally
        
        return stackButtonHolder
    }
    private func createMusicButtonsInStack(buttonStack : UIStackView!) {
        let btnPlay = UIButton()
        btnPlay.tag = IGTagManager.btnPlayTag
        let btnNext = UIButton()
        btnNext.isEnabled = false
        btnNext.tag = IGTagManager.btnNextTag
        let btnPrevius = UIButton()
        btnPrevius.isEnabled = false

        btnPrevius.tag = IGTagManager.btnPreviusTag
        let btnOrder = UIButton()
        btnOrder.tag = IGTagManager.btnOrderTag
        let btnShuffle = UIButton()
        btnShuffle.tag = IGTagManager.btnShuffleTag
        //font
        btnPlay.titleLabel?.font = UIFont.iGapFonticon(ofSize: 40)
        btnNext.titleLabel?.font = UIFont.iGapFonticon(ofSize: 40)
        btnPrevius.titleLabel?.font = UIFont.iGapFonticon(ofSize: 40)
        btnShuffle.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnOrder.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        //color
        btnPlay.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
//        btnNext.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
//        btnPrevius.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        btnNext.setTitleColor(UIColor.lightGray, for: .normal)
        btnPrevius.setTitleColor(UIColor.lightGray, for: .normal)
        btnOrder.setTitleColor(UIColor.lightGray, for: .normal)
        btnShuffle.setTitleColor(UIColor.lightGray, for: .normal)

        btnShuffle.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        btnOrder.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        //play
        btnPlay.setTitle("🎗", for: .normal)
        btnNext.setTitle("🎘", for: .normal)
        btnPrevius.setTitle("🎕", for: .normal)
        btnShuffle.setTitle("🎜", for: .normal)
        btnOrder.setTitle("🎛", for: .normal)
        //*****ADD TO STACK*******//
        buttonStack.addArrangedSubview(btnOrder)
        buttonStack.addArrangedSubview(btnPrevius)
        buttonStack.addArrangedSubview(btnPlay)
        buttonStack.addArrangedSubview(btnNext)
        buttonStack.addArrangedSubview(btnShuffle)
        ///update play button state
        switch IGGlobal.songState {
        case .ended :
            btnPlay.setTitle("🎗", for: .normal)
            break
        case .playing :
            btnPlay.setTitle("🎖", for: .normal)
            break
        case .paused :
            btnPlay.setTitle("🎗", for: .normal)
            break
        default:
            break
        }
        //***********ACTIONS******************//
        ///Play/Pause Button action
        btnPlay.addTarget(self, action: #selector(self.buttonPlayAction(_:)), for: .touchUpInside)
        //        ///Next Button action
        //        btnNext.addTarget(self, action: #selector(self.buttonNextAction(_:)), for: .touchUpInside)
        //        ///Previus Button action
        //        btnPrevius.addTarget(self, action: #selector(self.buttonPreviusAction(_:)), for: .touchUpInside)
        //        ///Order Button action
        //        btnOrder.addTarget(self, action: #selector(self.buttonOrderAction(_:)), for: .touchUpInside)
        //        ///Shuffle Button action
        //        btnShuffle.addTarget(self, action: #selector(self.buttonShuffleAction(_:)), for: .touchUpInside)
        
        
        
    }
    //ACTIONS
    @objc func buttonPlayAction(_ sender:UIButton!)
    {
        UIView.transition(with: sender,duration: 0.3, options: .transitionFlipFromTop, animations: {
            if  !(IGGlobal.isPaused){
                sender.setTitle("🎗", for: .normal)
                IGPlayer.shared.pauseMusic()
            }  else {
                sender.setTitle("🎖", for: .normal)
                IGPlayer.shared.playMusic()
            }
        },
                          completion: nil)
        IGGlobal.isPaused = !IGGlobal.isPaused
    }
///SLIDER
    private func addGestureRecognizer(slider: UISlider!,musicCover: UIButton!){
        slider.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderValueChanged(slider:event:)), for: .valueChanged)
        
        
        musicCover.addTarget(self, action: #selector(self.didTapOnMusicCover(_:)), for: .touchUpInside)

    }

    @objc func didTapOnMusicCover(_ sender:UIButton!) {
        

    }
    
    /*************************************************************************/
    /**************************** Gesture Manager ****************************/
    
    @objc func sliderTouchUpInside(_ sender: UISlider) {
//        sliderValueChanged(slider : sender)
    }
    @objc func sliderTouchUpOutside(_ sender: UISlider) {
//        sliderValueChanged(slider : sender)
    }
    @objc func sliderTouchDown(_ sender: UISlider) {
    }
    @objc func sliderValueChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                sliderValueIsChanging = true

                break
                // handle drag began
            case .moved:
                // handle drag moved
                sliderValueIsChanging = true

                latestSliderValue = slider.value
                updateTimer(currentPercent: slider.value)
//                IGPlayer.shared.updateSLider(value: slider.value,sliderBottom: slider)
                player.seekToTime(value: CMTimeMakeWithSeconds(Float64(((slider.value) * (IGGlobal.topBarSongTime / 100)) * 100), preferredTimescale: IGPlayer.shared.attachmentTimeScale))
//                IGPlayer.shared.flag = false
//                IGPlayer.shared.updateSliderValue()
                
                
                break

            case .ended:
                sliderValueIsChanging = false
                let t = slider.value
                slider.value = t

                break
                // handle drag ended
            default:
                break
            }
        }

    }
//    private func sliderValueChanged(slider : UISlider!) {
//        latestSliderValue = slider.value
////        player.seekToTime(value: CMTimeMakeWithSeconds(Float64(slider.value), preferredTimescale: attachmentTimeScale))
////        updateSliderValue(slider: slider)
//    }
    private func updateTimer(currentPercent: Float) {
        let valueInt = Int(currentPercent)
        var tmpCurrentTime = currentPercent * ((IGGlobal.topBarSongTime) / 100)
        tmpCurrentTime = tmpCurrentTime * 100
        let timeM = Int(tmpCurrentTime / 60)
        let timeS = Int(tmpCurrentTime.truncatingRemainder(dividingBy: 60.0))
//        print("TMER CHANGED:",IGGlobal.topBarSongTime,tmpCurrentTime * 100)
        let labels = self.headerView.subviews.flatMap { $0 as? UILabel }
        for label in labels {
            if label.tag == IGTagManager.lblCurrentTime {
                label.text = String(timeM).inLocalizedLanguage() + ":" + String(timeS).inLocalizedLanguage()
            }
        }
//        latestTimeValue = finalValue

    }
    
    

    
    /////END
    private func createMusicDataAboveStack(buttonStack : UIStackView!,headerView : UIView!,musicCover: UIImage? = nil,currentTime : Float!,finalTime : Float!,sliderValue: Float!) {
        //slider - current Time label and music total time
        let musicSlider : UISlider = UISlider()
        let lblCurrentTime : UILabel = UILabel()
        let lblMusicTotalTime : UILabel = UILabel()
        let lblMusicName : UILabel = UILabel()
        let lblMusicArtist : UILabel = UILabel()
//        let tmpMusicCover : UIImageView = UIImageView()
        let tmpMusicCover : UIButton = UIButton()
        musicSlider.tag = IGTagManager.sliderMusic
        lblCurrentTime.tag = IGTagManager.lblCurrentTime
        lblMusicTotalTime.tag = IGTagManager.lblFinalTime
        tmpMusicCover.tag = IGTagManager.imgMusicCover
        lblMusicName.tag = IGTagManager.lblMusicName
        lblMusicArtist.tag = IGTagManager.lblMusicArtist
        tmpMusicCover.layer.cornerRadius = 10
        tmpMusicCover.layer.masksToBounds = true
        
        headerView.addSubview(musicSlider)
        headerView.addSubview(lblCurrentTime)
        headerView.addSubview(lblMusicTotalTime)
        headerView.addSubview(tmpMusicCover)
        headerView.addSubview(lblMusicName)
        headerView.addSubview(lblMusicArtist)
        
        lblCurrentTime.font = UIFont.igFont(ofSize: 10)
        lblMusicTotalTime.font = UIFont.igFont(ofSize: 10)
        lblMusicArtist.font = UIFont.igFont(ofSize: 12, weight: .light)
        lblMusicName.font = UIFont.igFont(ofSize: 13)
        tmpMusicCover.titleLabel?.font = UIFont.iGapFonticon(ofSize: 30)
        lblCurrentTime.textAlignment = .left
        lblMusicName.textAlignment = .left
        lblMusicArtist.textAlignment = .left
        lblMusicTotalTime.textAlignment = .right
        tmpMusicCover.setTitle("", for: .normal)
        tmpMusicCover.setTitleColor(UIColor(named: themeColor.backgroundColor.rawValue), for: .normal)
        tmpMusicCover.backgroundColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        let circleImage = makeCircleWith(size: CGSize(width: 15, height: 15),
                                         backgroundColor: UIColor(named: themeColor.navigationSecondColor.rawValue)!)
        musicSlider.setThumbImage(circleImage, for: .normal)
        musicSlider.setThumbImage(circleImage, for: .highlighted)
        musicSlider.tintColor = UIColor(named: themeColor.navigationSecondColor.rawValue)!
        lblCurrentTime.adjustsFontSizeToFitWidth = true
        lblMusicTotalTime.adjustsFontSizeToFitWidth = true
        
        lblCurrentTime.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        lblMusicTotalTime.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        //labels constraints
        lblCurrentTime.translatesAutoresizingMaskIntoConstraints = false
        lblCurrentTime.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: 5).isActive = true
        lblCurrentTime.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lblCurrentTime.leftAnchor.constraint(equalTo: buttonStack.leftAnchor, constant: 20).isActive = true
        
        lblMusicTotalTime.translatesAutoresizingMaskIntoConstraints = false
        lblMusicTotalTime.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: 5).isActive = true
        lblMusicTotalTime.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lblMusicTotalTime.rightAnchor.constraint(equalTo: buttonStack.rightAnchor, constant: -20).isActive = true
        
        lblMusicArtist.translatesAutoresizingMaskIntoConstraints = false
        lblMusicArtist.bottomAnchor.constraint(equalTo: tmpMusicCover.bottomAnchor, constant: 0).isActive = true
        lblMusicArtist.rightAnchor.constraint(equalTo: buttonStack.rightAnchor, constant: -20).isActive = true
        lblMusicArtist.leftAnchor.constraint(equalTo: tmpMusicCover.rightAnchor, constant: 10).isActive = true
        
        lblMusicName.translatesAutoresizingMaskIntoConstraints = false
        lblMusicName.topAnchor.constraint(equalTo: tmpMusicCover.topAnchor, constant: 0).isActive = true
        lblMusicName.rightAnchor.constraint(equalTo: buttonStack.rightAnchor, constant: -20).isActive = true
        lblMusicName.leftAnchor.constraint(equalTo: tmpMusicCover.rightAnchor, constant: 10).isActive = true
        //Slider constraints
        musicSlider.translatesAutoresizingMaskIntoConstraints = false
        musicSlider.bottomAnchor.constraint(equalTo: lblCurrentTime.topAnchor, constant: -10).isActive = true
        musicSlider.leftAnchor.constraint(equalTo: lblCurrentTime.leftAnchor, constant: 0).isActive = true
        musicSlider.rightAnchor.constraint(equalTo: lblMusicTotalTime.rightAnchor, constant: 0).isActive = true
        //musicCover constraints
        tmpMusicCover.translatesAutoresizingMaskIntoConstraints = false
        tmpMusicCover.bottomAnchor.constraint(equalTo: musicSlider.topAnchor, constant: -5).isActive = true
        tmpMusicCover.leftAnchor.constraint(equalTo: musicSlider.leftAnchor, constant: 0).isActive = true
        tmpMusicCover.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tmpMusicCover.widthAnchor.constraint(equalToConstant: 50).isActive = true
        //slider default Value
        let timeM = Int(self.currentTime / 60)
        let timeS = Int(self.currentTime.truncatingRemainder(dividingBy: 60.0))
        let percent = ((self.currentTime * 100) / (IGGlobal.topBarSongTime)) / 100
        lblCurrentTime.text = String(timeM).inLocalizedLanguage() + ":" + String(timeS).inLocalizedLanguage()
        musicSlider.value = percent

        addGestureRecognizer(slider: musicSlider,musicCover: tmpMusicCover)
        
    }
    fileprivate func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if shareMediaMessage != nil {
            return shareMediaMessage.count
            
        } else {
            return 0
            
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellID) as! MusicCell
        let currentLastItem = shareMediaMessage[indexPath.row]
        let tmppMusic : Music = Music(MusicName: currentLastItem.attachment!.name!, MusicArtist: "",MusicTotalTime: 200.0)
        cell.music = tmppMusic
        
        return cell
    }
    
    
}
extension IGMusicPlayerTableViewController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(300.0) : longFormHeight
    }
    
    var scrollIndicatorInsets: UIEdgeInsets {
        let bottomOffset = presentingViewController?.bottomLayoutGuide.length ?? 0
        return UIEdgeInsets(top: CGFloat(headerHeight), left: 0, bottom: bottomOffset, right: 0)
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        let location = panModalGestureRecognizer.location(in: view)
        return headerView.frame.contains(location)
    }
    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}
