//
//  RecordButton.swift
//  OctagonAnalytics
//
//  Created by Rameez on 28/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "Record"), for: .normal)
        layer.backgroundColor = UIColor.red.cgColor
        layer.cornerRadius = frame.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
