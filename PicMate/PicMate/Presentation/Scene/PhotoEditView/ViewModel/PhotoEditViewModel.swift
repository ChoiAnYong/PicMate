//
//  PhotoEditViewModel.swift
//  PicMate
//
//  Created by 최안용 on 6/30/25.
//

import Photos
import UIKit

import RxSwift
import RxRelay
import RxCocoa

final class PhotoEditViewModel: ViewModelType {
    var photoItemListRelay: BehaviorRelay<[PhotoItem]>
    
    private let currentIndexRelay = BehaviorRelay<Int>(value: 0)
    private let favoriteRelay = PublishRelay<Bool>()
    private let deleteResultRelay = PublishRelay<Void>()
    private let userAlbumsRelay = BehaviorRelay<[PHAssetCollection]>(value: [])
    
    init(photoGroup: [PhotoItem]) {
        self.photoItemListRelay = BehaviorRelay(value: photoGroup)
    }
    
    struct Input {
        let loadTrigger: Observable<Void>
        let toggleFavoriteTrigger: Observable<Void>
        let deleteTrigger: Observable<Void>
        let currentIndex: Observable<Int>
        let addToAlbumTrigger: Observable<PHAssetCollection>
    }
    
    struct Output {
        let isFavorite: Driver<Bool>
        let deleteResult: Driver<Void>
        let currentPositionText: Driver<String>
        let dateLabelText: Driver<String>
        let userAlbums: Driver<[PHAssetCollection]>
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        input.currentIndex
            .bind(to: currentIndexRelay)
            .disposed(by: disposeBag)
        
        input.loadTrigger
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.updateFavorite()
                self.fetchUserAlbums()
            })
            .disposed(by: disposeBag)
        
        input.currentIndex
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                self.updateFavorite()
            })
            .disposed(by: disposeBag)
        
        input.toggleFavoriteTrigger
            .subscribe(onNext: { [weak self] in
                self?.toggleFavorite()
            })
            .disposed(by: disposeBag)
        
        input.deleteTrigger
            .subscribe(onNext: { [weak self] in
                self?.deleteCurrentPhoto()
            })
            .disposed(by: disposeBag)
        
        input.addToAlbumTrigger
            .subscribe(onNext: { [weak self] collection in
                self?.addCurrentPhotoToAlbum(collection)
            })
            .disposed(by: disposeBag)
        
        let isFavorite = favoriteRelay
            .asDriver(onErrorJustReturn: false)
        
        let currentPositionText = currentIndexRelay
            .map { [weak self] index in
                guard let self = self else { return "0 / 0" }
                return "\(index + 1) / \(self.photoItemListRelay.value.count)"
            }
            .asDriver(onErrorJustReturn: "0 / 0")
        
        let dateLabelText = currentIndexRelay
            .map { [weak self] index in
                guard let self = self else { return "2000.01.01 00:00" }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd HH:mm"
                let dateString = formatter.string(from: self.photoItemListRelay.value[index].createDate)
                return dateString
            }
            .asDriver(onErrorJustReturn: "2000.01.01 00:00")
        
        let userAlbums = userAlbumsRelay
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            isFavorite: isFavorite,
            deleteResult: deleteResultRelay.asDriver(onErrorJustReturn: ()),
            currentPositionText: currentPositionText,
            dateLabelText: dateLabelText,
            userAlbums: userAlbums
        )
    }
}

private extension PhotoEditViewModel {
    func updateFavorite() {
        let index = currentIndexRelay.value
        guard photoItemListRelay.value.indices.contains(index) else {
            favoriteRelay.accept(false)
            return
        }
        
        let item = photoItemListRelay.value[index]
        favoriteRelay.accept(item.isFavorite)
    }
    
    func toggleFavorite() {
        let index = currentIndexRelay.value
        guard photoItemListRelay.value.indices.contains(index) else { return }
        
        let item = photoItemListRelay.value[index]
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [item.identifier], options: nil).firstObject else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest(for: asset).isFavorite = !asset.isFavorite
        }, completionHandler: { [weak self] success, _ in
            guard success else { return }
            DispatchQueue.main.async {
                self?.photoItemListRelay.value[index].isFavorite.toggle()
                self?.favoriteRelay.accept(self?.photoItemListRelay.value[index].isFavorite ?? false)
            }
        })
    }
    
    func deleteCurrentPhoto() {
        let index = currentIndexRelay.value
        guard photoItemListRelay.value.indices.contains(index) else { return }
        
        let item = photoItemListRelay.value[index]
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [item.identifier], options: nil).firstObject else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }, completionHandler: { [weak self] success, _ in
            guard success else { return }
            DispatchQueue.main.async {
                var updated = self?.photoItemListRelay.value ?? []
                updated.remove(at: index)
                self?.photoItemListRelay.accept(updated)
                self?.deleteResultRelay.accept(())
                
                if let newCount = self?.photoItemListRelay.value.count, newCount > 0 {
                    let newIndex = min(index, newCount - 1)
                    self?.currentIndexRelay.accept(newIndex)
                    self?.updateFavorite()
                }
            }
        })
    }
    
    func fetchUserAlbums() {
        let albums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        
        var collections: [PHAssetCollection] = []
        
        albums.enumerateObjects { collection, _, _ in
            collections.append(collection)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.userAlbumsRelay.accept(collections)
        }
    }
    
    func addCurrentPhotoToAlbum(_ collection: PHAssetCollection) {
        let index = currentIndexRelay.value
        guard photoItemListRelay.value.indices.contains(index) else { return }
        let item = photoItemListRelay.value[index]
        
        let assets = PHAsset.fetchAssets(
            withLocalIdentifiers: [item.identifier],
            options: nil
        )
        
        guard let asset = assets.firstObject else { return }
        
        PHPhotoLibrary.shared().performChanges ({
            if let request = PHAssetCollectionChangeRequest(for: collection) {
                request.addAssets([asset] as NSArray)
            }
        }, completionHandler: { [weak self] success, error in
            guard success, error == nil else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // 현재 리스트에서 제거
                var updatedList = self.photoItemListRelay.value
                updatedList.remove(at: index)
                self.photoItemListRelay.accept(updatedList)
                
                // 인덱스 갱신 및 즐겨찾기 상태 업데이트
                if !updatedList.isEmpty {
                    let newIndex = min(index, updatedList.count - 1)
                    self.currentIndexRelay.accept(newIndex)
                    self.updateFavorite()
                }
            }
        })
    }
    

}

extension PhotoEditViewModel {
    func createAlbum(named name: String) {
        var placeholder: PHObjectPlaceholder?

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = request.placeholderForCreatedAssetCollection
        }) { [weak self] success, error in
            guard success else { return }
            
            DispatchQueue.main.async {
                self?.fetchUserAlbums()
            }
        }
    }
}
