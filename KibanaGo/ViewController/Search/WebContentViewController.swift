//
//  WebContentViewController.swift
//  KibanaGo
//
//  Created by Rameez on 2/27/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import WebKit

class WebContentViewController: PanelBaseViewController {

    fileprivate var webView: WKWebView?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialConfig()
    }
    
    private func initialConfig() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: displayContainerView.bounds, configuration: webConfiguration)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        guard let web = webView else { return }
        displayContainerView.addSubview(web)
        
        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["displayContainerView": displayContainerView, "web": webView!]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[web]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[web]-0-|", options: [], metrics: nil, views: views)
        displayContainerView?.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
    
    override func loadChartData() {
        // Load nothing
        updatePanelContent()
    }
    
    override func updatePanelContent() {

        guard var htmlString = (panel?.visState as? WebContentVisState)?.htmlString else { return }
        
        htmlString = htmlString.replacingOccurrences(of: "\\n", with: "")
        htmlString = htmlString.replacingOccurrences(of: "\\", with: "")
        webView?.loadHTMLString(htmlString, baseURL: nil)
    }
    
}
