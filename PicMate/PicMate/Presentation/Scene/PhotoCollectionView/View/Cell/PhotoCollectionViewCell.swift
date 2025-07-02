//
//  PhotoCollectionViewCell.swift
//  PicMate
//
//  Created by 최안용 on 6/16/25.
//

import UIKit
import Photos

final class PhotoCollectionViewCell: UICollectionViewCell {
    static let imageManager = PHCachingImageManager.default()
    private let imageView = UIImageView()
    private let videoMarkView = UIImageView()
    private let livePhotoMarkView = UIImageView()
    
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
        imageLoadTask?.cancel()
        imageLoadTask = nil
        videoMarkView.isHidden = true
        livePhotoMarkView.isHidden = true
    }
    
    func configure(with photoAsset: PhotoItem) {
        if let thumbnail = photoAsset.thumbnail {
            self.imageView.image = thumbnail
            
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photoAsset.identifier], options: nil).firstObject
            if let asset = asset {
                let mediaType = PHAssetMediaType(rawValue: Int(photoAsset.mediaType)) ?? .unknown
                switch mediaType {
                case .image:
                    if asset.mediaSubtypes.contains(.photoLive) {
                        self.livePhotoMarkView.isHidden = false
                    }
                case .video:
                    self.videoMarkView.isHidden = false
                default:
                    break
                }
            }
            return
        } else {
            let asset = PHAsset.fetchAssets(
                withLocalIdentifiers: [photoAsset.identifier],
                options: nil
            ).firstObject
            
            if let asset = asset {
                let size = CGSize(width: self.bounds.width, height: self.bounds.height)
                    .applying(.init(scaleX: UIScreen.main.scale, y: UIScreen.main.scale))
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = false
                options.isNetworkAccessAllowed = true
                
                imageLoadTask = Task { [weak self] in
                    guard let self else { return }
                    let image = await withCheckedContinuation { continuation in
                        PhotoCollectionViewCell.imageManager.requestImage(
                            for: asset,
                            targetSize: size,
                            contentMode: .aspectFill,
                            options: options
                        ) { image, _ in
                            continuation.resume(returning: image)
                        }
                    }
                    
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        self.imageView.image = image
                        photoAsset.thumbnail = image
                        let mediaType = PHAssetMediaType(rawValue: Int(photoAsset.mediaType)) ?? .unknown
                        switch mediaType {
                        case .image:
                            if asset.mediaSubtypes.contains(.photoLive) {
                                self.livePhotoMarkView.isHidden = false
                            }
                        case .video:
                            self.videoMarkView.isHidden = false
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
}

private extension PhotoCollectionViewCell {
    func setStyle() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        videoMarkView.do {
            $0.image = UIImage(systemName: "video.fill")
            $0.tintColor = .white
            $0.isHidden = true
        }
        
        livePhotoMarkView.do {
            $0.image = UIImage(systemName: "livephoto")
            $0.tintColor = .white
            $0.isHidden = true
        }
    }
    
    func setUI() {
        contentView.addSubViews(imageView, videoMarkView, livePhotoMarkView)
    }
    
    func setLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        videoMarkView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(5)
            $0.trailing.equalTo(contentView.snp.trailing).inset(5)
        }
        
        livePhotoMarkView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).inset(5)
            $0.trailing.equalTo(contentView.snp.trailing).inset(5)
        }
    }
}

