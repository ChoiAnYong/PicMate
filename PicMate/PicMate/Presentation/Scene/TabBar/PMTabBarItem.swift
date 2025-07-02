//
//  PMTabBarItem.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import UIKit

enum PMTabBarItem: CaseIterable {
    case cleanUp
    case fullPhoto
//    case album    
    
    var title: String {
        switch self {
        case .cleanUp:
            return "정리하기"
        case .fullPhoto:
            return "전체 사진"
//        case .album:
//            return "앨범"
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .cleanUp:
            return UIImage(resource: .icSelectedCleanUp)
        case .fullPhoto:
            return UIImage(resource: .icSelectedFullPhoto)
//        case .album:
//            return UIImage(resource: .icSelectedAlbum)
        }
    }
    
    var unSelectedImage: UIImage {
        switch self {
        case .cleanUp:
            return UIImage(resource: .icCleanUp)
        case .fullPhoto:
            return UIImage(resource: .icFullPhoto)
//        case .album:
//            return UIImage(resource: .icAlbum)
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .cleanUp:
            let vc = UINavigationController(rootViewController: CleanUpViewController())
            vc.setupBarAppearance()
            return vc
            
        case .fullPhoto:
            let vc = UINavigationController(rootViewController: FullPhotoViewController())
            vc.setupBarAppearance()
            return vc
//            
//        case .album:            
//            let vc = UINavigationController(rootViewController: AlbumViewController())
//            vc.setupBarAppearance()
//            return vc
        }
    }
}
