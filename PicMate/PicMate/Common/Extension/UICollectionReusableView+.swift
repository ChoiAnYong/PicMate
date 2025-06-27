//
//  UICollectionReusableView+.swift
//  PicMate
//
//  Created by 최안용 on 6/27/25.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
