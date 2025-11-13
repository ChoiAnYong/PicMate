//
//  PhotoEditViewController.swift
//  PicMate
//
//  Created by 최안용 on 6/27/25.
//

import Photos
import UIKit

import RxSwift
import RxRelay

final class PhotoEditViewController: UIViewController {
    private let date: String
    private let rootView = PhotoEditView()
    private let viewModel: PhotoEditViewModel
    private let disposeBag = DisposeBag()
    
    private let loadTrigger = PublishRelay<Void>()
    private let currentIndexRelay = BehaviorRelay<Int>(value: 0)
    private let albumButtonTappedRelay = PublishRelay<PHAssetCollection>()
    
    init(date: String, photoGroup: [PhotoItem]) {
        self.viewModel = PhotoEditViewModel(photoGroup: photoGroup)
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.dateButton.setTitle(date, for: .normal)
        setRegister()
        setDelegate()
        setUpAction()
        bindViewModel()
        loadTrigger.accept(())
    }
}

private extension PhotoEditViewController {
    func setRegister() {
        rootView.collectionView.register(
            PhotoCell.self,
            forCellWithReuseIdentifier: PhotoCell.cellIdentifier
        )
    }
    
    func setDelegate() {
        rootView.collectionView.delegate = self
        rootView.collectionView.dataSource = self
    }
    
    func bindViewModel() {
        let input = PhotoEditViewModel.Input(
            loadTrigger: loadTrigger.asObservable(),
            toggleFavoriteTrigger: rootView.favoriteButton.rx.tap.asObservable(),
            deleteTrigger: rootView.deleteButton.rx.tap.asObservable(),
            currentIndex: currentIndexRelay.asObservable(),
            addToAlbumTrigger: albumButtonTappedRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.currentPositionText
            .drive(rootView.countLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.deleteResult
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.rootView.collectionView.reloadData()
                if self.viewModel.photoItemListRelay.value.isEmpty {
                    dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        output.isFavorite
            .drive(rootView.favoriteButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.dateLabelText
            .drive(rootView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.userAlbums
            .drive(onNext: { [weak self] albums in
                guard let self else { return }
                self.setupAlbumButtons(albums: albums)
            })
            .disposed(by: disposeBag)
        
        rootView.collectionView.rx.contentOffset
            .map { [weak self] offset in
                guard let self = self else { return 0 }
                let width = self.rootView.collectionView.frame.width
                guard width > 0 else { return 0 }
                let page = Int(round(offset.x / width))
                return page
            }
            .distinctUntilChanged()
            .bind(to: currentIndexRelay)
            .disposed(by: disposeBag)
        
        viewModel.photoItemListRelay
            .asDriver()
            .drive(onNext: { [weak self] photoItemList in
                if photoItemList.isEmpty {
                    self?.dismiss(animated: true)
                } else {
                    self?.rootView.collectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoEditViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.photoItemListRelay.value.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.cellIdentifier,
            for: indexPath
        ) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.photoItemListRelay.value[indexPath.item]
        cell.configure(photoItem: item)
        return cell
    }
}

extension PhotoEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return rootView.collectionView.bounds.size
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}

private extension PhotoEditViewController {
    func setUpAction() {
        rootView.closeButton.addTarget(
            self,
            action: #selector(didTabCloseButton),
            for: .touchUpInside
        )
        
        rootView.addAlbumButton.addTarget(
            self,
            action: #selector(didTapAddAlbumButton),
            for: .touchUpInside
        )
    }
    
    @objc
    func didTabCloseButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapAddAlbumButton() {
        let alert = UIAlertController(
            title: "새 앨범 만들기",
            message: "앨범 이름을 입력해주세요.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "앨범 이름"
        }
        
        let confirmAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard
                let self,
                let albumName = alert.textFields?.first?.text,
                !albumName.isEmpty
            else { return }

            self.viewModel.createAlbum(named: albumName)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func setupAlbumButtons(albums: [PHAssetCollection]) {
        rootView.albumStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for album in albums {
            let button = AlbumButton(title: album.localizedTitle)

            button.addAction(UIAction(handler: { [weak self] _ in
                self?.albumButtonTappedRelay.accept(album)
            }), for: .touchUpInside)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.rootView.albumStackView.addArrangedSubview(button)
            }
        }
    }
}
