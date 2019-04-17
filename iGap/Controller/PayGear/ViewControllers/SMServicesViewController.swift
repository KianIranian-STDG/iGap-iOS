//
//  SMServicesViewController.swift
//  PayGear
//
//  Created by amir soltani on 7/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import WebKit

class SMServicesViewController:UIViewController,UIWebViewDelegate {
    
  
    @IBOutlet weak var serviceWebView: UIWebView!
    var refController:UIRefreshControl = UIRefreshControl()
    override func viewDidLoad() {
        self.SMTitle = "services.tab.title".localized
        let request = URLRequest.init(url: URL.init(string: "http://192.168.95.61:3000/")!)
        serviceWebView.isOpaque = false;
        serviceWebView.backgroundColor = UIColor.clear
        serviceWebView.scalesPageToFit = true;
        serviceWebView.delegate = self
        serviceWebView.loadRequest(request)
        SMLoading.showLoadingPage(viewcontroller: self)
        refController.bounds = CGRect.init(x: 0, y: 50, width: refController.bounds.size.width, height: refController.bounds.size.height)
        refController.addTarget(self, action: #selector(mymethodforref(refresh:)), for: UIControl.Event.valueChanged)
        refController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        serviceWebView.scrollView.addSubview(refController)
        
    }
    
    @objc
    func mymethodforref(refresh:UIRefreshControl){
        serviceWebView.reload()
        refController.endRefreshing()
    }
   
    func webViewDidStartLoad(_ webView: UIWebView) {
       // SMLoading.showLoadingPage(viewcontroller: self)
    }
    
    
    func webViewDidFinishLoad(_ webView : UIWebView) {
        //Page is loaded do what you want
        SMLoading.hideLoadingPage()
        
        
    }
    
   
   
    
  
    
    func addBackButton() {
        let btn = UIButton(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        btn.setImage(UIImage.init(named:"arrow_back_white"), for: .normal)
        btn.addTarget(self, action: #selector(self.pressedBack), for: .touchUpInside)
        btn.titleLabel?.font = SMFonts.IranYekanBold(18)
        btn.setTitleColor(UIColor(netHex: 0x03a9f4), for: .normal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
        
    }
    
    @objc func pressedBack() {
        if(serviceWebView.canGoBack) {
            serviceWebView.goBack()
        } else {
            self.navigationController?.popViewController(animated:true)
        }
        
    }
    
    
    
    
}
