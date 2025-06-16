//
//  UIFont+.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//


import UIKit

extension UIFont {
    static func font(_ style: FontName, ofSize size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            print("🚨\(style.rawValue) font가 등록되지 않았습니다.🚨")
            return UIFont.systemFont(ofSize: size)
        }
        
        return customFont
    }
}

enum FontName: String {
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardLight = "Pretendard-Light"
}
