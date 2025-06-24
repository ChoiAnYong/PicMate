//
//  PhotoDetailViewModel.swift
//  PicMate
//
//  Created by 최안용 on 6/24/25.
//

import Photos
import UIKit

import RxSwift
import RxRelay
import Photos

final class PhotoDetailViewModel {
    let loadTrigger = PublishRelay<Void>()
    
    let fullSizeImage = BehaviorRelay<UIImage?>(value: nil)
    let createImageDate = BehaviorRelay<String?>(value: nil)
    
    let photoItem: PhotoItem
    private let imageManager = PHImageManager.default()
    private let disposeBag = DisposeBag()
    
    init(photoItem: PhotoItem) {
        self.photoItem = photoItem
        bind()
    }
    
    private func bind() {
        loadTrigger
            .subscribe(onNext: { [weak self] in
                self?.loadFullSizeImage()
                self?.createImageDate.accept(self?.photoItem.createDate.description)
            })
            .disposed(by: disposeBag)
    }
    
    private func loadFullSizeImage() {
        let asset = PHAsset.fetchAssets(
            withLocalIdentifiers: [photoItem.identifier],
            options: nil
        ).firstObject
        
        if let asset = asset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        self?.fullSizeImage.accept(image)
                    }
                }
        }
    }
}
