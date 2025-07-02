//
//  UIColor+.swift
//  PicMate
//
//  Created by 최안용 on 6/26/25.
//

import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        while true {
            let color = UIColor(
                red: CGFloat.random(in: 0...1),
                green: CGFloat.random(in: 0...1),
                blue: CGFloat.random(in: 0...1),
                alpha: 1.0
            )
            
            if color.contrastRatio(with: .background) > 1.5,
               color.contrastRatio(with: .black) > 4.5 {
                return color
            }
        }
    }
    
    func contrastRatio(with other: UIColor) -> CGFloat {
        let l1 = self.relativeLuminance()
        let l2 = other.relativeLuminance()
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }
    
    func relativeLuminance() -> CGFloat {
        guard let components = cgColor.components else { return 0 }
        func adjust(_ c: CGFloat) -> CGFloat {
            return (c <= 0.03928) ? c / 12.92 : pow((c + 0.055)/1.055, 2.4)
        }
        
        let r = adjust(components[0])
        let g = adjust(components.count >= 3 ? components[1] : components[0])
        let b = adjust(components.count >= 3 ? components[2] : components[0])
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}
