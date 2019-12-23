//
//  SavedSearchPopOverViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/14/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit

class SavedSearchPopOverViewController: BaseViewController {

    var savedSearch: SavedSearch?

    var backgroundImage: UIImage?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var jsonDisplayTextView: UITextView!

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    //MARK: Overridden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        titleLabel.style(CurrentTheme.headLineTextStyle(CurrentTheme.secondaryTitleColor))
        view.backgroundColor = .clear
        view.isOpaque = false
        setupPopOverView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shadowView.style(.shadow(opacity: 0.5, colorAlpha: 0.5))
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
    override func leftBarButtons() -> [UIBarButtonItem] {
        return []
    }

    override func leftBarButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Close Action
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Functions
    fileprivate func setupPopOverView() {
        
        backgroundImageView.image = backgroundImage?.blurredImage()
        
        headerView.backgroundColor = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.8)
        containerView.style(.roundCorner(5.0, 0.0, .clear))
        
        jsonDisplayTextView.style(CurrentTheme.calloutTextStyle(CurrentTheme.selectedTitleColor))
        jsonDisplayTextView.text = parsedJsonString(dict: savedSearch?.data ?? [:])
    }
    
    fileprivate func parsedJsonString(dict: Any) -> String {
        do {
            let prettyJsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            guard let prettyJsonString = NSString(data: prettyJsonData, encoding: String.Encoding.utf8.rawValue) as String? else {
                return ""
            }
            return prettyJsonString
            
        } catch {
            return ""
        }
    }
    
}
