//
//  FullPhotoViewController.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import Photos
import PhotosUI
import UIKit

import RxSwift
import RxCocoa

final class FullPhotoViewController: UIViewController {
    private let rootview = FullPhotoView()
//    private var currentColumnCount: CGFloat = 5.0
//    private var possibleColumnCounts: [CGFloat] = [1.0, 3.0, 5.0, 7.0, 9.0, 11.0, 13.0, 15.0]
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        self.view = rootview
    }
    
    override func viewDidLoad() {        
        navigationItem.title = "전체 사진"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.font(.pretendardSemiBold, ofSize: 22),
            .foregroundColor: UIColor.black
        ]
//        rootview.setCollectionViewDelegate(viewController: self)
        loadPhotoAssets()
        
        rootview.selectedSegmentIndex
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                switch index {
                case 0:
                    self.fetchAssets()
                case 1:
                    self.fetchAssets(true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

//extension FullPhotoViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//        let width = collectionView.frame.inset(by: collectionView.contentInset).width / currentColumnCount
//        let height = width
//        return CGSize(width: width, height: height)
//    }
//}

private extension FullPhotoViewController {
    func loadPhotoAssets() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                print("사진 라이브러리 접근 허용됨")
                self.fetchAssets()
            case .denied, .restricted:
                print("사진 라이브러리 접근 거부 또는 제한됨")
            case .notDetermined:
                print("사용자가 아직 선택하지 않음")
            @unknown default:
                fatalError("알 수 없는 권한 상태")
            }
        }
    }

    private func fetchAssets(_ isFavorite: Bool = false) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        if isFavorite {
            fetchOptions.predicate = NSPredicate(format: "isFavorite == YES")
        }
        
        let allAssets = PHAsset.fetchAssets(with: fetchOptions)
        
        print("총 \(allAssets.count)장의 사진이 있습니다.")
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoItem>()
        snapshot.appendSections([.main])
        
        var photoItems: [PhotoItem] = []

        allAssets.enumerateObjects { asset, _, _ in
            if let date = asset.creationDate {
                let item = PhotoItem(
                    createDate: date,
                    identifier: asset.localIdentifier,
                    mediaType: asset.mediaType.rawValue
                )
                photoItems.append(item)
            }
        }
        
        snapshot.appendItems(photoItems)
        rootview.loadPhotoAssets(snapshot)
    }
}
