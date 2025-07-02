//
//  PhotoEditView.swift
//  PicMate
//
//  Created by 최안용 on 6/27/25.
//

import UIKit

import SnapKit
import Then
import Photos

final class PhotoEditView: UIView, BaseViewProtocol {
    private let titleLabel = UILabel()
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )
    let favoriteButton = UIButton()
    let closeButton = UIButton(type: .system)
    let deleteButton = UIButton()
    let dateLabel = UILabel()
    let countLabel = UILabel()
    let dateButton = UIButton()
    let headerView = UIView()
    let infoStackView = UIStackView()
    let bottomView = UIView()
    let albumScrollView = UIScrollView()
    let albumStackView = UIStackView()
    let addAlbumButton = AlbumButton(title: "앨범 추가", isAddButton: true)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        self.do {
            $0.backgroundColor = .black
        }
        
        collectionView.do {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            $0.setCollectionViewLayout(layout, animated: true)
            $0.backgroundColor = .black
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
        }
        
        favoriteButton.do {
            $0.setImage(.init(systemName: "star"), for: .normal)
            $0.setImage(.init(systemName: "star.fill"), for: .selected)
            $0.tintColor = .yellow
        }
        
        closeButton.do {
            $0.setImage(.init(systemName: "xmark"), for: .normal)
            $0.tintColor = .white
        }
        
        deleteButton.do {
            $0.setImage(.init(systemName: "trash"), for: .normal)
            $0.tintColor = .white
        }
        
        dateLabel.do {
            $0.font = .font(.pretendardMedium, ofSize: 12)
            $0.textColor = .tabTitle
        }
        
        countLabel.do {
            $0.font = .font(.pretendardMedium, ofSize: 12)
            $0.textColor = .tabTitle
        }
        
        dateButton.do {
            $0.titleLabel?.font = .font(.pretendardSemiBold, ofSize: 14)
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
            $0.backgroundColor = .selectedTabTitle
            $0.setTitle("2022년 6월", for: .normal)
        }
        
        infoStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
        
        bottomView.do {
            $0.backgroundColor = .bottomSheet
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.sheetLayer.cgColor
        }
        
        titleLabel.do {
            $0.text = "앨범 정리"
            $0.font = .font(.pretendardSemiBold, ofSize: 14)
            $0.textColor = .tabTitle
        }
        
        albumScrollView.do {
            $0.backgroundColor = .sheetLayer
            $0.showsHorizontalScrollIndicator = false
            $0.alwaysBounceHorizontal = true
        }
        
        albumStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
    }
    
    func setUI() {
        addSubViews(collectionView, headerView, bottomView)
        headerView.addSubViews(
            closeButton,
            dateButton,
            deleteButton,
            infoStackView
        )
        infoStackView.addArrangedSubViews(favoriteButton, countLabel, dateLabel)
        bottomView.addSubViews(titleLabel, albumScrollView)
        albumScrollView.addSubViews(albumStackView, addAlbumButton)
    }
    
    func setLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(130)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalTo(headerView.snp.leading).inset(15)
            $0.top.equalTo(headerView.snp.top).inset(70)
            $0.size.equalTo(20)
        }
        
        dateButton.snp.makeConstraints {
            $0.centerX.equalTo(headerView.snp.centerX)
            $0.top.equalTo(headerView.snp.top).inset(70)
            $0.width.greaterThanOrEqualTo(100)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalTo(headerView.snp.trailing).inset(15)
            $0.top.equalTo(headerView.snp.top).inset(70)
            $0.size.equalTo(20)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.size.equalTo(12)
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(10)
            $0.centerX.equalTo(dateButton.snp.centerX)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top).offset(-10)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(180)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bottomView.snp.top).inset(10)
            $0.centerX.equalTo(bottomView.snp.centerX)
        }
        
        albumScrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        albumStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        addAlbumButton.snp.makeConstraints {
            $0.leading.equalTo(albumStackView.snp.trailing).offset(30)
            $0.directionalVerticalEdges.equalToSuperview().inset(12)
            $0.width.equalTo(82)
        }
    }
}
