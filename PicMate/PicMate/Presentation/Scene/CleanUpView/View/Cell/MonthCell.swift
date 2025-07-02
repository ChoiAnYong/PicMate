//
//  MonthCell.swift
//  PicMate
//
//  Created by 최안용 on 6/26/25.
//

import UIKit

import SnapKit
import Then

final class MonthCell: UICollectionViewCell {
    private let dateLabel = UILabel()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.text = nil
        countLabel.text = nil
    }
    
    func configure(date: String, count: Int) {
        dateLabel.text = date
        countLabel.text = "\(count)"
    }
}

private extension MonthCell {
    func setStyle() {
        self.contentView.do {
            $0.backgroundColor = .randomColor()
            $0.layer.cornerRadius = 10
        }
        
        dateLabel.do {
            $0.textColor = .black
            $0.font = UIFont.font(.pretendardSemiBold, ofSize: 16)
        }
        
        countLabel.do {
            $0.textColor = .black
            $0.font = UIFont.font(.pretendardSemiBold, ofSize: 16)
        }
        
    }
    
    func setUI() {
        contentView.addSubViews(dateLabel, countLabel)
    }
    
    func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }
}
