//
//  PrivacyPolicyViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/17.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: BaseViewController {
    
    // MARK: - properties
     
    private lazy var webView: WKWebView = {
        
        let web = WKWebView()
        
        web.navigationDelegate = self
        
        return web
    }()
    
    // MARK: - methods
    
    private func loadURL() {
        
        let privacyPolicyURL = "https://www.privacypolicies.com/live/f869d812-3028-4bdf-bf0d-e842ec6c2c30"
        
        if let url = URL(string: privacyPolicyURL) {
            
            let request = URLRequest(url: url)
            
            webView.load(request)
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
        
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
}

// MARK: - WKNavigationDelegate

extension PrivacyPolicyViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
    
}

extension PrivacyPolicyViewController {
    
    private func setWebView() {
        
        view.stickSubView(webView)
        
        view.sendSubviewToBack(webView)
    }
}
