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
    private var possibleColumnCounts: [CGFloat] = [1.0, 3.0, 5.0, 7.0/*, 9.0, 11.0, 13.0, 15.0*/]
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
            
            cell.configure(with: photoAsset)
            return cell
        }
    }
    
    func setupPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGesture)
    }
    
    @objc
    func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        switch gesture.state {
        case .began:
            didScaleDuringPinch = false

        case .changed:
            guard !didScaleDuringPinch else { return }

            let scale = gesture.scale
            let pinchLocation = gesture.location(in: collectionView)

            guard let indexPath = collectionView.indexPathForItem(at: pinchLocation) else { return }

            var newColumnCount = currentColumnCount
            if scale > 1.05 {
                if let index = possibleColumnCounts.firstIndex(of: currentColumnCount), index > 0 {
                    newColumnCount = possibleColumnCounts[index - 1]
                }
            } else if scale < 0.95 {
                if let index = possibleColumnCounts.firstIndex(of: currentColumnCount), index < possibleColumnCounts.count - 1 {
                    newColumnCount = possibleColumnCounts[index + 1]
                }
            }

            guard newColumnCount != currentColumnCount else { return }
            currentColumnCount = newColumnCount
            didScaleDuringPinch = true

            UIView.performWithoutAnimation {
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.layoutIfNeeded()

                guard let newAttributes = layout.layoutAttributesForItem(at: indexPath) else { return }
                let newCellCenter = newAttributes.center

                let collectionCenter = CGPoint(
                    x: collectionView.bounds.width / 2,
                    y: collectionView.bounds.height / 2
                )

                let delta = CGPoint(
                    x: newCellCenter.x - collectionCenter.x,
                    y: newCellCenter.y - collectionCenter.y
                )

                var newOffset = CGPoint(
                    x: delta.x,
                    y: delta.y
                )

                let maxOffsetX = max(0, collectionView.contentSize.width - collectionView.bounds.width)
                let maxOffsetY = max(0, collectionView.contentSize.height - collectionView.bounds.height)

                newOffset.x = max(0, min(maxOffsetX, newOffset.x))
                newOffset.y = max(0, min(maxOffsetY, newOffset.y))

                self.collectionView.setContentOffset(newOffset, animated: false)
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
