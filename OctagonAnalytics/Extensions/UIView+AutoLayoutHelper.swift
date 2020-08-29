//
//  Extensions.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 07/23/2020.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import Foundation
import UIKit

/**
*  UIView extension to ease creating Auto Layout Constraints
*/
extension UIView {


    // MARK: - Fill

    /**
     Creates and adds an array of NSLayoutConstraint objects that relates this view's top, leading, bottom and trailing to its superview, given an optional set of insets for each side.

     Default parameter values relate this view's top, leading, bottom and trailing to its superview with no insets.

     @note The constraints are also added to this view's superview for you

     :param: edges An amount insets to apply to the top, leading, bottom and trailing constraint. Default value is UIEdgeInsetsZero

     :returns: An array of 4 x NSLayoutConstraint objects (top, leading, bottom, trailing) if the superview exists otherwise an empty array
    */
    @discardableResult
    public func fillSuperView(_ edges: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {

        var constraints: [NSLayoutConstraint] = []

        if let superview = superview {

            let topConstraint = addTopConstraint(toView: superview, constant: edges.top)
            let leadingConstraint = addLeadingConstraint(toView: superview, constant: edges.left)
            let bottomConstraint = addBottomConstraint(toView: superview, constant: -edges.bottom)
            let trailingConstraint = addTrailingConstraint(toView: superview, constant: -edges.right)

            constraints = [topConstraint, leadingConstraint, bottomConstraint, trailingConstraint]
        }

        return constraints
    }


    // MARK: - Leading / Trailing

    /**
     Creates and adds an `NSLayoutConstraint` that relates this view's leading edge to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's leading edge to be equal to the leading edge of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's leading edge to e.g. the other view's trailing edge. Default value is `NSLayoutAttribute.Leading`

     :param: relation  The relation of the constraint. Default value is `NSLayoutRelation.Equal`

     :param: constant  An amount by which to offset this view's left from the other view's specified edge. Default value is 0

     :returns: The created `NSLayoutConstraint` for this leading attribute relation
     */
    @discardableResult
    public func addLeadingConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .leading, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .leading, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }

    /**
     Creates and adds an `NSLayoutConstraint` that relates this view's trailing edge to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's trailing edge to be equal to the trailing edge of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's leading edge to e.g. the other view's trailing edge. Default value is `NSLayoutAttribute.Trailing`

     :param: relation  The relation of the constraint. Default value is `NSLayoutRelation.Equal`

     :param: constant  An amount by which to offset this view's left from the other view's specified edge. Default value is 0

     :returns: The created `NSLayoutConstraint` for this trailing attribute relation
     */
    @discardableResult
    public func addTrailingConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .trailing, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .trailing, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Left

    /**
     Creates and adds an NSLayoutConstraint that relates this view's left to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's left to be equal to the left of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's left side to e.g. the other view's right. Default value is NSLayoutAttribute.Left

     :param: relation  The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant  An amount by which to offset this view's left from the other view's specified edge. Default value is 0

     :returns: The created NSLayoutConstraint for this left attribute relation
    */
    @discardableResult
    public func addLeftConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .left, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .left, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Right

    /**
     Creates and adds an NSLayoutConstraint that relates this view's right to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's right to be equal to the right of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's right to e.g. the other view's left. Default value is NSLayoutAttribute.Right

     :param: relation  The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant  An amount by which to offset this view's right from the other view's specified edge. Default value is 0.0

     :returns: The created NSLayoutConstraint for this right attribute relation
    */
    @discardableResult
    public func addRightConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .right, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .right, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Top

    /**
     Creates and adds an NSLayoutConstraint that relates this view's top to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's right to be equal to the right of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's top to e.g. the other view's bottom. Default value is NSLayoutAttribute.Bottom

     :param: relation  The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant  An amount by which to offset this view's top from the other view's specified edge. Default value is 0.0

     :returns: The created NSLayoutConstraint for this top edge layout relation
    */
    @discardableResult
    public func addTopConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .top, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .top, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Bottom

    /**
     Creates and adds an NSLayoutConstraint that relates this view's bottom to some specified edge of another view, given a relation and offset.
     Default parameter values relate this view's right to be equal to the right of the other view.

     @note The new constraint is added to this view's superview for you

     :param: view      The other view to relate this view's layout to

     :param: attribute The other view's layout attribute to relate this view's bottom to e.g. the other view's top. Default value is NSLayoutAttribute.Botom

     :param: relation  The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant  An amount by which to offset this view's bottom from the other view's specified edge. Default value is 0.0

     :returns: The created NSLayoutConstraint for this bottom edge layout relation
    */
    @discardableResult
    public func addBottomConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .bottom, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .bottom, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Center X

    /**
     Creates and adds an NSLayoutConstraint that relates this view's center X attribute to the center X attribute of another view, given a relation and offset.
     Default parameter values relate this view's center X to be equal to the center X of the other view.

     :param: view     The other view to relate this view's layout to

     :param: relation The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant An amount by which to offset this view's center X attribute from the other view's center X attribute. Default value is 0.0

     :returns: The created NSLayoutConstraint for this center X layout relation
    */
   @discardableResult
    public func addCenterXConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .centerX, toView: view, attribute: .centerX, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Center Y

    /**
     Creates and adds an NSLayoutConstraint that relates this view's center Y attribute to the center Y attribute of another view, given a relation and offset.
     Default parameter values relate this view's center Y to be equal to the center Y of the other view.

     :param: view     The other view to relate this view's layout to

     :param: relation The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant An amount by which to offset this view's center Y attribute from the other view's center Y attribute. Default value is 0.0

     :returns: The created NSLayoutConstraint for this center Y layout relation
    */
    @discardableResult
    public func addCenterYConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .centerY, toView: view, attribute: .centerY, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Width

    /**
     Creates and adds an NSLayoutConstraint that relates this view's width to the width of another view, given a relation and offset.
     Default parameter values relate this view's width to be equal to the width of the other view.

     :param: view     The other view to relate this view's layout to

     :param: relation The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant An amount by which to offset this view's width from the other view's width amount. Default value is 0.0

     :returns: The created NSLayoutConstraint for this width layout relation
    */
    @discardableResult
    public func addWidthConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .width, toView: view, attribute: .width, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Height

    /**
     Creates and adds an NSLayoutConstraint that relates this view's height to the height of another view, given a relation and offset.
     Default parameter values relate this view's height to be equal to the height of the other view.

     :param: view     The other view to relate this view's layout to

     :param: relation The relation of the constraint. Default value is NSLayoutRelation.Equal

     :param: constant An amount by which to offset this view's height from the other view's height amount. Default value is 0.0

     :returns: The created NSLayoutConstraint for this height layout relation
    */
    @discardableResult
    public func addHeightConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .height, toView: view, attribute: .height, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Private

    /// Adds an NSLayoutConstraint to the superview
    fileprivate func addConstraintToSuperview(_ constraint: NSLayoutConstraint) {

        translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(constraint)
    }

    /// Creates an NSLayoutConstraint using its factory method given both views, attributes a relation and offset
    fileprivate func createConstraint(attribute attr1: NSLayoutConstraint.Attribute, toView: UIView?, attribute attr2: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) -> NSLayoutConstraint {

        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attr1,
            relatedBy: relation,
            toItem: toView,
            attribute: attr2,
            multiplier: 1.0,
            constant: constant)

        return constraint
    }
}
