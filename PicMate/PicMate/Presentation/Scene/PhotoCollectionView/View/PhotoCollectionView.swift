//
//  PhotoCollectionView.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import Photos
import PhotosUI
import UIKit

import SnapKit
import Then

protocol PhotoCollctionViewDelegate: AnyObject {
    func didSelectPhoto(_ photo: PhotoItem)
}

final class PhotoCollectionView: UIView , BaseViewProtocol {
    private var dataSource: UICollectionViewDiffableDataSource<Section, PhotoItem>!
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let imageManager = PHCachingImageManager()
    private var currentColumnCount: CGFloat = 5.0
    private var possibleColumnCounts: [CGFloat] = [1.0, 3.0, 5.0, 7.0, 9.0, 11.0, 13.0, 15.0]
    private var didScaleDuringPinch = false
    
    weak var delegate: PhotoCollctionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.delegate = self
        setUpView()
        setUpDataSource()
        setupPinchGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        collectionView.do {
            let layout = UICollectionViewFlowLayout()
            let spacing: CGFloat = 0
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
            $0.backgroundColor = .background
            $0.collectionViewLayout = layout
            $0.register(
                PhotoCollectionViewCell.self,
                forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier
            )
        }
    }
    
    func setUI() {
        self.addSubview(collectionView)
    }
    
    func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setDelegate(viewController: UICollectionViewDelegate) {
        collectionView.delegate = viewController
    }
    
    func loadPhotoAssets(_ snapshot: NSDiffableDataSourceSnapshot<Section, PhotoItem>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: true)
            
            let lastItem = snapshot.itemIdentifiers.last
            if let lastItem = lastItem,
               let indexPath = self.dataSource.indexPath(for: lastItem) {
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
}

private extension PhotoCollectionView {
    func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PhotoItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, photoAsset: PhotoItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier,
                for: indexPath
            ) as? PhotoCollectionViewCell else {
                return PhotoCollectionViewCell()
            }
            
            cell.configure(with: photoAsset, imageManager: self.imageManager)
            return cell
        }
    }
    
    private func setupPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGesture)
    }
    
    @objc
    private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            didScaleDuringPinch = false
            
        case .changed:
            guard !didScaleDuringPinch else { return }
            
            let scale = gesture.scale
            
            if scale > 1.1 {
                if let index = possibleColumnCounts.firstIndex(of: currentColumnCount),
                   index > 0 {
                    currentColumnCount = possibleColumnCounts[index - 1]
                    didScaleDuringPinch = true
                }
            } else if scale < 0.9 {
                if let index = possibleColumnCounts.firstIndex(of: currentColumnCount),
                   index < possibleColumnCounts.count - 1 {
                    currentColumnCount = possibleColumnCounts[index + 1]
                    didScaleDuringPinch = true
                }
            }
            
            if didScaleDuringPinch {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
            
        case .ended, .cancelled, .failed:
            gesture.scale = 1.0
            didScaleDuringPinch = false
            
        default:
            break
        }
    }
}

extension PhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.inset(by: collectionView.contentInset).width / currentColumnCount
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            delegate?.didSelectPhoto(item)
        }
    }
}
