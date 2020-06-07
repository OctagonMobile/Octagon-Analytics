//
//  ChartLegendTableViewCell.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ChartLegendTableViewCell: UITableViewCell {
    
    @IBOutlet var shape: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    var bgColor: UIColor? {
        didSet {
            self.backgroundColor = bgColor
            self.contentView.backgroundColor = backgroundColor
        }
    }
    
    var legend: ChartLegendType? {
        didSet {
            if let legend = legend {
                
                titleLabel.text = legend.text
                
                titleLabel.font = legend.font ?? UIFont.systemFont(ofSize: 12)

                if let textColor = legend.textColor {
                    titleLabel.textColor = textColor
                }
                
                let shapeLayer = CAShapeLayer()

                let circlePath: UIBezierPath =  {
                    switch legend.shape {
                    case .circle(let radius):
                        return UIBezierPath(arcCenter: CGPoint(x: shape.bounds.center.x, y: shape.bounds.center.y), radius: radius, startAngle: 0, endAngle: (2 * CGFloat(CGFloat.pi)), clockwise: true)
                    case .rect(let width, let height):
                        return UIBezierPath(roundedRect: CGRect(x: shape.bounds.center.x - width / 2, y: shape.bounds.center.y - height / 2, width: width, height: height), cornerRadius: 5.0)
                    }
                }()
                
                shapeLayer.path = circlePath.cgPath
                shapeLayer.fillColor = legend.color.cgColor
                shapeLayer.frame = shape.bounds
                shape.layer.addSublayer(shapeLayer)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
