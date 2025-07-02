//
//  PMSegmentedControl.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import UIKit

import Then

final class PMSegmentedControl: UISegmentedControl {
    private lazy var underLineView: UIView = {
        let width = self.bounds.width / CGFloat(self.numberOfSegments)
        let height = 3.0
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.bounds.size.height - 3.0
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = .black
        self.addSubview(view)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        removeBackgroundAndDivider()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        removeBackgroundAndDivider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 0
        let underLineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        UIView.animate(withDuration: 0.2) {
            self.underLineView.frame.origin.x = underLineFinalXPosition
        }
    }
}

private extension PMSegmentedControl {
    func removeBackgroundAndDivider() {
        self.do {
            let image = UIImage()
            
            $0.setBackgroundImage(image, for: .normal, barMetrics: .default)
            $0.setBackgroundImage(image, for: .selected, barMetrics: .default)
            $0.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
            
            $0.setDividerImage(
                image,
                forLeftSegmentState: .selected,
                rightSegmentState: .normal,
                barMetrics: .default
            )
            $0.setTitleTextAttributes(
                [
                    .foregroundColor: UIColor.tabTitle,
                    .font: UIFont.font(.pretendardSemiBold, ofSize: 16)
                ],
                for: .normal
            )
            $0.setTitleTextAttributes(
                [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.font(.pretendardSemiBold, ofSize: 16)
                ],
                for: .selected
            )
            $0.backgroundColor = .white
        }
    }
}
