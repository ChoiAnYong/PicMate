//
//  PhotoDetailView.swift
//  PicMate
//
//  Created by 최안용 on 6/18/25.
//

import UIKit
import Photos

import SnapKit
import Then

final class PhotoDetailView: UIView, BaseViewProtocol {
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let headerView = UIView()
    private let titleLabel = UILabel()
    let dateLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    let footerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpView()
        setGesture()
        scrollView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStyle() {
        self.do {
            $0.backgroundColor = .black
        }
        
        scrollView.do {
            $0.minimumZoomScale = 1.0
            $0.maximumZoomScale = 3.0
        }
        
        imageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        headerView.do {
            $0.backgroundColor = .black
            $0.alpha = 0.8
        }
        
        titleLabel.do {
            $0.font = .font(.pretendardSemiBold, ofSize: 16)
            $0.text = "사진"
            $0.textColor = .white
        }
        
        closeButton.do {
            $0.setImage(.init(systemName: "xmark"), for: .normal)
            $0.tintColor = .white
        }
        
        dateLabel.do {
            $0.font = .font(.pretendardMedium, ofSize: 12)
            $0.textColor = .tabTitle
        }
        
        footerView.do {
            $0.backgroundColor = .black
            $0.alpha = 0.8
        }
        
        favoriteButton.do {
            $0.setImage(.init(systemName: "star"), for: .normal)
            $0.tintColor = .yellow
        }
    }
    
    func setUI() {
        addSubViews(scrollView, headerView, footerView)
        scrollView.addSubViews(imageView)
        headerView.addSubViews(closeButton, titleLabel, dateLabel)
        footerView.addSubViews(favoriteButton)
    }
    
    func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(scrollView.snp.height)
            $0.centerX.equalTo(scrollView.snp.centerX)
            $0.centerY.equalTo(scrollView.snp.centerY)
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(120)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalTo(headerView.snp.leading).inset(15)
            $0.bottom.equalTo(headerView.snp.bottom).inset(30)
            $0.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalTo(headerView.snp.centerX)
            $0.centerY.equalTo(closeButton.snp.centerY)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalTo(headerView.snp.centerX)
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
        }
        
        footerView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.top.equalTo(footerView.snp.top).inset(15)
            $0.centerX.equalTo(footerView.snp.centerX)
            $0.size.equalTo(20)
        }
    }
}

// MARK: - UIScollViewDelegate
extension PhotoDetailView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: Gesture Setting
private extension PhotoDetailView {
    func setGesture() {
        let singleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleSingleTap(_:))
        )
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        
        scrollView.addGestureRecognizer(singleTap)
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc
    func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.headerView.isHidden.toggle()
            self.footerView.isHidden.toggle()
        }
    }
    
    @objc
    func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let zoomScale = scrollView.zoomScale > scrollView.minimumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        let point = gesture.location(in: scrollView)
        let size = CGSize(width: scrollView.bounds.width / zoomScale, height: scrollView.bounds.height / zoomScale)
        let origin = CGPoint(x: point.x - size.width / 2, y: point.y - size.height / 2)
        let rect = CGRect(origin: origin, size: size)

        scrollView.zoom(to: rect, animated: true)
    }
}
