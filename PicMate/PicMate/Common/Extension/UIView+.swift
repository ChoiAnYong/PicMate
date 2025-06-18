//
//  UIView+.swift
//  PicMate
//
//  Created by 최안용 on 6/15/25.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}
