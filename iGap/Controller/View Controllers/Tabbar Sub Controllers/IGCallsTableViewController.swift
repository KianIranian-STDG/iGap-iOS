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
import SwiftEventBus

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
    var btnHolderView : UIView!
    var btnHolderScrollView : UIScrollView!
    var connectionStatus: IGAppManager.ConnectionStatus?
    
    //-End
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.initNavBarWithIgapIcon()

        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
        callLogList = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties)
        
        
        self.tableView.register(IGCallListTableViewCell.nib(), forCellReuseIdentifier: IGCallListTableViewCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
//        self.tableView.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.view.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.tableView.tableHeaderView?.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        
        self.tableView.tableHeaderView = addCollectionFilterView()
        
        updateObserver(mode : currentMode)
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.fetchCallLogList()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.fetchCallLogList),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
        callTypes = IGPSignalingGetLog.IGPFilter.allCases
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
            SwiftEventBus.onMainThread(self, name: "initTheme") { result in
                self.initTheme()

            }
        initTheme()
        }

        private func initTheme() {
            self.tableView.reloadData()
            self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
            self.transactionTypesCollectionView.backgroundColor = .clear
            self.tableView!.setEmptyMessage(IGStringsManager.GlobalNoHistory.rawValue.localized)

        }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstIndex = IndexPath(item: 0, section: 0)
        self.transactionTypesCollectionView.scrollToItem(at: firstIndex, at: .centeredHorizontally, animated: false)
        let selectedIndex = IndexPath(item: self.selectedIndex, section: 0)
        transactionTypesCollectionView.selectItem(at: selectedIndex, animated: false, scrollPosition: [])
    }
    
    private func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.setCallListNavigationItems()
        self.hideKeyboardWhenTappedAround()
        
        navigationItem.rightViewContainer?.addAction {
            self.goToContactListPage()
        }
        navigationItem.leftViewContainer?.addAction {
            if !(self.callLogList!.count == 0) {
                self.showClearHistoryActionSheet()
            }
        }
    }
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        if let navigationItem = self.navigationItem as? IGNavigationItem {
            switch status {
            case .waitingForNetwork:
                navigationItem.setNavigationItemForWaitingForNetwork()
                connectionStatus = .waitingForNetwork
                IGAppManager.connectionStatusStatic = .waitingForNetwork
                break
                
            case .connecting:
                navigationItem.setNavigationItemForConnecting()
                connectionStatus = .connecting
                IGAppManager.connectionStatusStatic = .connecting
                break
                
            case .connected:
                connectionStatus = .connected
                IGAppManager.connectionStatusStatic = .connected
                break
                
            case .iGap:
                connectionStatus = .iGap
                IGAppManager.connectionStatusStatic = .iGap
                switch  currentTabIndex {
                case TabBarTab.Recent.rawValue:
                    let navItem = self.navigationItem as! IGNavigationItem
                    navItem.addModalViewItems(leftItemText: nil, rightItemText: nil, title: IGStringsManager.Phone.rawValue.localized)
                default:
                    self.initNavigationBar()
                }
                break
            }
        }
    }

    private func addCollectionFilterView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        headerView.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        self.transactionTypesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.transactionTypesCollectionView.showsHorizontalScrollIndicator = false

        self.transactionTypesCollectionView.register(CallTypesCVCell.nib, forCellWithReuseIdentifier: CallTypesCVCell.identifier)
        headerView.addSubview(self.transactionTypesCollectionView)
        
        self.transactionTypesCollectionView?.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView.snp.centerY)
            make.height.equalTo(50)
            make.leading.equalTo(headerView.snp.leading).offset(0)
            make.trailing.equalTo(headerView.snp.trailing).offset(0)
        }
        self.transactionTypesCollectionView.backgroundColor = .clear
        
        self.transactionTypesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        self.transactionTypesCollectionView.semanticContentAttribute = self.semantic
        self.transactionTypesCollectionView.transform = self.transform
        
        self.transactionTypesCollectionView.dataSource = self
        self.transactionTypesCollectionView.delegate = self
        
        return headerView
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
                self.tableView.reloadData()
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

