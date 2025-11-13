//
//  PhotoCell.swift
//  PicMate
//
//  Created by 최안용 on 6/30/25.
//

import Photos
import UIKit

import SnapKit
import Then

final class PhotoCell: UICollectionViewCell {
    static let imageManager = PHCachingImageManager.default()
    private let imageView = UIImageView()
    
    private var imageLoadTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
    }
    
    func configure(photoItem: PhotoItem) {
        let asset = PHAsset.fetchAssets(
            withLocalIdentifiers: [photoItem.identifier],
            options: nil
        ).firstObject
        
        guard let asset else { return }
        
        let size = CGSize(width: self.bounds.width, height: self.bounds.height)
            .applying(.init(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        
        imageLoadTask = Task { [weak self] in
            guard let self else { return }
            let image = await withCheckedContinuation { continuation in
                PhotoCell.imageManager.requestImage(
                    for: asset,
                    targetSize: size,
                    contentMode: .aspectFit,
                    options: options) { image, _ in
                        continuation.resume(returning: image)
                    }
            }
            
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.imageView.image = image
                photoItem.thumbnail = image
            }
        }
    }
}

private extension PhotoCell {
    func setStyle() {
        imageView.do {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
        }
    }
    
    func setUI() {
        contentView.addSubview(imageView)
    }
    
    func setLayout() {
        imageView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(8)
        }
    }
}
