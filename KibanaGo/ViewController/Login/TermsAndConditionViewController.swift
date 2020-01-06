//
//  TermsAndConditionViewController.swift
//  KibanaGo
//
//  Created by Rameez on 3/29/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class TermsAndConditionViewController: BaseViewController {

    public typealias DidAcceptTermsAndCondition = (_ accepted: Bool) -> Void

    var didAccept: DidAcceptTermsAndCondition?

    @IBOutlet weak var termsAndConditionWebView: UIWebView!
    
    var termsAndConditionLink: String?
    
    var termsAndConditionString: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet var holderView: UIView?
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let theme = CurrentTheme
        view.backgroundColor = theme.cellBackgroundColor
        holderView?.backgroundColor = theme.cellBackgroundColor
        termsAndConditionWebView.backgroundColor = theme.cellBackgroundColor
        
        titleLabel.text = "Terms & Condition".localiz()
        titleLabel.style(theme.headLineTextStyle())
//        closeButton.style(theme.headLineTextStyle())
        cancelButton.style(theme.headLineTextStyle(theme.standardColor))
        agreeButton.style(theme.headLineTextStyle(theme.standardColor))

        let closeIcon = "close"
        closeButton.setImage(UIImage(named: closeIcon), for: .normal)
        setupTermsAndCondition()
        preferredContentSize = CGSize(width: view.frame.width * 0.5, height: view.frame.height * 0.8)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupTermsAndCondition() {
        
        if let termsLinkString = termsAndConditionLink {
            guard let url = URL(string: termsLinkString) else {
                return
            }
            
            let request = URLRequest(url: url)
            termsAndConditionWebView.loadRequest(request)
        } else if let termsAndConditionString = termsAndConditionString {
            termsAndConditionWebView.loadHTMLString(termsAndConditionString, baseURL: nil)
        }
    }
    
    //MARK:
    @IBAction func agreeButtonAction(_ sender: UIButton) {
        dismiss(animated: true) {
            self.didAccept?(true)
        }
        
    }
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        dismiss(animated: true) {
            self.didAccept?(false)
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
