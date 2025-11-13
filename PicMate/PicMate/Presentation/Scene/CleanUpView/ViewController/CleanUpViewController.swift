//
//  CleanUpViewController.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import Photos
import UIKit

import RxSwift
import RxRelay

enum CleanUpSection: Int, CaseIterable {
    case month
}

final class CleanUpViewController: UIViewController {
    private var photoData: [(String, [PhotoItem])] = []
    private let rootView = CleanUpView()
    private let viewModel = CleanUpViewModel()
    private let disposeBag = DisposeBag()
    private let loadTrigger = PublishRelay<Void>()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        setDelegate()
        setRegister()
        setNavigationTitle()
        bindViewModel()
        checkPermission()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setDelegate() {
        rootView.collectionView.delegate = self
        rootView.collectionView.dataSource = self
    }
    
    private func setRegister() {
        rootView.collectionView.register(
            MonthCell.self,
            forCellWithReuseIdentifier: MonthCell.cellIdentifier
        )
        
        rootView.collectionView.register(
            MonthSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MonthSectionHeaderView.reuseIdentifier
        )
    }
    
    private func setNavigationTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "정리하기"
        titleLabel.font = .font(.pretendardSemiBold, ofSize: 25)
        titleLabel.textColor = .black
        titleLabel.sizeToFit()
        
        let leftItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func bindViewModel() {
        let input = CleanUpViewModel.Input(
            loadTrigger: loadTrigger.asObservable()
        )
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.monthPhotoGroup
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.photoData = data.sorted { $0.key > $1.key }
                self.rootView.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        loadTrigger.accept(())
    }
}

extension CleanUpViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = photoData[indexPath.item].0
        let group = photoData[indexPath.item].1
        let destination = PhotoEditViewController(date: date, photoGroup: group)
        destination.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(destination, animated: true)
        }
    }
}

extension CleanUpViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        CleanUpSection.allCases.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard let section = CleanUpSection(rawValue: section) else  { return 0 }
        
        switch section {
        case .month:
            return photoData.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = CleanUpSection(rawValue: indexPath.section) else  {
            return UICollectionViewCell()
        }
        
        switch section {
        case .month:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MonthCell.cellIdentifier,
                for: indexPath
            ) as? MonthCell else {
                return UICollectionViewCell()
            }
            
            let (month, assets) = photoData[indexPath.item]
            
            cell.configure(date: month, count: assets.count)
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MonthSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? MonthSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        return header
    }
}

extension CleanUpViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.loadTrigger.accept(())
        }
    }
}

private extension CleanUpViewController {
    func checkPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                print("📸 사진 라이브러리 접근 허용됨")
            default:
                DispatchQueue.main.async { [weak self] in
                    self?.showPhotoPermissionAlert()
                }
            }
        }
    }
    
    func showPhotoPermissionAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let alert = UIAlertController(
            title: "사진 전체 접근 권한 필요",
            message: "앱을 이용하려면 사진 전체 접근 권한이 필요합니다. 설정에서 사진 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        window.rootViewController?.present(alert, animated: true)
    }
}
