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
import IGProtoBuff
import SwiftProtobuf
import RealmSwift
import MBProgressHUD

class IGCallsTableViewController: BaseTableViewController {
    var transactionTypesCollectionView : UICollectionView!
    var selectedRowUser : IGRegisteredUser?
    var cellIdentifer = IGCallListTableViewCell.cellReuseIdentifier()
    var callLogList: Results<IGRealmCallLog>!
    var callMissedLogList: Results<IGRealmCallLog>!
    var callIncommingLogList: Results<IGRealmCallLog>!
    var callOutgoingLogList: Results<IGRealmCallLog>!
    var callCanceledLogList: Results<IGRealmCallLog>!
    var notificationToken: NotificationToken?
    var isLoadingMore: Bool = false
    var numberOfCallLogFetchedInLastRequest: Int = -1
    let CALL_LOG_CONFIG: Int32 = 50
    var hud = MBProgressHUD()
    var currentMode : IGPSignalingGetLog.IGPFilter = .all
    var selectedIndex: Int = 0

    var callTypes: [IGPSignalingGetLog.IGPFilter]!

    //Mark: - filterView
    var btnAll : UIButton!
    var btnMissed : UIButton!
    var btnIncomming : UIButton!
    var btnCanceled : UIButton!
    var btnOutGoing : UIButton!
    var headerView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 50.0))
    var btnHolderView : UIView!
    var btnHolderScrollView : UIScrollView!
    
    //-End
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
        callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties)
        
        
        self.tableView.register(IGCallListTableViewCell.nib(), forCellReuseIdentifier: IGCallListTableViewCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        updateObserver(mode : currentMode)
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchCallLogList()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.fetchCallLogList),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
    }
    
    private func initNavigationBar(){
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setCallListNavigationItems()
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.rightViewContainer?.addAction
            {
                self.goToContactListPage()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationItem.leftViewContainer?.addAction {
                if !(self.callLogList!.count == 0) {
                    
                    self.showClearHistoryActionSheet()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        selectedIndex = 0
        initNavigationBar()
        callTypes = IGPSignalingGetLog.IGPFilter.allCases
        
        addCollectionFilterView()

        self.tableView.isUserInteractionEnabled = true
    }
    override func viewDidLayoutSubviews() {
        let firstIndex = IndexPath(item: 0, section: 0)
        self.transactionTypesCollectionView.scrollToItem(at: firstIndex, at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstIndex = IndexPath(item: 0, section: 0)
        transactionTypesCollectionView.selectItem(at: firstIndex, animated: false, scrollPosition: [])
    }

    private func addCollectionFilterView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        self.transactionTypesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.transactionTypesCollectionView.showsHorizontalScrollIndicator = false

        self.transactionTypesCollectionView.register(CallTypesCVCell.nib, forCellWithReuseIdentifier: CallTypesCVCell.identifier)
        self.headerView.addSubview(self.transactionTypesCollectionView)
        
        self.transactionTypesCollectionView?.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.headerView.snp.centerY)
            make.height.equalTo(40)
            make.width.equalTo(((UIScreen.main.bounds.width) + (UIScreen.main.bounds.width)/4))
            make.leading.equalTo(self.headerView.snp.leading).offset(10)
            make.trailing.equalTo(self.headerView.snp.trailing).offset(-10)
        }
        self.self.transactionTypesCollectionView.backgroundColor = UIColor.white

        self.transactionTypesCollectionView.transform = self.transform
        
        self.transactionTypesCollectionView.dataSource = self
        self.transactionTypesCollectionView.delegate = self

        
    }
    
    
    //observer Update
    func updateObserver(mode : IGPSignalingGetLog.IGPFilter) {
        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
        
        switch currentMode {
        case .all:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties)
        case .missed:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).filter(NSPredicate(format: "status = %lld", 0))//MISSED
        case .canceled:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).filter(NSPredicate(format: "status = %lld", 1))//CANCELED
        case .incoming:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).filter(NSPredicate(format: "status = %lld", 2))//INCOMMING
        case .outgoing:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).filter(NSPredicate(format: "status = %lld", 3))//OUTGOING
        default:
            callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties)
            
        }
        
        self.notificationToken = callLogList!.observe { (changes: RealmCollectionChange) in
            switch changes {
                
            case .initial:
                self.tableView.reloadWithAnimation()
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
                
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Hint :- restore call list to its first state on disapreance of viewcontroller

        self.tableView.isUserInteractionEnabled = true
    }
    
    
    @objc private func fetchCallLogList() {
        IGSignalingGetLogRequest.Generator.generate(offset: 0, limit: CALL_LOG_CONFIG, mode: currentMode).success { (responseProtoMessage) in
            DispatchQueue.main.async {
                
                if let signalingResponse = responseProtoMessage as? IGPSignalingGetLogResponse {
                    self.numberOfCallLogFetchedInLastRequest = IGSignalingGetLogRequest.Handler.interpret(response: signalingResponse)
                }
                
            }}.error({ (errorCode, waitTime) in }).send()
    }
    
    
    private func showClearHistoryActionSheet() {
        var title : String!
        var actionTitle: String!
        title = ""
        actionTitle = "CLEAR_HISTORY".localizedNew
        let deleteConfirmAlertView = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: actionTitle , style:.default , handler: { (action) in
            if IGAppManager.sharedManager.userID() != nil {
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                
                let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
                guard let clearId = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).first?.id else {
                    return
                }
                
                IGSignalingClearLogRequest.Generator.generate(clearId: clearId).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let clearLogResponse = protoResponse as? IGPSignalingClearLogResponse {
                            IGSignalingClearLogRequest.Handler.interpret(response: clearLogResponse)
                            hud.hide(animated: true)
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        switch errorCode {
                        case .timeout:
                            let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        default:
                            break
                        }
                        self.hud.hide(animated: true)
                    }
                }).send()
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == actionTitle{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
    }
    private func goToContactListPage() {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "CreateRoom", bundle: nil)
        let contactList : IGContactListTableViewController? = (storyboard.instantiateViewController(withIdentifier: "IGContactListTableViewController") as! IGContactListTableViewController)
        contactList!.forceCall = true
        self.navigationController!.pushViewController(contactList!, animated: true)
        
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if callLogList!.count == 0 {
            self.tableView!.setEmptyMessage("CALL_LISTT_EMPTY".localizedNew)
        } else {
            self.tableView!.restore()
        }
        return callLogList!.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGCallListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGCallListTableViewCell
        
        cell.setCallLog(callLog: callLogList![indexPath.row])
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 82.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        selectedRowUser = callLogList![indexPath.row].registeredUser
        self.tableView.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: self.selectedRowUser!.id, isIncommmingCall: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
        
    }
}


