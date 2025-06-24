//
//  PhotoPageViewModel.swift
//  PicMate
//
//  Created by 최안용 on 6/22/25.
//

import UIKit
import Photos

import RxSwift
import RxRelay

final class PhotoPageViewModel {
    private let isFavorite: Bool
    
    let reloadTrigger = PublishRelay<Void>()
    
    let snapshot = BehaviorRelay<NSDiffableDataSourceSnapshot<Section, PhotoItem>>(value: .init())
    
    private let disposeBag = DisposeBag()
    
    init(isFavorite: Bool) {
        self.isFavorite = isFavorite
        bind()
    }
    
    private func bind() {
        reloadTrigger
            .subscribe(onNext: { [weak self] in
                self?.fetchPhotoItem()
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchPhotoItem() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        if isFavorite {
            fetchOptions.predicate = NSPredicate(format: "isFavorite == YES")
        }
        
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var items: [PhotoItem] = []
        
        assets.enumerateObjects { asset, _, _ in
            if let date = asset.creationDate {
                let item = PhotoItem(
                    createDate: date,
                    identifier: asset.localIdentifier,
                    mediaType: Int16(asset.mediaType.rawValue)
                )
                items.append(item)
            }
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        self.snapshot.accept(snapshot)
    }
}
