//
//  ChartLegendTableViewCell.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ChartLegendTableViewCell: UITableViewCell {
    
    private static let FormBaseWidth: CGFloat = 25
    private static let FormBaseHeight: CGFloat = 26
    
    @IBOutlet var shape: UIView!
    @IBOutlet var titleLabel: UILabel!
    private var shapeLayer: CAShapeLayer?
    
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
                
                shapeLayer?.removeFromSuperlayer()
                shapeLayer = CAShapeLayer()

                let circlePath: UIBezierPath =  {
                    switch legend.shape {
                    case .circle(let radius):
                        return UIBezierPath(arcCenter: CGPoint(x: ChartLegendTableViewCell.FormBaseWidth/2, y: ChartLegendTableViewCell.FormBaseHeight/2), radius: radius, startAngle: 0, endAngle: (2 * CGFloat(CGFloat.pi)), clockwise: true)
                    case .rect(let width, let height):
                        return UIBezierPath(roundedRect: CGRect(x: ChartLegendTableViewCell.FormBaseWidth/2 - width/2, y: ChartLegendTableViewCell.FormBaseHeight/2 - height/2, width: width, height: height), cornerRadius: 5.0)
                    }
                }()
                
                shapeLayer?.path = circlePath.cgPath
                shapeLayer?.fillColor = legend.color.cgColor
                shapeLayer?.frame = shape.bounds
                shape.layer.addSublayer(shapeLayer!)
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
