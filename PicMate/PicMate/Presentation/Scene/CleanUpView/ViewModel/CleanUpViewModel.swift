//
//  CleanUpViewModel.swift
//  PicMate
//
//  Created by 최안용 on 6/27/25.
//

import Photos
import UIKit

import RxSwift
import RxRelay
import RxCocoa

final class CleanUpViewModel: ViewModelType {
    private let monthPhotoGroupRelay = BehaviorRelay<[String: [PhotoItem]]>(value: [:])
    
    init() { }
    
    struct Input {
        let loadTrigger: Observable<Void>
    }
    
    struct Output {
        let monthPhotoGroup: Driver<[String: [PhotoItem]]>
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        
        input.loadTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.fetchPhotosGroupedByMonth()
            })
            .disposed(by: disposeBag)
        
        return Output(
            monthPhotoGroup: monthPhotoGroupRelay
                .asDriver(onErrorJustReturn: [:])
        )
    }
}

private extension CleanUpViewModel {
    func fetchPhotosGroupedByMonth() {
        let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let allAssets = PHAsset.fetchAssets(with: fetchOptions)
            var allAssetSet = Set<String>()
            allAssets.enumerateObjects { asset, _, _ in
                allAssetSet.insert(asset.localIdentifier)
            }

            var includedAssetSet = Set<String>()
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            userAlbums.enumerateObjects { collection, _, _ in
                let assets = PHAsset.fetchAssets(in: collection, options: nil)
                assets.enumerateObjects { asset, _, _ in
                    includedAssetSet.insert(asset.localIdentifier)
                }
            }

            let uncategorizedAssetIDs = allAssetSet.subtracting(includedAssetSet)

            var grouped: [String: [PhotoItem]] = [:]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월"

            allAssets.enumerateObjects { asset, _, _ in
                guard uncategorizedAssetIDs.contains(asset.localIdentifier),
                      let date = asset.creationDate else { return }

                let key = formatter.string(from: date)
                grouped[key, default: []].append(
                    PhotoItem(
                        createDate: date,
                        identifier: asset.localIdentifier,
                        mediaType: Int16(asset.mediaType.rawValue),
                        isFavorite: asset.isFavorite
                    )
                )
            }

            monthPhotoGroupRelay.accept(grouped)
    }
}
