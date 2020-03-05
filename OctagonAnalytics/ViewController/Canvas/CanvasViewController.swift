//
//  CanvasViewController.swift
//  KibanaGo
//
//  Created by Rameez on 7/21/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import WebKit

class CanvasViewController: BaseViewController {

    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var canvasWebView: WKWebView!
    
    var canvas: Canvas?
        
    private var currentPage: Int    =   1
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title   =  canvas?.name ??  "Canvas".localiz()
        canvasWebView.navigationDelegate = self
        
        let pagingRightArrowIcon = CurrentTheme.isDarkTheme ? "PagingRightArrow-Dark" : "PagingRightArrow"
        nextButton.setImage(UIImage(named: pagingRightArrowIcon), for: .normal)
        let pagingLeftArrowIcon = CurrentTheme.isDarkTheme ? "PagingLeftArrow-Dark" : "PagingLeftArrow"
        prevButton.setImage(UIImage(named: pagingLeftArrowIcon), for: .normal)

        prevButton.isHidden = canvas?.pages.count ?? 1 <= 1
        nextButton.isHidden = canvas?.pages.count ?? 1 <= 1
        loadCanvas()
    }

    override func leftBarButtons() -> [UIBarButtonItem] {
        return []
    }
    
    private func loadCanvas() {
        
        guard let id = canvas?.id else { return }
        let urlString = Configuration.shared.environment.baseUrl + "/app/canvas#/workpad/\(id)/page/\(currentPage)?__fullscreen=true"
        guard let url = URL(string: urlString) else { return }
        _ = canvasWebView?.load(URLRequest(url: url))
        
        guard let canvas = canvas else { return }
        
        prevButton.isHidden = (canvas.pages.count == 1) || (currentPage == 1)
        nextButton.isHidden = (canvas.pages.count == 1) || (currentPage == canvas.pages.count)

    }
    
    //MARK: Button Action
    @IBAction func nextButtonAction(_ sender: UIButton) {
        guard let canvas = self.canvas,
            (currentPage + 1) <= canvas.pages.count else { return }
        currentPage += 1
        loadCanvas()
    }
    
    @IBAction func previousButtonAction(_ sender: UIButton) {
        guard (currentPage - 1) > 0 else { return }
        currentPage -= 1
        loadCanvas()
    }
}

extension CanvasViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let tabbarController = self.tabBarController as? DashboardTabBarController,
            navigationAction.navigationType == .linkActivated else { decisionHandler(.allow); return }

        //Note: Since the url has an unsafe charecter '#' in the url, url.pathComponents isn't working as expected
        let urlString = navigationAction.request.url?.absoluteString
        let urlPart = urlString?.components(separatedBy: "?").first
        guard let dashboardId = urlPart?.components(separatedBy: "#").last?.components(separatedBy: "/").last else { decisionHandler(.allow); return }
        tabbarController.showDashboard(dashboardId)
        
        decisionHandler(.cancel)
    }
}

