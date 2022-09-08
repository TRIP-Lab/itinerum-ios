//
//  WebVC.swift
//  ItinerumBase
//
//  Created by Chandramani choudhary on 8/18/18.
//  Copyright © 2018 Chandramani choudhary. All rights reserved.
//

import UIKit

class WebVC: BaseVC {
    @IBOutlet weak var webView:UIWebView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    var urlString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(urlString != nil, "Please pass the link!!")
        let requestObj = URLRequest(url: URL.init(string: urlString!)!)
        self.webView.loadRequest(requestObj)
    }
    
    func showLoadingInd() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingInd() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

extension WebVC : UIWebViewDelegate {
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        self.showLoadingInd()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideLoadingInd()
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        //self.showAlertWithDisappearingTitle(message: error.localizedDescription)
    }
    
}
