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
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD
import UserNotifications
import Contacts
import AddressBook
import messages
import webservice
import KeychainSwift
import SDWebImage
import MarkdownKit
import SwiftEventBus
import AsyncDisplayKit
import SnapKit


class IGRoomListNodeController: ASViewController<ASTableNode> {
    var roomListModel = [UIImage(named: "igap_default_image"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_music"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_image"),UIImage(named: "igap_default_music")]

    init() {
        super.init(node: ASTableNode())
        
        navigationItem.title = "ASDK"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        node.dataSource = self
        node.delegate = self

        self.view.backgroundColor = .purple
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension IGRoomListNodeController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        let nodeBlock: ASCellNodeBlock = {
            return IGRoomListNode(photoModel: self.roomListModel[indexPath.row]!)
        }
        return nodeBlock
    }
    
    func shouldBatchFetchForCollectionNode(collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    

}
