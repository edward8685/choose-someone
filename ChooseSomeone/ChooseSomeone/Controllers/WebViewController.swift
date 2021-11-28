//
//  WebViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/17.
//

import UIKit
import WebKit

protocol policy {
    
    var url: String { get }
}

enum PolicyType: String, policy {
    
    case privacy
    
    case eula
    
    var url: String {
        
        switch self {
            
        case .privacy: return "https://www.privacypolicies.com/live/f869d812-3028-4bdf-bf0d-e842ec6c2c30"
            
        case .eula: return "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        }
    }
}

class WebViewController: BaseViewController {
    
    // MARK: - Class Properties -
    
    var policyType: PolicyType?
    
    private lazy var webView: WKWebView = {
        
        let web = WKWebView()
        
        web.navigationDelegate = self
        
        return web
    }()
    
    // MARK: - Methods -
    
    private func loadURL(type: PolicyType) {
        
        if let url = URL(string: type.url) {
            
            let request = URLRequest(url: url)
            
            webView.load(request)
        }
    }
    
    private func setWebView() {
        
        view.stickSubView(webView)
        
        view.sendSubviewToBack(webView)
    }
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
        
        if let policyType = policyType {
            loadURL(type: policyType)
        }
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

// MARK: - WKNavigation Delegate -

extension WebViewController: WKNavigationDelegate {
    
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
