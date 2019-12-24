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
import WebKit

class IGiGapBrowser: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate {
    
    @IBOutlet var mainView: UIView!
    
    var webView: WKWebView!
    var webViewProgressbar: UIActivityIndicatorView!
    var htmlString : String!
    var itemID : Int32!
    var url: String!
    var isPost : Bool = false
    var param: String = ""
    var pageTitle: String = ""
    var tapCounter : Int! = 0
    var btnAgree : UIButtonX!
    var lblAgrement : UILabel!
    var checkBtn : UIButtonX!

    var request : URLRequest!
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        if (htmlString == nil) {
            if isPost {
                request.httpMethod = "POST"
                let postString = "id=\(param)"
                request.httpBody = postString.data(using: .utf8)
                openWebViewForPostReq(request: request)
            } else {
                openWebView(url: self.url)
            }
            webView.configuration.userContentController.add(self, name: "iosJsHandler")
        }
        else {
            openWebViewWithHTMLString(string: htmlString)
            webView.configuration.userContentController.add(self, name: "iosJsHandler")
        }
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: pageTitle)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.backViewContainer?.addAction {
            self.back()
        }
    }
    
    /*************** web view manager ***************/
    private func openWebView(url:String)  {
        
        makeWebView()
        
        self.webView.isHidden = false
        self.view.endEditing(true)
        
        let url = URL(string: url)
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.webView?.load(request)
                    }
                } else {
                    print("ERROR: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
    private func openWebViewForPostReq(request:URLRequest)  {
        
        makeWebView()
        
        self.webView.isHidden = false
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            self.webView.load(request) //if your `webView` is `UIWebView`
        }
    }
    private func openWebViewWithHTMLString(string:String)  {
        
        makeWebViewForAgreement()
        
        self.webView.isHidden = false
        self.view.endEditing(true)
        if SMLangUtil.loadLanguage() == "fa" {
            self.webView.loadHTMLString(htmlString.replacingOccurrences(of: "justify", with: "right"), baseURL: nil)
        } else {
            self.webView.loadHTMLString(htmlString.replacingOccurrences(of: "justify", with: "center"), baseURL: nil)
        }
        makeAgrementBtns()
        
    }
    
    
    func closeWebView() {
        self.webView.stopLoading()
        self.webView.isHidden = true
        removeWebView()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func makeWebView(){
        if self.webView == nil {
            self.webView = WKWebView()
        }
        mainView.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.right.equalTo(mainView.snp.right)
            make.left.equalTo(mainView.snp.left)
        }
        self.webView.navigationDelegate = self
    }
    private func makeWebViewForAgreement(){
        if self.webView == nil {
            self.webView = WKWebView()
        }
        mainView.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom).offset(-70)
            make.right.equalTo(mainView.snp.right)
            make.left.equalTo(mainView.snp.left)
        }
        self.webView.navigationDelegate = self
    }
    private func makeAgrementBtns(){

        
        btnAgree = UIButtonX()
        lblAgrement = UILabel()
        checkBtn = UIButtonX()
        
        btnAgree.backgroundColor = UIColor.iGapGray()
        btnAgree.cornerRadius = 7.0
        btnAgree.popIn = true
        btnAgree.setTitle(IGStringsManager.GlobalOKandGo.rawValue.localized, for: .normal)
        btnAgree.titleLabel?.font = UIFont.igFont(ofSize: 20,weight: .bold)
        btnAgree.titleLabel?.textColor = UIColor.white
        btnAgree.isUserInteractionEnabled = false
        btnAgree.addTarget(self, action: #selector(self.didTapOnAgreeAndGo(sender:)), for: .touchUpInside)

        mainView.addSubview(btnAgree)
        
        btnAgree.snp.makeConstraints { (make) in
            make.bottom.equalTo(mainView.snp.bottom).offset(-2)
            make.height.equalTo(40)
            make.right.equalTo(mainView.snp.right).offset(-10)
            make.left.equalTo(mainView.snp.left).offset(10)
        }
        checkBtn.backgroundColor = UIColor.clear
        checkBtn.borderColor = UIColor.black
        checkBtn.borderWidth = 2.0
        checkBtn.cornerRadius = 7.0
        checkBtn.popIn = true
        checkBtn.addTarget(self, action: #selector(self.didTapOnCheckBox(sender:)), for: .touchUpInside)

        mainView.addSubview(checkBtn)
        checkBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(btnAgree.snp.top).offset(-5)
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.left.equalTo(btnAgree.snp.left)
        }

        lblAgrement.text = IGStringsManager.AcceptTheTerms.rawValue.localized
        lblAgrement.font = UIFont.igFont(ofSize: 15,weight: .bold)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnLbl))
        lblAgrement.isUserInteractionEnabled = true
        lblAgrement.addGestureRecognizer(tap)

        mainView.addSubview(lblAgrement)
        lblAgrement.snp.makeConstraints { (make) in
            make.bottom.equalTo(checkBtn.snp.bottom)
            make.left.equalTo(checkBtn.snp.right).offset(5)
        }

    }
    @objc
    func didTapOnLbl(sender:UITapGestureRecognizer) {
        tapCounter += 1
        if tapCounter % 2 == 0 {
            checkBtn.backgroundColor = .clear
            btnAgree.isUserInteractionEnabled = false
            btnAgree.backgroundColor = UIColor.iGapGray()
        } else {
            checkBtn.backgroundColor = .black
            btnAgree.isUserInteractionEnabled = true
            btnAgree.backgroundColor = UIColor.iGapGreen()
        }
    }
    @objc func didTapOnAgreeAndGo(sender: UIButtonX!) {
        btnAgree.removeFromSuperview()
        lblAgrement.removeFromSuperview()
        checkBtn.removeFromSuperview()
        self.webView.snp.updateConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.right.equalTo(mainView.snp.right)
            make.left.equalTo(mainView.snp.left)
        }
        self.mainView.layoutIfNeeded()
        self.webView.layoutIfNeeded()

        
        carpinoAggrement(itemID: itemID)
    }
    @objc func didTapOnCheckBox(sender: UIButtonX!) {
        tapCounter += 1
        if tapCounter % 2 == 0 {
            checkBtn.backgroundColor = .clear
            btnAgree.isUserInteractionEnabled = false
            btnAgree.backgroundColor = UIColor.iGapGray()
        } else {
            checkBtn.backgroundColor = .black
            btnAgree.isUserInteractionEnabled = true
            btnAgree.backgroundColor = UIColor.iGapGreen()
        }
    }
    //setAgreement Slug and Go
    private func carpinoAggrement(itemID:Int32!) {
        self.webView.load(URLRequest.init(url: URL.init(string: "about:blank")!))

        IGClientSetDiscoveryItemAgreemnetRequest.Generator.generate(itemId: itemID).success { (responseProto) in
            DispatchQueue.main.async {
                IGGlobal.carpinoAgreement = true

                
                let url = URL(string: self.url)
                if let unwrappedURL = url {
                    
                    let request = URLRequest(url: unwrappedURL)
                    let session = URLSession.shared
                    
                    
                    let task = session.dataTask(with: request) { (data, response, error) in
                        
                        if error == nil {
                            DispatchQueue.main.async {
                                self.webView?.load(request)
                            }
                        } else {
                            self.webView.load(URLRequest.init(url: URL.init(string: "about:blank")!))
                        }
                    }
                    task.resume()
                }
                
                }
            }.error { (errorCode, waitTime) in
            }.send()
    }
    
    //
    private func removeWebView(){
        if self.webView != nil {
            self.webView.removeFromSuperview()
            self.webView = nil
        }
    }
    
    private func makeWebViewProgress(){
        if webViewProgressbar == nil {
            webViewProgressbar = UIActivityIndicatorView()
            webViewProgressbar.hidesWhenStopped = true
            webViewProgressbar.color = UIColor.darkGray
        }
        webView.addSubview(webViewProgressbar)
        
        webViewProgressbar.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.centerX.equalTo(webView.snp.centerX)
            make.centerY.equalTo(webView.snp.centerY)
        }
    }
    
    private func removeWebViewProgress(){
        if self.webViewProgressbar != nil {
            self.webViewProgressbar.removeFromSuperview()
            self.webViewProgressbar = nil
        }
    }
    
    
    func back() { // this back  when work that webview is working
        if webView == nil || webView.isHidden {
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.backViewContainer?.isUserInteractionEnabled = false
            _ = self.navigationController?.popViewController(animated: true)
        } else if webView.canGoBack {
            webView.goBack()
        } else {
            closeWebView()
        }
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        removeWebViewProgress()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {}
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        removeWebViewProgress()
        let title = webView.stringByEvaluatingJavaScript(from: "document.title")
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: title)
        navigationItem.backViewContainer?.addAction {
            self.back()
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if request.url?.description == "igap://close" {
            closeWebView()
        } else {
            makeWebViewProgress()
            webViewProgressbar.startAnimating()
        }
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            if url.absoluteString == "igap://close" {
                closeWebView()
            }
        }
        decisionHandler(.allow)
    }
}

extension IGiGapBrowser: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iosJsHandler" {
            print(message.body)
            IGGlobal.prgShow()
            IGApiPayment.shared.orderCheck(token: message.body as! String, completion: { (success, payment, errorMessage) in
                IGGlobal.prgHide()
                let paymentView = IGPaymentView.sharedInstance
                if success {
                    guard let paymentData = payment else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        return
                    }
                    paymentView.show(on: UIApplication.shared.keyWindow!, title: self.pageTitle, payToken: message.body as! String, payment: paymentData)
                } else {
                    
                    paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: self.pageTitle, message: errorMessage ?? "", payToken: message.body as! String)
                }
            })
        }
    }
}
