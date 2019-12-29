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
import Lottie


import SwiftEventBus

class IGLiveStickerPackViewController: UIViewController {
    var isShortFormEnabled = true
    var isKeyboardPresented = false

    let cellIdentifier = "cellIdentifier"

    @IBOutlet weak var lblInfo : UILabel!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var btnSend: UIButton!
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTheme()

    }
    @IBAction func didTapOnSendButton(_ sender: UIButton) {
        

        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    private func initTheme() {
        self.stickerCollectionView.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.lblInfo.textColor = ThemeManager.currentTheme.LabelColor
        self.btnSend.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.view.backgroundColor = ThemeManager.currentTheme.BackGroundColor
    }

    private func manageView(){
    }

    
    /*************************************************************************************************/
    /**************************************** Collection View ****************************************/
    
    
}

extension IGLiveStickerPackViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return stickerCollectionView
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func panModalDidDismiss() {
        SwiftEventBus.post(EventBusManager.sendForwardReq)

    }
    
    

    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(deviceSizeModel.getShareModalSize())
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(350)
    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}

