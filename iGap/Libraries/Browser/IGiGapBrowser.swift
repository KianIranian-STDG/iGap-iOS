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

class IGiGapBrowser: UIViewController, UIGestureRecognizerDelegate, UIWebViewDelegate {
    
    @IBOutlet var mainView: UIView!
    
    var webView: UIWebView!
    var webViewProgressbar: UIActivityIndicatorView!
    
    var url: String!
    var pageTitle: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        openWebView(url: self.url)
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
                        self.webView?.loadRequest(request)
                    }
                } else {
                    print("ERROR: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
    func closeWebView() {
        self.webView.stopLoading()
        self.webView.isHidden = true
        removeWebView()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func makeWebView(){
        if self.webView == nil {
            self.webView = UIWebView()
        }
        mainView.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.right.equalTo(mainView.snp.right)
            make.left.equalTo(mainView.snp.left)
        }
        self.webView.delegate = self
    }
    
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
}
