//
//  UINavigationController+.swift
//  PicMate
//
//  Created by 최안용 on 6/26/25.
//

import UIKit

extension UINavigationController {
    func setupBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        appearance.titleTextAttributes = [.font: UIFont.font(.pretendardSemiBold, ofSize: 16.0),
                                          .foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.font: UIFont.font(.pretendardSemiBold, ofSize: 35.0),
                                               .foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.prefersLargeTitles = false        
    }
}
