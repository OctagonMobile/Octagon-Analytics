//
//  MapTrackingAnnotationView.swift
//  KibanaGo
//
//  Created by Rameez on 4/8/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class MapTrackingAnnotationView: MKAnnotationView {

    private var mapTrackingAnnotationView: MapTrackingAnnotationView?
    
    private var backgroundColorView: UIView?
    
    var annotationBackgroundColor: UIColor = CurrentTheme.darkBackgroundColor {
        didSet {
            backgroundColorView?.backgroundColor = annotationBackgroundColor
        }
    }
    
    //MARK:
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup(annotation as? UserPointAnnotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(_ annotation: UserPointAnnotation?) {
        
        let padding: CGFloat    = 50
        let width: CGFloat      = 30
        let height: CGFloat     = 35
        self.frame = CGRect(x: -width/2, y: -(height + padding), width: width, height: height)
        self.clipsToBounds = true

        var innerViewFrame = bounds
        
        let placeHolderImage = UIImage(named: "UserAnnotation")
        let imageView = UIImageView(image: placeHolderImage)
        imageView.contentMode = .scaleAspectFit
        if let imageIconUrlString = annotation?.imageIconUrl, let url = URL(string:imageIconUrlString) {
            imageView.af_setImage(withURL: url, placeholderImage: placeHolderImage)
            imageView.style(.roundCorner(5.0, 1.0, .white))
            innerViewFrame.size.height = height
            self.style(.shadow(opacity: 1.0, colorAlpha: 1.0))
        } else {
            imageView.image = placeHolderImage
            innerViewFrame.size.height = height - 5.0
            self.style(.shadow(opacity: 0.5, colorAlpha: 1.0))
        }
        
        backgroundColorView = UIView(frame: innerViewFrame)
        backgroundColorView?.style(.roundCorner(5.0, 0.0, .clear))
        if let backgroundColorView = backgroundColorView {
            addSubview(backgroundColorView)
        }

        imageView.frame = bounds
        addSubview(imageView)
        
    }
}
