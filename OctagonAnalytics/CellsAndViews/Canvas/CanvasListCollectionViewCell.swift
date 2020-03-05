//
//  CanvasListCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit

class CanvasListCollectionViewCell: UICollectionViewCell {
    
    var canvas: Canvas? {
        didSet {
            updateContent()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateSelectionColor()
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var canvasTitleLabel: UILabel?
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    func updateUI() {
        let size = canvasTitleLabel?.font.pointSize ?? 15.0
        canvasTitleLabel?.style(CurrentTheme.textStyleWith(size, weight: .regular))
        containerView.style(.roundCorner(5.0, 2.0, CurrentTheme.cellBackgroundColor))
        style(.shadow())
    }

    private func updateContent() {
        canvasTitleLabel?.text = canvas?.name
    }
    
    fileprivate func updateSelectionColor() {
        containerView.backgroundColor =  isHighlighted ? CurrentTheme.headerViewBackground : CurrentTheme.cellBackgroundColor
    }

}
