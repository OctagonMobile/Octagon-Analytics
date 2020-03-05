//
//  GraphWeightView.swift
//  Graphite
//
//  Created by Palle Klewitz on 18.12.17.
//  Copyright (c) 2017 Palle Klewitz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import UIKit

open class GraphWeightView: UIView {
    public var edgesList: [(UIView, UIView, Graph.Edge)] = []

	public var weights: [(UIView, UIView, Double)] = []
	public var strokeColor: UIColor = .white {
		didSet {
			layer.setNeedsDisplay()
		}
	}
	
	var onLayout: (() -> ())? = nil
	var onTouchesBegan: (() -> ())? = nil
	
	public var showsHiddenNodeEdges: Bool = false
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		
		self.layer.contentsScale = self.window?.screen.scale ?? UIScreen.main.scale
	}
	
	private func initialize() {
		self.layer.contentsScale = UIScreen.main.scale
		self.layer.drawsAsynchronously = true
		self.layer.setNeedsDisplay()
	}
    
	open override func draw(_ layer: CALayer, in ctx: CGContext) {
		guard layer == self.layer else {
			return
		}
		
		ctx.clear(self.bounds)
		ctx.setStrokeColor(strokeColor.cgColor)
		
		for (v1, v2, edge) in edgesList where showsHiddenNodeEdges || (!v1.isHidden && !v2.isHidden) {
            
            let radius: CGFloat = 35

            // New From & To point for edges inorder to start the edge from/to circumference
            let denominator = sqrt( pow(v2.center.x - v1.center.x, CGFloat(2)) + pow(v2.center.y - v1.center.y, CGFloat(2)))
            let newFromPointXValue = v1.center.x + ((radius * (v2.center.x - v1.center.x)) / denominator)
            let newFromPointYValue = v1.center.y + ((radius * (v2.center.y - v1.center.y)) / denominator)
            let newFromPoint = CGPoint(x: newFromPointXValue, y: newFromPointYValue)

            let newToPointXValue = v2.center.x + ((radius * (v1.center.x - v2.center.x)) / denominator)
            let newToPointYValue = v2.center.y + ((radius * (v1.center.y - v2.center.y)) / denominator)
            let newToPoint = CGPoint(x: newToPointXValue, y: newToPointYValue)

            guard denominator > 0 else { continue }

            let path = UIBezierPath()
            path.addArrow(start: newFromPoint, end: newToPoint, pointerLineLength: 10, arrowAngle: CGFloat(Double.pi / 4))
            ctx.addPath(path.cgPath)
            ctx.setLineWidth(CGFloat(edge.weight) * 3 + 2)
            ctx.setAlpha(CGFloat(edge.weight) * 0.5 + 0.5)

//            ctx.move(to: v1.center)
//            ctx.addLine(to: v2.center)
//            ctx.setLineWidth(CGFloat(edge.weight) * 3 + 2)
//            ctx.setAlpha(CGFloat(edge.weight) * 0.5 + 0.5)
            
            ctx.strokePath()
		}
        
        
        
        UIGraphicsPushContext ( ctx )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
            NSAttributedString.Key.foregroundColor: UIColor.gray
            ] as [NSAttributedString.Key : Any]

        for (v1, v2, edge) in edgesList where showsHiddenNodeEdges || (!v1.isHidden && !v2.isHidden) {

            let centerPoint = CGPoint(x: (v1.center.x + v2.center.x) / 2, y: (v1.center.y + v2.center.y) / 2)
            let rightCenterPoint = CGPoint(x: (v2.center.x + centerPoint.x) / 2, y: (v2.center.y + centerPoint.y) / 2)
            ("\(edge.edgeName)" as NSString).draw(at: rightCenterPoint, withAttributes: attributes)

//            let angle = atan2(v2.center.y - v1.center.y, v2.center.x - v1.center.x)
//            ("\(edge.edgeName)" as NSString).drawWithBasePoint(basePoint: centerPoint, andAngle: CGFloat(angle), andAttributes: attributes as [NSAttributedString.Key : AnyObject], context: ctx)
        }
        UIGraphicsPopContext()
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		onLayout?()
	}
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		onTouchesBegan?()
	}
}

extension UIBezierPath {
    func addArrow(start: CGPoint, end: CGPoint, pointerLineLength: CGFloat, arrowAngle: CGFloat) {
        self.move(to: start)
        self.addLine(to: end)
        
        let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))

        self.addLine(to: arrowLine1)
        self.move(to: end)
        self.addLine(to: arrowLine2)
    }
}

extension NSString {
    func drawWithBasePoint(basePoint: CGPoint, andAngle angle: CGFloat, andAttributes attributes: [NSAttributedString.Key: AnyObject], context: CGContext) {
        let radius: CGFloat = 100
        let textSize: CGSize = self.size(withAttributes: attributes)
        let t: CGAffineTransform = CGAffineTransform(translationX: basePoint.x, y: basePoint.y)
        let r: CGAffineTransform = CGAffineTransform(rotationAngle: angle)
        context.concatenate(t)
        context.concatenate(r)
        self.draw(at: CGPoint(x: radius-textSize.width/2, y: -textSize.height/2), withAttributes: attributes)
        context.concatenate(r.inverted())
        context.concatenate(t.inverted())
    }
}
