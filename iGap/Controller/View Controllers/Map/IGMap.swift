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
import MapKit
import CoreLocation
import RealmSwift
import IGProtoBuff

enum CommentState {
    case UPDATE
    case CLEAR
    case NONE
}

class IGMap: BaseViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var edtComment: UITextField!
    @IBOutlet weak var btnComment: UIButton!

    @IBOutlet weak var segType: UISegmentedControl!
    
    var tileRenderer: MKTileOverlayRenderer!
    var currentLocation: CLLocation!
    private static let locationManager = CLLocationManager()
    
    var latestComment: String? // changed comment before send to server
    var latestMainComment: String? // server comment
    var latestCommentState: CommentState?
    var showMarker = true
    var isFirstSetRegion = true
    var room: IGRoom!
    
    var span: MKCoordinateSpan!
    var latestSpan: MKCoordinateSpan!
    var lastCenterCoordinate: CLLocationCoordinate2D!
    var latestUpdatePosition: Int64?
    var northLimitation: Double!
    var southLimitation: Double!
    var westLimitation: Double!
    var eastLimitation: Double!
    
    let MIN_ZOOM_LEVEL = 14.5
    let MAX_ZOOM_LEVEL = 18.5
    let MAX_COMMENT_LENGTH = 200
    let DISTANCE_METERS = 5000
    let UPDATE_POSITION_DELAY = 60 * 1000 // allow send update poistion for each one minute
    
    var userIdDictionary:[Int:Int64] = [:]
    var usersCommentDictionary:[Int64:String] = [:]
    var userNoInfoDictionary:[Int64:IGPGeoGetNearbyCoordinateResponse.IGPResult] = [:]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segType.setTitle("SATELITE".localized, forSegmentAt: 1)
        segType.setTitle("SATNDARD".localized, forSegmentAt: 0)
        let font: [AnyHashable : Any] = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 14)]
        segType.setTitleTextAttributes((font as! [NSAttributedString.Key : Any]), for: .normal)
        edtComment.placeholder = "YOUR_STATUS".localized
    }
    @IBAction func segmentChanger(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        setCurrentLocation(setRegion: true)
    }
    
    @IBAction func btnUpdateComment(_ sender: UIButton) {
        if latestCommentState == .NONE {
            return
        } else if latestCommentState == .CLEAR {
            clearCommentAlert()
        } else if latestCommentState == .UPDATE {
            updateComment(comment: edtComment.text!)
        }
        
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btnComment.removeUnderline()
        btnCurrentLocation.removeUnderline()
        btnCurrentLocation.setTitle("", for: .normal)
        edtComment.delegate = self
        edtComment.font = UIFont.igFont(ofSize: 15)
        edtComment.textAlignment = edtComment.localizedDirection
        initNavigationBar()
        checkLocationPermission()
        initMapView()
        getMyComment()
        manageCommentView()
        manageCommentButtonView(commentState: .NONE)
        buttonViewCustomize(button: btnCurrentLocation, color: UIColor.white)
        
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_NEARBY_PAGE)
    }
    
    /************************************************************/
    /********************** Common Methods **********************/
    /************************************************************/
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", title: "SETTING_PAGE_NEARBY".localized,iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
//        navigationItem.addModalViewRightItem(title: "", iGapFont: true, fontSize: 25.0, xPosition: 5.0)
        navigationItem.rightViewContainer?.addAction {
            self.mapOptionsAlert()
        }
    }
    
    func mapOptionsAlert(){
        let option = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let updateMap = UIAlertAction(title: "SETTING_NEARBY_MAP_MANUALUPDATE".localized, style: .default, handler: { (action) in
            self.detectUsersCoordinate()
        })
        
        let nearbyDistance = UIAlertAction(title: "SETTING_NEARBY_MAP_USERS_NEARBY_DISTANCE".localized, style: .default, handler: { (action) in
            self.openNearbyDistanceList()
        })
        
        let nearbyState = UIAlertAction(title: "SETTING_NEARBY_MAP_DISABLE_NEARBY".localized, style: .default, handler: { (action) in
            self.disableNearbyVisibilityAlert()
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        option.addAction(updateMap)
        option.addAction(nearbyDistance)
        option.addAction(nearbyState)
        option.addAction(cancel)
        
        self.present(option, animated: true, completion: {})
    }
    
    func commentMaxAlert(){
        let option = UIAlertController(title: nil, message: "Comment cannot be more than \(MAX_COMMENT_LENGTH) characters!", preferredStyle: .alert)
        let cancel = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .cancel, handler: nil)
        option.addAction(cancel)
        self.present(option, animated: true, completion: {})
    }
    
    func clearCommentAlert(){
        let option = UIAlertController(title: "CLEAR_STATUS".localized, message: "SETTING_NEARBY_MAP_STATUS".localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .destructive, handler: { (action) in
            self.updateComment(comment: "")
        })
        let cancel = UIAlertAction(title: IGStringsManager.GlobalNo.rawValue.localized, style: .cancel, handler: nil)
        
        option.addAction(ok)
        option.addAction(cancel)
        self.present(option, animated: true, completion: {})
    }
    
    func disableNearbyVisibilityAlert(){
        let option = UIAlertController(title: "SETTING_NEARBY_MAP_DISABLE_NEARBY".localized, message: "MSG_DESABLE_MAP_VISIBILITY".localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .destructive, handler: { (action) in
            self.geoRegister()
        })
        let cancel = UIAlertAction(title: IGStringsManager.GlobalNo.rawValue.localized, style: .cancel, handler: nil)
        
        option.addAction(ok)
        option.addAction(cancel)
        self.present(option, animated: true, completion: {})
    }
    
    func initMapView(){
        let initialRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.689197, longitude: 51.388974), span: MKCoordinateSpan(latitudeDelta: 0.16405544070813249, longitudeDelta: 0.1232528799585566))
        mapView.region = initialRegion
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.delegate = self
    }
    
    func setupTileRenderer() {
        let template = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKHipsterTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
    }
    
    func checkLocationPermission(){
        let status  = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            IGMap.locationManager.requestWhenInUseAuthorization()
            return
        }
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "LOCATION_SERVICE_DISABLE".localized, message: "LOCATION_SERVICE_ENABLE_IT".localized, preferredStyle: .alert)

            let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
            return
        }
        IGMap.locationManager.requestAlwaysAuthorization()
        IGMap.locationManager.startUpdatingLocation()
        IGMap.locationManager.delegate = self
    }
    
    func manageCommentView(){
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewShadow.layer.shadowRadius = 5.0
        viewShadow.layer.shadowOpacity = 0.3
        viewShadow.layer.masksToBounds = false
        viewShadow.layer.cornerRadius = 7.0
        
        commentView.layer.cornerRadius = 7.0
        commentView.layer.borderWidth = 0.1
        commentView.layer.borderColor = UIColor.darkGray.cgColor
        commentView.layer.masksToBounds = true
    }
    
    func manageCommentButtonView(commentState: CommentState){
        
        latestCommentState = commentState
        
        if commentState == .UPDATE {
            btnComment.setTitle("", for: UIControl.State.normal)
            btnComment.setTitleColor(UIColor.iGapColor(), for: UIControl.State.normal)
        } else if commentState == .CLEAR {
            btnComment.setTitle("", for: UIControl.State.normal)
            btnComment.setTitleColor(UIColor.red, for: UIControl.State.normal)
        } else if commentState == .NONE {
            btnComment.setTitle(" ", for: UIControl.State.normal)
            btnComment.setTitleColor(UIColor.clear, for: UIControl.State.normal)
        }
    }
    
    func buttonViewCustomize(button: UIButton, color: UIColor){
        button.backgroundColor = color
        
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius = 0.1
        button.layer.shadowOpacity = 0.1
        
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = button.frame.width / 2
    }
    
    func addMarker(userId: Int64, lat: Double, lon: Double){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", userId)
        if let userInfo = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            let annotation = MKPointAnnotation()
            let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            annotation.coordinate = userLocation
            annotation.subtitle = "Status ..."
            annotation.title = userInfo.displayName
            userIdDictionary[annotation.hash] = userId
            mapView.addAnnotation(annotation)
        }
    }
    
    func setCurrentLocation(setRegion: Bool){
        
        if currentLocation == nil {
            return
        }
        
        span = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(16)) * Double(mapView.frame.size.width) / 256)
        let region = MKCoordinateRegion.init(center: currentLocation.coordinate, span: span)
        
        if isFirstSetRegion {
            detectUsersCoordinate(delay: 2)
        }
        
        if setRegion || isFirstSetRegion{
            isFirstSetRegion = false
            mapView.setRegion(region, animated: true)
        }
        
        updatePosition(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
    }

    @objc func callToUser(sender: UIButton){
        if IGCall.callPageIsEnable {
            return
        }
        
        if let userId = userIdDictionary[sender.tag] {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: userId, isIncommmingCall: false)
            }
        }
    }
    
    func openNearbyDistanceList(){
        if currentLocation == nil {
            return
        }
        
        let mapNearbyDistanceList = IGMapNearbyDistanceTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        mapNearbyDistanceList.latitude = currentLocation.coordinate.latitude
        mapNearbyDistanceList.longitude = currentLocation.coordinate.longitude
        mapNearbyDistanceList.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(mapNearbyDistanceList, animated: true)
    }
    
    func openChat(){
        let roomVC = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        roomVC.room = room
        roomVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(roomVC, animated: true)
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    /************************************************************/
    /************************* Requests *************************/
    /************************************************************/
    
    func geoRegister(enable: Bool = false){
        IGGeoRegister.Generator.generate(enable: enable).success({ (protoResponse) in
            IGMap.locationManager.delegate = nil
            DispatchQueue.main.async {
                if let registerResponse = protoResponse as? IGPGeoRegisterResponse {
                    IGGeoRegister.Handler.interpret(response: registerResponse)
                    IGAppManager.sharedManager.setMapEnable(enable: registerResponse.igpEnable)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getMyComment(){
        IGGeoGetComment.Generator.generate(userId: IGAppManager.sharedManager.userID()!).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let comment = protoResponse as? IGPGeoGetCommentResponse {
                    self.latestComment = comment.igpComment
                    self.latestMainComment = comment.igpComment
                    self.edtComment.text = comment.igpComment
                    
                    if comment.igpComment.isEmpty {
                        self.manageCommentButtonView(commentState: .NONE)
                    } else {
                        self.manageCommentButtonView(commentState: .CLEAR)
                    }
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getMyComment()
            default:
                break
            }
            
        }).send()
    }
    
    func updatePosition(lat: Double, lon: Double){
        
        let currentTime = getCurrentMillis()
        
        if let updateTime = latestUpdatePosition {
            let difference = currentTime - updateTime
            if (difference) < UPDATE_POSITION_DELAY {
                return
            }
        }
        
        IGGeoUpdatePosition.Generator.generate(lat: lat, lon: lon).success({ (protoResponse) in
            DispatchQueue.main.async {
                self.latestUpdatePosition = currentTime
                
                if let updatePosition = protoResponse as? IGPGeoUpdatePositionResponse {
                    IGGeoUpdatePosition.Handler.interpret(response: updatePosition)
                }
            }
        }).error ({ (errorCode, waitTime) in }).send()
    }
    
    func detectUsersCoordinate(delay: Double = 0){
        
        if self.currentLocation == nil {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            IGGeoGetCoordinateDistance.Generator.generate(lat: self.currentLocation.coordinate.latitude, lon: self.currentLocation.coordinate.longitude).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let coordinateDistanceResponse as IGPGeoGetNearbyCoordinateResponse:
                        
                        // first remove all annotations
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        
                        let realm = try! Realm()
                        
                        // then show new markers
                        for result in coordinateDistanceResponse.igpResult {
                            
                            let predicate = NSPredicate(format: "id = %lld", result.igpUserID)
                            if let _ = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                                
                                if result.igpHasComment {
                                    
                                    let comment = self.usersCommentDictionary[result.igpUserID]
                                    if comment != nil { // if comment exist reuse that again
                                        self.addMarker(userId: result.igpUserID, lat: result.igpLat, lon: result.igpLon)
                                    } else {
                                        self.userNoInfoDictionary[result.igpUserID] = result
                                        self.getUserComment(userId: result.igpUserID)
                                    }
                                    
                                } else {
                                    self.usersCommentDictionary[result.igpUserID] = ""
                                    self.addMarker(userId: result.igpUserID, lat: result.igpLat, lon: result.igpLon)
                                }
                                
                            } else {
                                self.userNoInfoDictionary[result.igpUserID] = result
                                self.getUserInfo(userId: result.igpUserID)
                            }
                        }
                        
                        IGGeoGetCoordinateDistance.Handler.interpret(response: coordinateDistanceResponse)
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func getUserInfo(userId: Int64){
        IGUserInfoRequest.Generator.generate(userID: userId).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userInfoResponse as IGPUserInfoResponse:
                    let igpUser = userInfoResponse.igpUser
                    IGFactory.shared.saveRegistredUsers([igpUser])
                    
                    if let nearbyCoordinate = self.userNoInfoDictionary[igpUser.igpID] {
                        if nearbyCoordinate.igpHasComment {
                            self.getUserComment(userId: igpUser.igpID)
                        } else {
                            self.usersCommentDictionary[nearbyCoordinate.igpUserID] = ""
                            self.addMarker(userId: igpUser.igpID, lat: nearbyCoordinate.igpLat, lon: nearbyCoordinate.igpLon)
                            self.userNoInfoDictionary.removeValue(forKey: igpUser.igpID)
                        }
                    }
                    
                    break
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    
    func getUserComment(userId: Int64){
        IGGeoGetComment.Generator.generate(userId: userId, identity: userId).successPowerful ({ (protoResponse, requestWrapper) in
            DispatchQueue.main.async {
                if let comment = protoResponse as? IGPGeoGetCommentResponse {
                    let userId = requestWrapper.identity as! Int64
                    self.usersCommentDictionary[userId] = comment.igpComment
                    
                    if let nearbyCoordinate = self.userNoInfoDictionary[userId] {
                        self.addMarker(userId: userId, lat: nearbyCoordinate.igpLat, lon: nearbyCoordinate.igpLon)
                        self.userNoInfoDictionary.removeValue(forKey: userId)
                    }
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    
    func updateComment(comment: String){
        IGGeoUpdateComment.Generator.generate(comment: comment).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let updateComment = protoResponse as? IGPGeoUpdateCommentResponse {
                    self.edtComment.text = updateComment.igpComment
                    if updateComment.igpComment.isEmpty {
                        self.manageCommentButtonView(commentState: .NONE)
                    } else {
                        self.manageCommentButtonView(commentState: .CLEAR)
                    }
                    IGGeoUpdateComment.Handler.interpret(response: updateComment)
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    @objc func manageOpenChat(sender: UIButton){
        let userId = userIdDictionary[sender.tag]
        let realm = try! Realm()
        let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", userId!)
        if let roomInfo = realm.objects(IGRoom.self).filter(predicate).first {
            room = roomInfo
            openChat()
        } else {
            IGChatGetRoomRequest.Generator.generate(peerId: userId!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.room = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                        self.openChat()
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }

            }).send()
        }
    }
    
    /************************************************************/
    /*********************** Map Bounding ***********************/
    /************************************************************/
    
    func detectBoundingBox(location: CLLocation) {
        let latRadian = degreesToRadians(degrees: CGFloat(location.coordinate.latitude))
        let degLatKm = 110.574235
        let degLongKm = 110.572833 * cos(latRadian)
        let deltaLat = 5000 / 1000.0 / degLatKm
        let deltaLong = 5000 / 1000.0 / degLongKm
        
        southLimitation = location.coordinate.latitude - deltaLat
        westLimitation = Double(CGFloat(location.coordinate.longitude) - deltaLong)
        northLimitation =  location.coordinate.latitude + deltaLat
        eastLimitation = Double(CGFloat(location.coordinate.longitude) + deltaLong)
    }
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(Double.pi) / 180
    }
    
    /*********************************************************/
    /******************* Overrided Method ********************/
    /*********************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last!
        setCurrentLocation(setRegion: false)
        latestSpan = span
        detectBoundingBox(location: self.currentLocation)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var commentText: String! = edtComment.text!
        
        if !string.isEmpty {
            commentText = "\(commentText!)\(string)"
        } else {
            commentText = String(commentText!.prefix(commentText!.count - 1))
        }
        
        
        if commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if latestMainComment == commentText.trimmingCharacters(in: .whitespacesAndNewlines) {
                manageCommentButtonView(commentState: .NONE)
            } else {
                manageCommentButtonView(commentState: .CLEAR)
            }
        } else {
            if latestMainComment == commentText.trimmingCharacters(in: .whitespacesAndNewlines) {
                manageCommentButtonView(commentState: .CLEAR)
            } else {
                manageCommentButtonView(commentState: .UPDATE)
            }
        }
        
        if let text = edtComment.text {
            let newLength = text.count + string.count - range.length
            if (newLength > MAX_COMMENT_LENGTH) {
                edtComment.text = latestComment
                commentMaxAlert()
            } else {
                latestComment = text
            }
        }
        
        return true
    }
}

extension IGMap: MKMapViewDelegate {
    
    /*********************************************************/
    /***************** Manage Annotation View ****************/
    /*********************************************************/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            if annotation is MKUserLocation {
                return nil
            }
            
            let realm = try! Realm()
            let userIdDic = "\(userIdDictionary[annotation.hash]!)"
            let predicate = NSPredicate(format: "id = %lld", Int64(userIdDic)!)
            let user = realm.objects(IGRegisteredUser.self).filter(predicate).first
            
            //********** annotation view **********//
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            
            //********** set avatar **********//
            let frame = CGRect(x:0 ,y:0 ,width:30 ,height:30)
            let avatarViewAbs = IGAvatarView(frame: frame)
            avatarViewAbs.setUser(user!)
            
            var pinImage :UIImage!
            if let image = avatarViewAbs.avatarImageView?.image {
                pinImage = image
            } else {
                pinImage = UIImage(named: "IG_Map")
            }
            
            
            //********** make circlur annotation view **********//
            let size = CGSize(width: 50, height: 50)
            //UIGraphicsBeginImageContext(size)
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            pinView?.image = maskRoundedImage(image: (resizedImage)!, radius:  CGFloat(25))
            
            
            //********** annotation dialog view **********//
            let smallSquare = CGSize(width: 48, height: 37.5)
            
            let buttonLeftOpenChat = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
            buttonLeftOpenChat.tag = annotation.hash
            buttonLeftOpenChat.setBackgroundImage(UIImage(named: "IG_Splash_Cute_3"), for: .normal)
            buttonLeftOpenChat.addTarget(self, action: #selector(IGMap.manageOpenChat), for: .touchUpInside)
            pinView?.leftCalloutAccessoryView = buttonLeftOpenChat
            
            let buttonRigthCall = UIButton(frame: CGRect(origin: CGPoint(x: 0,y :0), size: smallSquare))
            buttonRigthCall.tag = annotation.hash
            buttonRigthCall.setBackgroundImage(UIImage(named: "IG_Splash_Cute_5"), for: .normal)
            buttonRigthCall.addTarget(self, action: #selector(IGMap.callToUser), for: .touchUpInside)
            pinView?.rightCalloutAccessoryView = buttonRigthCall

            //***** manage user comment view in annotation *****//
            
            let font = UIFont.igFont(ofSize: 15.0)
            
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 21))
            label1.font = font
            
            let comment = self.usersCommentDictionary[(user?.id)!]
            if comment != nil && !(comment?.isEmpty)! {
                label1.text = comment
            } else {
                label1.text = "No Status"
            }
            
            label1.numberOfLines = 0
            pinView?.detailCalloutAccessoryView = label1;

            let widthSize = CGFloat(200)
            let heightSize = comment?.height(withConstrainedWidth: widthSize, font: font) // compute height according to width and font size

            let width = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: widthSize)
            let height = NSLayoutConstraint(item: label1, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: heightSize!)
            
            label1.addConstraint(width)
            label1.addConstraint(height)

            return pinView
        }
    }
    
    func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.1
        
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = radius
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    /*********************************************************/
    /************ Manage Zoom & Scroll Limitation ************/
    /*********************************************************/
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude)
        let zoomLevel = getZoomLevel()
        
        if (self.latestSpan != nil) && (MIN_ZOOM_LEVEL > zoomLevel || MAX_ZOOM_LEVEL < zoomLevel) {
            let region = MKCoordinateRegion.init(center: coordinate, span: self.latestSpan)
            mapView.setRegion(region, animated:true)
        } else {
            if northLimitation == nil {
                return
            }
            
            self.latestSpan = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(zoomLevel-1)) * Double(mapView.frame.size.width) / 256)
            
            let latitude = mapView.region.center.latitude
            let longitude = mapView.region.center.longitude
            
            if latitude < northLimitation && latitude > southLimitation && longitude < eastLimitation && longitude > westLimitation {
                lastCenterCoordinate = coordinate
            } else {
                if lastCenterCoordinate == nil {
                    return
                }
                span = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(16)) * Double(mapView.frame.size.width) / 256)
                let region = MKCoordinateRegion.init(center: lastCenterCoordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func getZoomLevel() -> Double {
        var angleCamera = mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180
        let width = Double(mapView.frame.size.width)
        let height = Double(mapView.frame.size.height)
        let heightOffset : Double = 20
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1
    }
    
    /*********************************************************/
    /********************* Set Map Tiles *********************/
    /*********************************************************/
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return tileRenderer
    }
}