//        self.tableView.isUserInteractionEnabled = true
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
        var actionTitle: String!
        actionTitle = IGStringsManager.ClearHistory.rawValue.localized
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

                            break
                            default:
                            break
                        }
                        self.hud.hide(animated: true)
                    }
                }).send()
            }
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style:.cancel , handler: {
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
        
        self.performSegue(withIdentifier: "showPhoneBook", sender: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if callLogList!.count == 0 {
            self.tableView!.setEmptyMessage(IGStringsManager.GlobalNoHistory.rawValue.localized)
        } else {
            self.tableView!.restore()
        }
        return callLogList!.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGCallListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGCallListTableViewCell
        
        cell.setCallLog(callLog: callLogList![indexPath.row])
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if IGCall.callPageIsEnable {
            return
        }
        
        selectedRowUser = callLogList![indexPath.row].registeredUser
//        self.tableView.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: self.selectedRowUser!.id, isIncommmingCall: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78.0
    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return addCollectionFilterView()
//    }
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }

//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let deleteAction = UITableViewRowAction(style: .default, title: "") { action, indexPath in
//            // Handle delete action
//        }
//        (UIButton.appearance(whenContainedInInstancesOf: [UIView.self])).setImage(UIImage(named: "ic_delete"), for: .normal)
//        return [deleteAction]
//
//    }
    private func sendClearOneRowRequest(rowID: Int64!) {

        print(rowID)
        SMLoading.showLoadingPage(viewcontroller: self)
        IGSignalingClearLogRequest.Generator.generate(logIDArray: [rowID]).success({ (protoResponse) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                if let clearLogResponse = protoResponse as? IGPSignalingClearLogResponse {
                    IGSignalingClearLogRequest.Handler.interpretClearUsingArray(response: clearLogResponse,array: [rowID])
                    
                }
            }
        }).error({ (errorCode, waitTime) in
            SMLoading.hideLoadingPage()

            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                    default:
                    break
                }
            }
        }).send()

    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.sendClearOneRowRequest(rowID: self.callLogList[indexPath.row].id)

            success(true)
        })
        deleteAction.image = UIImage(named: "ic_delete")
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
        if segue.identifier == "showPhoneBook" {
            (segue.destination as! IGPhoneBookTableViewController).mustCallContact = true
        }
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
            cell.lbl.text = IGStringsManager.All.rawValue.localized
            break
        case .canceled:
            cell.lbl.text = IGStringsManager.Canceled.rawValue.localized
            break
        case .incoming:
            cell.lbl.text = IGStringsManager.Incomming.rawValue.localized
            break
        case .missed:
            cell.lbl.text = IGStringsManager.Missed.rawValue.localized
            break
        case .outgoing:
            cell.lbl.text = IGStringsManager.Outgoing.rawValue.localized
            break
        default:
            break
        }
        
        cell.layer.cornerRadius = 10
        cell.transform = self.transform
        
        if indexPath.item == selectedIndex {
            cell.backgroundColor = ThemeManager.currentTheme.TransactionsCVSelectedColor
            cell.lbl.textColor = UIColor.white
        } else {
            cell.backgroundColor = ThemeManager.currentTheme.TransactionsCVColor
            cell.lbl.textColor = ThemeManager.currentTheme.LabelFinancialServiceColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var typeStr = ""
        
        switch callTypes[indexPath.item] {
        case .all:
            typeStr = IGStringsManager.All.rawValue.localized
            break
        case .canceled:
            typeStr = IGStringsManager.Canceled.rawValue.localized
            break
        case .incoming:
            typeStr = IGStringsManager.Incomming.rawValue.localized
            break
        case .missed:
            typeStr = IGStringsManager.Missed.rawValue.localized
            break
        case .outgoing:
            typeStr = IGStringsManager.Outgoing.rawValue.localized
            break
        default:
            break
        }
        
        let size: CGSize = typeStr.size(withAttributes: [NSAttributedString.Key.font: UIFont.igFont(ofSize: 13)])
        return CGSize(width: size.width + 32.0, height: collectionView.bounds.size.height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        label.textColor = UIColor.white

        selectedIndex = indexPath.item

        switch callTypes[indexPath.item] {
        case .all:
            currentMode = .all
            break
        case .canceled:
            currentMode = .canceled
            break
        case .incoming:
            currentMode = .incoming
            break
        case .missed:
            currentMode = .missed
            break
        case .outgoing:
            currentMode = .outgoing
            
            break
        default:
            break
        }
        
        updateObserver(mode: currentMode)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let label = cell.viewWithTag(110) as! UILabel
        cell.backgroundColor = ThemeManager.currentTheme.TransactionsCVColor
        label.textColor = ThemeManager.currentTheme.LabelFinancialServiceColor
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let label = cell.viewWithTag(110) as! UILabel
        if indexPath.item == selectedIndex {
            cell.backgroundColor = ThemeManager.currentTheme.SliderTintColor
            label.textColor = UIColor.white
        } else {
            cell.backgroundColor = ThemeManager.currentTheme.TransactionsCVColor
            label.textColor = ThemeManager.currentTheme.LabelFinancialServiceColor
        }
    }

}
