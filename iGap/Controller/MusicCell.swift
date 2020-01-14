import UIKit
import AVFoundation
import MediaPlayer
import RxSwift

protocol MusicCellDelegate {
    func playSelectedMusic(cell: MusicCell,music : IGFile)
}
class MusicCell : UITableViewCell {
    var delegate : MusicCellDelegate?
    var attachment : IGFile!
    var room : IGRoom!
    var fileExist : Bool = false
    let disposeBag = DisposeBag()
    var music : Music? {
        didSet {
            
            //            musicCover.image = music?.MusicCover
            musicNameLabel.text = music?.MusicName
            //            musicArtistLabel.text = music?.MusicArtist
            //            musicTotalTime = music!.MusicTotalTime
        }
    }
    
    var musicNameLabel = UILabel()
    var btnDownload = UIButton()
    var indicatorViewAbs = IGProgress()
    
    var musicCoverGif : UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .clear
        return imgView
    }()
    var musicTotalTime : Float = 0
    private let musicCoverHolder : UIView = {
        let holder = UIView()
        holder.backgroundColor = ThemeManager.currentTheme.LabelGrayColor
        holder.layer.cornerRadius = 15
        holder.clipsToBounds = true
        return holder
    }()
    private let musicArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.backgroundColor = ThemeManager.currentTheme.LabelGrayColor
        lbl.numberOfLines = 0
        return lbl
    }()
    var musicCoverLabel = UILabel()
    var musicState = UILabel()
    var nameAndButtonStackView = UIStackView()
    
    
    private let musicCover : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    
    var showGif : Bool = false
    
    func getMetadata(file : IGFile!) {
        
        let path = attachment!.path()
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        let metadataList = playerItem.asset.commonMetadata
        var nowPlayingInfo = [String : Any]()
        
        let artworkItems = AVMetadataItem.metadataItems(from: metadataList, filteredByIdentifier: AVMetadataIdentifier.commonIdentifierArtwork)
        
        if let artworkItem = artworkItems.first {
            // Coerce the value to an NSData using its dataValue property
            if let imageData = artworkItem.dataValue {
                DispatchQueue.global(qos: .userInteractive).async {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.musicCover.image = image
                    }
                }
            }
            
            // process image
        } else {
            let avatarView : UIImageView = UIImageView()
            avatarView.setThumbnail(for: file)
            
            
            if let image = avatarView.image {
                musicCover.image = image
                
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        addSubview(musicCoverLabel)
        addSubview(musicCoverHolder)
        addSubview(nameAndButtonStackView)
        addSubview(indicatorViewAbs)
        nameAndButtonStackView.axis = .horizontal
        nameAndButtonStackView.distribution = .fillProportionally
        nameAndButtonStackView.alignment = .fill
        
        nameAndButtonStackView.addArrangedSubview(musicNameLabel)
        nameAndButtonStackView.addArrangedSubview(musicState)
        
        //        addSubview(musicArtistLabel)
        musicCoverHolder.addSubview(musicCoverLabel)
        musicCoverHolder.addSubview(musicCover)
        musicCoverHolder.backgroundColor = ThemeManager.currentTheme.LabelGrayColor
        
        makeMusicCoverHolder()
        makeMusicCoverLabel()
        makestackView()
        makeNameLabel()
        makeMusicCoverImage()
        makeMusicState()
        //        makeBtnDownload()
//        self.backgroundColor = .purple
        
    }
    func setMusic(roomMessage: IGRoomMessage) {
        if roomMessage.attachment!.name!.contains(".mp3") {
            self.musicNameLabel.text = roomMessage.attachment!.name!.replacingOccurrences(of: ".mp3", with: "")
        } else {
            self.musicNameLabel.text = roomMessage.attachment!.name!
        }
        self.attachment = roomMessage.attachment!
        
        
        let fileExist = IGGlobal.isFileExist(path: roomMessage.attachment!.path(), fileSize: roomMessage.attachment!.size)
        if fileExist {
            self.indicatorViewAbs.isHidden = true
            self.fileExist = true
        } else {
            self.indicatorViewAbs.isHidden = false
            self.fileExist = false
            
        }
        
        if !fileExist {
            if attachment != nil  {
                makeIndicatorViewAbs()
                setMediaIndicator(file: self.attachment)
            }
        }
        getMetadata(file: self.attachment)
        musicState.isHidden = true
    }
    private func makeMusicState() {
        musicState.font = UIFont.iGapFonticon(ofSize: 20)
        musicState.textAlignment = .center
        musicState.text = "🎗"
        musicState.translatesAutoresizingMaskIntoConstraints = false
        musicState.widthAnchor.constraint(equalToConstant: 100).isActive = true

    }
    private func makeIndicatorViewAbs() {
        indicatorViewAbs.setFileType(.download)
        indicatorViewAbs.setPercentage(self.attachment.downloadUploadPercent)
        
        indicatorViewAbs.translatesAutoresizingMaskIntoConstraints = false
        indicatorViewAbs.topAnchor.constraint(equalTo: musicCoverHolder.topAnchor, constant: -10).isActive = true
        indicatorViewAbs.bottomAnchor.constraint(equalTo: musicCoverHolder.bottomAnchor, constant: 10).isActive = true
        indicatorViewAbs.leftAnchor.constraint(equalTo: musicCoverHolder.leftAnchor, constant: 10).isActive = true
        indicatorViewAbs.rightAnchor.constraint(equalTo: musicCoverHolder.rightAnchor, constant: -10).isActive = true
        
    }
    private func makeMusicCoverImage() {
        musicCover.contentMode = .scaleToFill
        musicCover.translatesAutoresizingMaskIntoConstraints = false
        musicCover.topAnchor.constraint(equalTo: musicCoverHolder.topAnchor, constant: 0).isActive = true
        musicCover.bottomAnchor.constraint(equalTo: musicCoverHolder.bottomAnchor, constant: 0).isActive = true
        musicCover.leftAnchor.constraint(equalTo: musicCoverHolder.leftAnchor, constant: 0).isActive = true
        musicCover.rightAnchor.constraint(equalTo: musicCoverHolder.rightAnchor, constant: 0).isActive = true
        
    }
    private func makeMusicCoverLabel() {
        musicCoverLabel.font = UIFont.iGapFonticon(ofSize: 30)
        musicCoverLabel.backgroundColor = ThemeManager.currentTheme.LabelGrayColor
        musicCoverLabel.textAlignment = .center
        musicCoverLabel.numberOfLines = 0
        
        musicCoverLabel.translatesAutoresizingMaskIntoConstraints = false
        musicCoverLabel.topAnchor.constraint(equalTo: musicCoverHolder.topAnchor, constant: 0).isActive = true
        musicCoverLabel.bottomAnchor.constraint(equalTo: musicCoverHolder.bottomAnchor, constant: 0).isActive = true
        musicCoverLabel.leftAnchor.constraint(equalTo: musicCoverHolder.leftAnchor, constant: 0).isActive = true
        musicCoverLabel.rightAnchor.constraint(equalTo: musicCoverHolder.rightAnchor, constant: 0).isActive = true
    }
    private func makeMusicCoverHolder() {
        musicCoverHolder.layer.cornerRadius = 10
        musicCoverHolder.clipsToBounds = true
        musicCoverHolder.translatesAutoresizingMaskIntoConstraints = false
        musicCoverHolder.heightAnchor.constraint(equalToConstant: 50).isActive = true
        musicCoverHolder.widthAnchor.constraint(equalToConstant: 50).isActive = true
        musicCoverHolder.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        musicCoverHolder.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
    }
    private func makestackView() {
        nameAndButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        nameAndButtonStackView.topAnchor.constraint(equalTo: musicCoverHolder.topAnchor, constant: 0).isActive = true
        nameAndButtonStackView.bottomAnchor.constraint(equalTo: musicCoverHolder.bottomAnchor, constant: 0).isActive = true
        
        nameAndButtonStackView.leftAnchor.constraint(equalTo: musicCoverHolder.rightAnchor, constant: 10).isActive = true
        nameAndButtonStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
    }
    private func makeNameLabel() {
        musicNameLabel.numberOfLines = 1
        musicNameLabel.textAlignment = .left
//        musicNameLabel.textColor = ThemeManager.currentTheme.LabelColor
        musicNameLabel.font = UIFont.igFont(ofSize: 13 , weight: .bold)
    }
    private func makeBtnDownload() {
        
        btnDownload.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnDownload.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnDownload.setTitle("", for: .normal)
        btnDownload.translatesAutoresizingMaskIntoConstraints = false
        btnDownload.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    func setMediaIndicator(file: IGFile!) {
        if let msgAttachment = file {
            if let messageAttachmentVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.cacheID!) {
                self.attachment = messageAttachmentVariableInCache.value
            } else {
                self.attachment = msgAttachment.detach()
                //let attachmentRef = ThreadSafeReference(to: msgAttachment)
                IGAttachmentManager.sharedManager.add(attachment: attachment!)
                self.attachment = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.cacheID!)?.value
            }
            
            
            if let variableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: msgAttachment.cacheID!) {
                attachment = variableInCache.value
                variableInCache.asObservable().subscribe({ (event) in
                    DispatchQueue.main.async {
                        self.updateAttachmentDownloadUploadIndicatorView()
                    }
                }).disposed(by: disposeBag)
            }
            
            //MARK: ▶︎ Rx End
            if attachment != nil {
            switch (attachment.type) {
            case .audio:
                self.indicatorViewAbs.isHidden = false
                let progress = Progress(totalUnitCount: 100)
                progress.completedUnitCount = 0
                
                self.musicCover.setThumbnail(for: msgAttachment)
                
                if msgAttachment.status != .ready {
                    self.indicatorViewAbs.delegate = self
                }
            default:
                break
            }
            }
        }
    }
    
    func updateAttachmentDownloadUploadIndicatorView() {
        if let attachment = self.attachment {

            if IGGlobal.isFileExist(path: attachment.path(), fileSize: attachment.size) {
                indicatorViewAbs.setState(.ready)
                return
            }
            
            switch attachment.type {
            case .audio :
                self.indicatorViewAbs.setFileType(.download)
                self.indicatorViewAbs.setState(attachment.status)
                if attachment.status == .downloading {
                    self.indicatorViewAbs.setPercentage(attachment.downloadUploadPercent)
                }
            default:
                break
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
extension MusicCell: IGProgressDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGProgress) {
        if let attachment = self.attachment {
            self.indicatorViewAbs.isHidden = true
            
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                self.indicatorViewAbs.isHidden = true
                print("SUCCESS HAPPEND")
                self.getMetadata(file: attachment)
            }, failure: {
                self.indicatorViewAbs.isHidden = false
                
                print("ERROR HAPPEND")
                
            })
        }
        
    }
}
