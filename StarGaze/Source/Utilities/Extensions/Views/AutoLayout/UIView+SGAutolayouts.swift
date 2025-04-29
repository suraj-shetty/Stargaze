//
//  UIView+SGAutolayouts.swift
//  StarGaze
//
//  Created by Suraj Shetty on 17/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func pin(to parent:UIView, edges:UIRectEdge = .all, relation:NSLayoutConstraint.Relation = .equal, inset:UIEdgeInsets = .zero) {
        if self.superview != parent {
            parent.addSubview(self)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if edges == .all || edges.contains(.all) {
            NSLayoutConstraint.activate([
                .init(item: self, attribute: .leading, relatedBy: .equal, toItem: parent, attribute: .leading, multiplier: 1, constant: inset.left),
                .init(item: self, attribute: .top, relatedBy: .equal, toItem: parent, attribute: .top, multiplier: 1, constant: inset.top),
                
                .init(item: parent, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: inset.right),
                .init(item: parent, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: inset.bottom)
            ])
        }
        else {
            var constraints = [NSLayoutConstraint]()
            switch edges {
            case .left : constraints.append(.init(item: self, attribute: .leading, relatedBy: .equal,
                                                  toItem: parent, attribute: .leading, multiplier: 1, constant: inset.left))
                
            case .right: constraints.append(.init(item: parent, attribute: .trailing, relatedBy: .equal,
                                                  toItem: self, attribute: .trailing, multiplier: 1, constant: inset.right))

            case .top: constraints.append(.init(item: self, attribute: .top, relatedBy: .equal,
                                                toItem: parent, attribute: .top, multiplier: 1, constant: inset.top))
                
            case .bottom: constraints.append(.init(item: parent, attribute: .bottom, relatedBy: .equal,
                                                   toItem: self, attribute: .bottom, multiplier: 1, constant: inset.bottom))
            default: break
            }
            
            NSLayoutConstraint.activate(constraints)
        }
        self.layoutIfNeeded()
    }
    
    
    func setWidth(width:CGFloat, relation: NSLayoutConstraint.Relation = .equal) {
        set(attribute: .width, with: width, relation: relation)
    }
    
    func setHeight(height:CGFloat, relation: NSLayoutConstraint.Relation = .equal) {
        set(attribute: .height, with: height, relation: relation)
    }
    
    func centerAlign(to parent: UIView) {
        if self.superview != parent {
            parent.addSubview(self)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
        ])
    }
    
    private func set(attribute:NSLayoutConstraint.Attribute,
                     with value:CGFloat,
                     relation:NSLayoutConstraint.Relation) {
        
        if let constraint = self.constraints.first(where: {
            $0.firstAttribute == attribute && $0.relation == relation
        }) {
            constraint.constant = value
        }
        else {
            let constraint = NSLayoutConstraint(item: self,
                                                attribute: attribute,
                                                relatedBy: relation,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: value)
            self.addConstraint(constraint)
        }
        self.layoutIfNeeded()
    }
    
    
}
