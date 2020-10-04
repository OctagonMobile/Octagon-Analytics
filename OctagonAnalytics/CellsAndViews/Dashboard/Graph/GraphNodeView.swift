//
//  GraphNodeView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import AlamofireImage

class GraphNodeView: UIView {

    var imageBaseUrl: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var nodeImageView: UIImageView!
    //MARK:
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = CurrentTheme.standardColor
        layer.borderColor = CurrentTheme.enabledStateBackgroundColor.cgColor
        layer.borderWidth = 1.0
    }
        
    func setup(_ selectedNode: NeoGraphNode) {
        self.layer.cornerRadius = self.frame.size.width / 2
        titleLabel.text = selectedNode.number ?? selectedNode.name
        if let imageBaseUrl = imageBaseUrl, let urlString = selectedNode.imageUrl, let url = URL(string: imageBaseUrl + urlString) {
            nodeImageView.af.setImage(withURL: url)
        }

    }
}
