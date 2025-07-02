//
//  MonthSectionHeaderView.swift
//  PicMate
//
//  Created by 최안용 on 6/27/25.
//

import UIKit

import SnapKit
import Then

final class MonthSectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MonthSectionHeaderView {
    func setStyle() {
        titleLabel.do {
            $0.text = "월별사진"
            $0.font = .font(.pretendardSemiBold, ofSize: 18)
            $0.textColor = .black
        }
    }
    
    func setUI() {
        addSubview(titleLabel)
    }
    
    func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
