//
//  UIStackView+.swift
//  PicMate
//
//  Created by 최안용 on 6/15/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubViews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