extension IGCallsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 100 {
            self.loadMore()
        }
    }
}


extension IGCallsTableViewController {
    func loadMore() {
        if !isLoadingMore && numberOfCallLogFetchedInLastRequest > 0 {
            isLoadingMore = true
            
            let offset : Int! = callLogList!.count
            //
            IGSignalingGetLogRequest.Generator.generate(offset: Int32(offset), limit: CALL_LOG_CONFIG, mode: currentMode).success { (responseProtoMessage) in
                DispatchQueue.main.async {
                    
                    if let callLog = responseProtoMessage as? IGPSignalingGetLogResponse {
                        self.numberOfCallLogFetchedInLastRequest = IGSignalingGetLogRequest.Handler.interpret(response: callLog)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isLoadingMore = false
                    }
                }
                }.error({ (errorCode, waitTime) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.isLoadingMore = false
                    }
                }).send()
        }
    }
}

/// MARK: - collectionView delegate and datasource
extension IGCallsTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return callTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CallTypesCVCell", for: indexPath) as! CallTypesCVCell
        
        switch callTypes[indexPath.item] {
        case .all:
            cell.lbl.text = "FILTER_ALL_CALL".localizedNew
            break
        case .canceled:
            cell.lbl.text = "FILTER_CANCELED_CALL".localizedNew
            break
        case .incoming:
            cell.lbl.text = "FILTER_INCOMMING_CALL".localizedNew
            break
        case .missed:
            cell.lbl.text = "FILTER_MISSED_CALL".localizedNew
            break
        case .outgoing:
            cell.lbl.text = "FILTER_OUTGOING_CALL".localizedNew
            break
        default:
            break
        }
        
        cell.layer.cornerRadius = 12
        cell.transform = self.transform
        
