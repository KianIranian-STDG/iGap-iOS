import UIKit
protocol MusicCellDelegate {
 func playSelectedMusic(cell: MusicCell,music : IGFile)
}
class MusicCell : UITableViewCell {
    var delegate : MusicCellDelegate?
    var music : Music? {
        didSet {
            
//            musicCover.image = music?.MusicCover
            musicNameLabel.text = music?.MusicName
            musicArtistLabel.text = music?.MusicArtist
            musicTotalTime = music!.MusicTotalTime
        }
    }
    
    
    private let musicNameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()

    var musicTotalTime : Float = 0
    
    private let musicArtistLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.backgroundColor = UIColor(named : themeColor.labelGrayColor.rawValue)
        lbl.numberOfLines = 0
        return lbl
    }()
    private let musicCoverLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.iGapFonticon(ofSize: 30)
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
    private let musicCover : UIImageView = {
        let imgView = UIImageView(image: #imageLiteral(resourceName: "IG_Map"))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        return imgView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(musicCoverLabel)
        addSubview(musicNameLabel)
        addSubview(musicArtistLabel)
        musicCoverLabel.layer.cornerRadius = 10
        musicCoverLabel.translatesAutoresizingMaskIntoConstraints = false
        musicCoverLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        musicCoverLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        musicCoverLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        musicCoverLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true

        musicNameLabel.numberOfLines = 1
        musicNameLabel.textAlignment = .left
        musicNameLabel.font = UIFont.igFont(ofSize: 10 , weight: .bold)

        musicNameLabel.translatesAutoresizingMaskIntoConstraints = false
        musicNameLabel.topAnchor.constraint(equalTo: musicCoverLabel.topAnchor, constant: 0).isActive = true
        musicNameLabel.leftAnchor.constraint(equalTo: musicCoverLabel.rightAnchor, constant: 10).isActive = true
        musicNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true

        musicArtistLabel.numberOfLines = 1
        musicArtistLabel.textAlignment = .left
        musicArtistLabel.font = UIFont.igFont(ofSize: 10 , weight: .light)

        musicArtistLabel.translatesAutoresizingMaskIntoConstraints = false
        musicArtistLabel.bottomAnchor.constraint(equalTo: musicCoverLabel.bottomAnchor, constant: 0).isActive = true
        musicArtistLabel.leftAnchor.constraint(equalTo: musicCoverLabel.rightAnchor, constant: 10).isActive = true
        musicArtistLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
