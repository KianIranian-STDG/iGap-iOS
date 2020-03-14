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

class IGGiftStickerListCell: UITableViewCell {

    @IBOutlet weak var mainCellView: UIView!
    @IBOutlet weak var imgSticker: UIImageView!
    @IBOutlet weak var txtRRN: UILabel!
    @IBOutlet weak var txtAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    override func layoutSubviews() {
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }
    
    public func setInfo(giftCard: IGStructGiftCardListData){
        customizeView(view: mainCellView)
        showSticker(token: giftCard.sticker.token)
        txtRRN.text = IGStringsManager.WalletRrnNumber.rawValue.localized + " : " + String(describing: giftCard.rrn).inLocalizedLanguage()
        txtAmount.text = String(describing: giftCard.amount).inRialFormat().inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
    }
    
    private func customizeView(view: UIView){
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 10
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 1
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.4
        view.backgroundColor = ThemeManager.currentTheme.DashboardCellBackgroundColor
    }
    
    private func showSticker(token: String){
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.async(flags: .barrier) {
            IGGlobal.stickerImageDic[token] = self.imgSticker
        }
        IGAttachmentManager.sharedManager.getStickerFileInfo(token: token, completion: { (file) -> Void in
            self.fetchStickerImage(cacheId: file.cacheID!) { (file, imagaView) in
                DispatchQueue.main.async {
                    imagaView.setSticker(for: file)
                }
            }
        })
    }
    
    private func fetchStickerImage(cacheId: String, completion: @escaping ((_ file :IGFile, _ image: UIImageView) -> Void)) {
        IGAttachmentManager.sharedManager.syncroniseStickerQueue.sync {
            for file in IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", cacheId)) {
                if let image = IGGlobal.stickerImageDic[file.token!] {
                    completion(file, image)
                }
            }
        }
    }
}
