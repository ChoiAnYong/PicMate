//
//  FullPhotoView.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class FullPhotoView: UIView, BaseViewProtocol {
    private let segmentedControl = PMSegmentedControl(items: ["전체사진", "즐겨찾기"])
    private let photoCollectionView = PhotoCollectionView()
    private let disposeBag = DisposeBag()
    
    var selectedSegmentIndex: Observable<Int> {
        segmentedControl.rx.selectedSegmentIndex.asObservable()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        self.do {
            $0.backgroundColor = .white
        }
        
        segmentedControl.do {
            $0.selectedSegmentIndex = 0
        }
    }
    
    func setUI() {
        addSubViews(segmentedControl, photoCollectionView)
    }
    
    func setLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func setCollectionViewDelegate(viewController: UICollectionViewDelegateFlowLayout) {
        photoCollectionView.setDelegate(viewController: viewController)
    }
    
    func loadPhotoAssets(_ snapshot: NSDiffableDataSourceSnapshot<Section, PhotoItem>) {
        photoCollectionView.loadPhotoAssets(snapshot)
    }
    
    func setSegmentView() {
        
    }
}
