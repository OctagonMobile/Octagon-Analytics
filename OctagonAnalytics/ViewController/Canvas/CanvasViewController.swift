//
//  CanvasViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 7/21/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class CanvasViewController: BaseViewController {

    @IBOutlet var canvasWebView: WKWebView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var canvas: Canvas?
        
    private var currentPage: Int    =   1
    
    fileprivate lazy var hud: MBProgressHUD = {
        let loader = MBProgressHUD.refreshing(addedTo: self.view)
        loader.backgroundView.backgroundColor = CurrentTheme.lightBackgroundColor
        return loader
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title   =  canvas?.name ??  "Canvas".localiz()
        
        canvasWebView.navigationDelegate = self
        canvasWebView.isUserInteractionEnabled = false
        canvasWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pageControl.numberOfPages = canvas?.pages.count ?? 1
        pageControl.currentPage = 0
        
        tabBarController?.setTabBarVisible(visible: false, duration: 0.0, animated: false)

        hud.show(animated: true)
        loadCanvas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func leftBarButtons() -> [UIBarButtonItem] {
        return []
    }
        
    private func loadCanvas() {
        
        guard let id = canvas?.id else { return }
        let urlString = Configuration.shared.environment.baseUrl + "/app/canvas#/workpad/\(id)/page/\(currentPage)?__fullscreen=true"
        guard let url = URL(string: urlString) else { return }
        _ = canvasWebView?.load(URLRequest(url: url))
    }

    //MARK: Button Action
    @IBAction func leftSwipeAction(_ sender: UISwipeGestureRecognizer) {
        guard let canvas = self.canvas,
            (currentPage + 1) <= canvas.pages.count else { return }
        currentPage += 1
        pageControl.currentPage = (currentPage-1)
        loadCanvas()
    }
    
    @IBAction func rightSwipeAction(_ sender: UISwipeGestureRecognizer) {
        guard (currentPage - 1) > 0 else { return }
        currentPage -= 1
        pageControl.currentPage = (currentPage-1)
        loadCanvas()
    }
    
    @IBAction func tapGestureAction(_ sender: Any) {
        let shouldHideNavigationBar = navigationController?.isNavigationBarHidden ?? false
        navigationController?.setNavigationBarHidden(!shouldHideNavigationBar, animated: true)
        
        let shouldHideTabBar = tabBarController?.tabBarIsVisible() ?? false
        tabBarController?.setTabBarVisible(visible: !shouldHideTabBar, duration: 0.0, animated: true)
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hud.hide(animated: false)
    }
}

extension CanvasViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
