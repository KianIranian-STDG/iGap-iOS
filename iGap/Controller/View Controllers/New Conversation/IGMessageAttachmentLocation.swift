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
protocol DidSelectLocationDelegate{
    func userWasSelectedLocation(location: CLLocation)
}

class IGMessageAttachmentLocation: UIViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var bottomView: IGTappableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentLocationNameLabel: UILabel!
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var txtSendLocation: UILabel!
    @IBOutlet weak var btnCurrentLocation: UIButton!
    @IBOutlet weak var txtSendLocationIcon: UILabel!
    
    let locationManager = CLLocationManager()
    var centerAnnotation = MKPointAnnotation()
    var locationDelegate : DidSelectLocationDelegate?
    var currentLocation : CLLocation!
    var currentLocationShowView : CLLocation? // use from this param for go to location after click button
    var isSendLocation = true
    var showedCurrentLocation = false
    var room : IGRoom!
    
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
        setCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isSendLocation {
            IGClientActionManager.shared.cancelSendingLocation(for: room)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigation()
        buttonViewCustomize()
        manageBottomView()
        initLocation()
        
        bottomView.addAction {
            if self.isSendLocation && self.isSendLocation && self.currentLocation != nil {
                if self.locationDelegate != nil {
                    self.locationDelegate?.userWasSelectedLocation(location: self.currentLocation)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        initFonts()
    }
    private func initFonts() {
        btnCurrentLocation.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
        
        btnCurrentLocation.setTitle("", for: .normal)
        txtSendLocationIcon.font = UIFont.iGapFonticon(ofSize: 25)
        txtSendLocationIcon.text = ""
    }
    private func initNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        var title = "Received Location"
        if isSendLocation {
            title = "Send Location"
        }
        navigationItem.addNavigationViewItems(rightItemText: "", title: title, iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        if !isSendLocation {
//            navigationItem.addModalViewRightItem(title: "", iGapFont: true)
            navigationItem.rightViewContainer?.addAction {
                self.shareLocation()
            }
        }
    }
    
    private func shareLocation(){
        if (UIApplication.shared.canOpenURL(NSURL(string:"http://maps.apple.com/maps")! as URL)) {
            let url = "http://maps.apple.com/maps?q=iGap+Marker&ll=\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)&z=14"
            UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)

        }
    }
    
    func buttonViewCustomize(){
        btnCurrentLocation.removeUnderline()
        
        btnCurrentLocation.layer.shadowColor = UIColor.darkGray.cgColor
        btnCurrentLocation.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btnCurrentLocation.layer.shadowRadius = 0.1
        btnCurrentLocation.layer.shadowOpacity = 0.1
        
        btnCurrentLocation.layer.borderWidth = 1.5
        btnCurrentLocation.layer.borderColor = UIColor.darkGray.cgColor
        btnCurrentLocation.layer.masksToBounds = false
        btnCurrentLocation.layer.cornerRadius = btnCurrentLocation.frame.width / 2
    }
    
    func manageBottomView(){
//        bottomView.layer.shadowColor = UIColor.black.cgColor
//        bottomView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        bottomView.layer.shadowRadius = 5.0
//        bottomView.layer.shadowOpacity = 0.6
    }
    
    private func initLocation() {
        
        mapView.delegate = self
        mapView.isZoomEnabled = true
        currentLocationNameLabel.text = "Locating..."
        
        if isSendLocation { // for send location
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
            
            if currentLocation != nil {
                currentLocationShowView = currentLocation
                showCurrentLocation()
            }
            
        } else { // for received location
            txtSendLocationIcon.isHidden = true
            pinImageView.isHidden = true
            txtSendLocation.text = "Received this Location"
            currentLocationShowView = currentLocation
            
            addMarker()
            showCurrentLocation()
        }
    }
    
    func showCurrentLocation() {
        if !showedCurrentLocation { // just once go to current location
            showedCurrentLocation = true
            let userCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let camera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: userCoordinate, eyeAltitude: 300.0)
            self.mapView.setCamera(camera, animated: true)
            setCurrentLocation()
        }
        displayLocationInfo()
    }
    
    func setCurrentLocation() {
        if currentLocationShowView == nil {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let span = MKCoordinateSpan.init(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(16)) * Double(self.mapView.frame.size.width) / 256)
            let region = MKCoordinateRegion.init(center: (self.currentLocationShowView?.coordinate)!, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func addMarker(){
        let annotation = MKPointAnnotation()
        let userLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        annotation.coordinate = userLocation
        annotation.subtitle = "Received Location"
        mapView.addAnnotation(annotation)
    }
    
    func displayLocationInfo() {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            // Location name
//            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
//                print(locationName)
//                self.currentLocationNameLabel.text = locationName as String
//            }
            if let locationName = placeMark.name{
                print(locationName)
                self.currentLocationNameLabel.text = locationName as String
            }
            // Street address
            if let street = placeMark.thoroughfare {
                print(street)
            }
            // City
            if let city = placeMark.subAdministrativeArea {
                print(city)
            }
            // Zip code
            if let zip = placeMark.isoCountryCode {
                print(zip)
            }
            // Country
            if let country = placeMark.country {
                print(country)
                
            }
        })
    }
}

extension IGMessageAttachmentLocation : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !isSendLocation { return }
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        currentLocation = location
        if currentLocationShowView == nil {
            currentLocationShowView = currentLocation
        }
        self.showCurrentLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        // Configure your annotation view here
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Location_Marker")
        }
        
        return annotationView
    }
}
extension IGMessageAttachmentLocation : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // we don't need following condition because when isSendLocation is false location manage callbacks are disable
        // if !isSendLocation { return }
        
        self.currentLocationShowView = locations.last!
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors : " + error.localizedDescription)
    }
}

