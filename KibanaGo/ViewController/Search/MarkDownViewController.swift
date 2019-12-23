//
//  MarkDownViewController.swift
//  KibanaGo
//
//  Created by Rameez on 7/31/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import MarkdownView

class MarkDownViewController: PanelBaseViewController {

    @IBOutlet weak var markdownView: MarkdownView!
    
    //MARK: Functions
    override func setupPanel() {
        super.setupPanel()
        markdownView.backgroundColor = .clear
        
        guard let visState = (panel?.visState as? MarkDownVisState) else { return }
        markdownView.load(markdown: visState.markdownText)
    }
    
    override func loadChartData() {
        // Do nothing
    }
}
