
import UIKit
var CategoriesCounter = 0

class SliderTypeTwoCell: BaseTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var timer = Timer()
    var photoCount:Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainView : UIView!
    @IBOutlet weak var collectionHolderView : UIView!
    @IBOutlet weak var btnMore : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    
    var channelItem: FavouriteChannelHomeItem!
    let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        mainView?.layer.cornerRadius = 10
        collectionHolderView?.layer.cornerRadius = 10
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.lblTitle.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        self.initTheme()
    }
    private func initTheme() {
        self.collectionView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.mainView.backgroundColor = ThemeManager.currentTheme.CellSelectedChannelBGColor
        self.collectionHolderView.backgroundColor = ThemeManager.currentTheme.CellFavouriteChannellBGColor
        self.btnMore.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.lblTitle.textColor = ThemeManager.currentTheme.LabelColor
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelItem.channels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let channel = channelItem.channels?[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell", for: indexPath as IndexPath) as! IGFavouriteChannelsDashboardCollectionViewCell
        cell.lbl.text = channel?.title
        let url = URL(string: channel?.icon ?? "")
        cell.imgBG.sd_setImage(with: url, completed: nil)
        
        // set corner radius
        let collectionViewWidth = collectionView.bounds.width
        let lblHeight = cell.lbl.bounds.height + 4
        let imageviewHeight = (collectionViewWidth/4.0 + 10) - lblHeight - 12
        cell.imgBG.layer.cornerRadius = imageviewHeight / 2
        
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        cell.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        return CGSize(width: (collectionViewWidth/4.0) + 5 , height: (collectionViewWidth/4.0) + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let channel = channelItem.channels?[indexPath.item]
        if channel?.type == .Public {
            IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: channel!.slug)
        } else if channel?.type == .Private {
            IGHelperJoin.getInstance(viewController: UIApplication.topViewController()!).requestToCheckInvitedLink(invitedLink: channel!.slug)
        }
    }
    
    public func initView() {
        self.collectionView.reloadData()
        self.collectionView.register(UINib.init(nibName: "IGFavouriteChannelsDashboardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "IGFavouriteChannelsDashboardCollectionViewCell")
        self.collectionView.backgroundColor = .clear
    }
    
    ///btnMore Action Handler
    @IBAction func didTapOnBtnMore(_ sender: Any) {
        let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        dashboard.categoryId = channelItem.id
        dashboard.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
    }
}
