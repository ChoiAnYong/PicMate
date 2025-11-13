//
//  CleanUpView.swift
//  PicMate
//
//  Created by 최안용 on 6/26/25.
//

import UIKit

final class CleanUpView: UIView, BaseViewProtocol {
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CompositionalLayout.createCleanUpMonthListLayout()
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        self.do {
            $0.backgroundColor = .white
        }
        
        collectionView.do {
            $0.backgroundColor = .white
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    func setUI() {
        addSubview(collectionView)
    }
    
    func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
