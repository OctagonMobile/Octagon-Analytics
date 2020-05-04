//
//  CustomHudView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 5/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class CustomHudView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
    
    private func initialSetup() {
        let imageName = CurrentTheme.isDarkTheme ? "OctagonAnalyticsLogo" : "ProgressLogo-Light"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.frame = bounds
        addSubview(imageView)
    }
}
