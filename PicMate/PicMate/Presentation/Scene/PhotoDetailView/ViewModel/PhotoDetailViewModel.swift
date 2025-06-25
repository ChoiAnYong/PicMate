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
import RxCocoa

final class PhotoDetailViewModel: ViewModelType {
    private let photoItem: PhotoItem
    private let imageManager = PHImageManager.default()
    
    private let fullSizeImageRelay = PublishRelay<UIImage>()
    private let createImageDateRelay = PublishRelay<String>()
    private let isFavoriteRelay = PublishRelay<Bool>()
    private let deleteResultRelay = PublishRelay<Void>()
    
    init(photoItem: PhotoItem) {
        self.photoItem = photoItem
    }
    
    struct Input {
        let loadTrigger: Observable<Void>
        let toggleFavoriteTrigger: Observable<Void>
        let deleteTrigger: Observable<Void>
    }
    
    struct Output {
        let fullSizeImage: Driver<UIImage>
        let createImageDate: Driver<String>
        let isFavorite: Driver<Bool>
        let deleteResult: Driver<Void>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let errorTracker = PublishSubject<String>()
        
        input.loadTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.loadFullSizeImage()
                self.loadCreateDate()
                self.isFavoriteRelay.accept(self.photoItem.isFavorite)
            })
            .disposed(by: disposeBag)
        
        input.toggleFavoriteTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.toggleFavoriteStatus()
            })
            .disposed(by: disposeBag)
        
        input.deleteTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.deletePhoto()
            })
            .disposed(by: disposeBag)
        
        let fullSizeImage = fullSizeImageRelay
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: UIImage())
        
        let createImageDate = createImageDateRelay
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: "-")
        
        let isFavorite = isFavoriteRelay
            .asDriver(onErrorJustReturn: false)
        
        let errorMessage = errorTracker
            .asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        
        let deleteResult = deleteResultRelay
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            fullSizeImage: fullSizeImage,
            createImageDate: createImageDate,
            isFavorite: isFavorite,
            deleteResult: deleteResult,
            errorMessage: errorMessage
        )
    }
}

private extension PhotoDetailViewModel {
    func loadFullSizeImage() {
        let asset = PHAsset.fetchAssets(
            withLocalIdentifiers: [photoItem.identifier],
            options: nil
        ).firstObject
        
        guard let asset = asset else { return }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.fullSizeImageRelay.accept(image ?? UIImage())
            }
        }
    }
    
    func loadCreateDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString = formatter.string(from: photoItem.createDate)
        createImageDateRelay.accept(dateString)
    }
    
    func toggleFavoriteStatus() {
        guard let asset = PHAsset.fetchAssets(
            withLocalIdentifiers: [photoItem.identifier],
            options: nil
        ).firstObject else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !asset.isFavorite
        }, completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isFavoriteRelay.accept(!asset.isFavorite)
                } else {
                    print("즐겨찾기 변경 실패: \(String(describing: error))")
                }
            }
        })
    }
    
    func deletePhoto() {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [photoItem.identifier], options: nil)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.deleteResultRelay.accept(())
                } else {
                    print("삭제 실패: \(String(describing: error))")
                }
            }
        })
    }
}
