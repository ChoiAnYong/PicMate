//
//  PhotoPageViewController.swift
//  PicMate
//
//  Created by 최안용 on 6/22/25.
//

import UIKit

import RxSwift

final class PhotoPageViewController: UIViewController {
    private let viewModel: PhotoPageViewModel
    private let photoCollectionView = PhotoCollectionView()
    private let disposeBag = DisposeBag()
    
    init(viewModel: PhotoPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(photoCollectionView)
        photoCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        bind()
    }
    
    private func bind() {
        viewModel.snapshot
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] snapshot in
                self?.photoCollectionView.loadPhotoAssets(snapshot)
            })
            .disposed(by: disposeBag)
    }
    
    func setPhotoCollectionViewDelegate(_ delegate: PhotoCollctionViewDelegate) {
        photoCollectionView.delegate = delegate
    }
}