//        if indexPath.item == selectedIndex {
//            cell.backgroundColor = UIColor.iGapGreen()
//            cell.lbl.textColor = UIColor.white
//        } else {
//            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
//            cell.lbl.textColor = UIColor.iGapDarkGray()
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var typeStr = ""
        
        switch callTypes[indexPath.item] {
        case .all:
            typeStr = "FILTER_ALL_CALL".localizedNew
            break
        case .canceled:
            typeStr = "FILTER_CANCELED_CALL".localizedNew
            break
        case .incoming:
            typeStr = "FILTER_INCOMMING_CALL".localizedNew
            break
        case .missed:
            typeStr = "FILTER_MISSED_CALL".localizedNew
            break
        case .outgoing:
            typeStr = "FILTER_OUTGOING_CALL".localizedNew
            break
        default:
            break
        }
        
        let size: CGSize = typeStr.size(withAttributes: [NSAttributedString.Key.font: UIFont.igFont(ofSize: 13)])
        return CGSize(width: size.width + 32.0, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let LastIndexPath = IndexPath(row: selectedIndex, section: 0)

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        guard let LastCell = collectionView.cellForItem(at: LastIndexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = UIColor.iGapGreen()
        label.textColor = UIColor.iGapDarkGray()
        LastCell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)

        selectedIndex = indexPath.item

        switch callTypes[indexPath.item] {
        case .all:
            print("|||||TAPPED btnAll|||||")
            cell.backgroundColor = UIColor.iGapGreen()
            currentMode = .all
            
            updateObserver(mode: currentMode)
            self.tableView.reloadWithAnimation()
            break
        case .canceled:
            print("|||||TAPPED btnCanceled|||||")
            cell.backgroundColor = UIColor.iGapGreen()
            currentMode = .canceled
            updateObserver(mode: currentMode)
            self.tableView.reloadWithAnimation()
            break
        case .incoming:
            print("|||||TAPPED btnIncomming|||||")
            cell.backgroundColor = UIColor.iGapGreen()
            currentMode = .incoming
            updateObserver(mode: currentMode)
            self.tableView.reloadWithAnimation()
            break
        case .missed:
            print("|||||TAPPED btnMissed|||||")
            cell.backgroundColor = UIColor.iGapGreen()
            currentMode = .missed
            updateObserver(mode: currentMode)
            self.tableView.reloadWithAnimation()
            break
        case .outgoing:
            print("|||||TAPPED btnOutgoing|||||")
            cell.backgroundColor = UIColor.iGapGreen()
            currentMode = .outgoing
            updateObserver(mode: currentMode)
            self.tableView.reloadWithAnimation()
            break
        default:
            break
        }

    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        IGRequestManager.sharedManager.cancelRequest(identity: "\(callTypes[indexPath.item])")
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        label.textColor = UIColor.iGapDarkGray()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let label = cell.viewWithTag(110) as! UILabel
        if indexPath.item == selectedIndex {
            cell.backgroundColor = UIColor.iGapGreen()
            label.textColor = UIColor.iGapDarkGray()
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            label.textColor = UIColor.iGapDarkGray()
        }
    }

}
