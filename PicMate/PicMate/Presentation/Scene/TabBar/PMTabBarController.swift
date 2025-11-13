//
//  PMTabBarController.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import UIKit

final class PMTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        addTabBarController()
        self.selectedIndex = PMTabBarItem.allCases.firstIndex(of: .cleanUp) ?? 0
    }
}

private extension PMTabBarController {
    func setStyle() {
        view.backgroundColor = .white
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.font(.pretendardMedium, ofSize: 11),
            .foregroundColor: UIColor.tabTitle
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.font(.pretendardMedium, ofSize: 11),
            .foregroundColor: UIColor.selectedTabTitle
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    func addTabBarController() {
        let viewControllers = PMTabBarItem.allCases.map {
            let viewController = createViewController(
                title: $0.title,
                image: $0.unSelectedImage,
                selectedImage: $0.selectedImage,
                viewController: $0.viewController
            )
            
            return viewController
        }
        
        setViewControllers(viewControllers, animated: true)
    }
    
    func createViewController(
        title: String,
        image: UIImage,
        selectedImage: UIImage,
        viewController: UIViewController
    ) -> UIViewController {
        let viewController = viewController
        
        let tabBarItem = UITabBarItem(
            title: title,
            image: image.withRenderingMode(.alwaysOriginal),
            selectedImage: selectedImage.withRenderingMode(.alwaysOriginal)
        )
        
        viewController.tabBarItem = tabBarItem
        
        return viewController
    }
}
