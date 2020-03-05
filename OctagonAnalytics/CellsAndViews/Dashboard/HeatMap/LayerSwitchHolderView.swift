//
//  LayerSwitchHolderView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/25/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class LayerSwitchHolderView: UIView {

    typealias LayerSwitchActionBlock = (_ sender: LayerSwitchHolderView, _ mapLayer: MapLayer) -> Void
    typealias LoadDefaultLayer = (_ sender: LayerSwitchHolderView) -> Void

    var selectedLayer: MapLayer?
    
    var titleString: String =   "Layers Switch"
    var layerSwitchActionBlock: LayerSwitchActionBlock?
    var loadDefaultBlock: LoadDefaultLayer?

    fileprivate var buttonsTotalHeight: CGFloat = 0
    @IBOutlet weak var holderHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var showLayerButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var buttonsHolder: UIView?
    @IBOutlet weak var defaultLayerButton: UIButton?
    
    var layers: [MapLayer]  =   [] {
        didSet {
            setup()
        }
    }
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        
        backgroundColor = .clear
        buttonsHolder?.backgroundColor = .clear
        defaultLayerButton?.style(CurrentTheme.headLineTextStyle())
        defaultLayerButton?.style(.roundCorner(5.0, 1.0, CurrentTheme.separatorColor))

    }
    
    func setup()  {
        
        titleLabel?.text = titleString
        guard layers.count > 0, let holder = buttonsHolder else { return }

        holder.subviews.forEach( { $0.removeFromSuperview()} )
        
        
        let buttonHeight = 30
        let buttonSpacingVertical = 5
        var buttons = [String: UIButton]()
        var allConstraints = [NSLayoutConstraint]()
        var verticalConstraintsString = "V:|-\(buttonSpacingVertical)-"

        for (index,layer) in layers.enumerated() {
            
            let buttonId = "button\(index)"
            let button = MapLayerButton(type: .custom)
            button.titleLabel?.numberOfLines = 2
            button.setTitle(layer.buttonTitle, for: .normal)
            button.style(CurrentTheme.caption1TextStyle())
            button.style(.roundCorner(5.0, 1.0, CurrentTheme.separatorColor))
            button.backgroundColor = selectedLayer?.layerName == layer.layerName ? CurrentTheme.standardColor : .white
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
            button.addTarget(self, action: #selector(LayerSwitchHolderView.buttonAction(_:)), for: .touchUpInside)
            button.mapLayer = layer
            button.translatesAutoresizingMaskIntoConstraints = false
            holder.addSubview(button)
            
            buttons[buttonId] = button

            // add vertical constraints to label
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[\(buttonId)]-5-|", options: [], metrics: nil, views: buttons)
            allConstraints.append(contentsOf: horizontalConstraints)
            
            // add label to horizontal VFL string
            verticalConstraintsString += "[\(buttonId)(\(buttonHeight))]-\(buttonSpacingVertical)-"

        }
        verticalConstraintsString += "|"
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat:verticalConstraintsString, options: [], metrics: nil, views: buttons)
        allConstraints.append(contentsOf:horizontalConstraints)
        NSLayoutConstraint.activate(allConstraints)

        buttonsTotalHeight = CGFloat((buttonHeight * layers.count) + ((layers.count + 1) * buttonSpacingVertical))
        holderHeightConstraint?.constant = showLayerButton?.isSelected == true ? buttonsTotalHeight : 0
    }
    
    private func updateSelectedButtons() {
        buttonsHolder?.subviews.forEach({ (btn) in
            guard let button = btn as? MapLayerButton else { return }
            let isSelected = button.mapLayer?.layerName == selectedLayer?.layerName
            button.backgroundColor = isSelected ? CurrentTheme.standardColor : .white
        })
    }
    
    @objc func buttonAction(_ sender: MapLayerButton) {
        
        guard let selectedMapLayer = sender.mapLayer else { return }
        selectedLayer = selectedMapLayer
        updateSelectedButtons()
        
        layerSwitchActionBlock?(self, selectedMapLayer)
    }

    @IBAction func showOrHideLayersAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let height = sender.isSelected ? buttonsTotalHeight : 0
        
        let initialAlpha: CGFloat = sender.isSelected ? 0.0 : 1.0
        let endAlpha: CGFloat = sender.isSelected ? 1.0 : 0.0

        self.buttonsHolder?.alpha = initialAlpha
        if sender.isSelected {
            self.holderHeightConstraint?.constant = height
        }

        UIView.animate(withDuration: 0.5, animations: {
            self.buttonsHolder?.alpha = endAlpha
        }) { (complete) in
            
            if !sender.isSelected {
                self.holderHeightConstraint?.constant = height
            }
        }
    }
    
    @IBAction func defaultLayerButtonAction(_ sender: UIButton) {
        loadDefaultBlock?(self)
    }
}

class MapLayerButton: UIButton {
    var mapLayer: MapLayer?
}
