//
//  RecordButton.swift
//  OctagonAnalytics
//
//  Created by Rameez on 28/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
    
    private var fromColor: UIColor = UIColor.colorFromHexString("FF453A")
    private var toColor: UIColor = UIColor.colorFromHexString("FF3B30")

    //MARK: Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "Record"), for: .normal)
        layer.backgroundColor = fromColor.cgColor
        layer.cornerRadius = frame.height / 2
        animateBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animateBackground() {

        let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
        colourAnim.repeatCount = .infinity
        colourAnim.fromValue = fromColor.cgColor
        colourAnim.toValue = toColor.cgColor
        colourAnim.duration = 1.0
        colourAnim.fillMode = .forwards
        colourAnim.isRemovedOnCompletion = false
        layer.add(colourAnim, forKey: "colourAnimation")
    }
}
