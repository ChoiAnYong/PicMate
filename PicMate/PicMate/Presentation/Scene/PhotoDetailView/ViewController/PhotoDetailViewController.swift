//
//  PhotoDetailViewController.swift
//  PicMate
//
//  Created by 최안용 on 6/22/25.
//

import UIKit

import RxSwift

final class PhotoDetailViewController: UIViewController {
    private let rootView: PhotoDetailView = PhotoDetailView()
    private let viewModel: PhotoDetailViewModel
    
    private let disposeBag = DisposeBag()
    
    init(item: PhotoItem) {
        self.viewModel = PhotoDetailViewModel(photoItem: item)
        
        super.init(nibName: nil, bundle: nil)
        setGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        bind()
        navigationController?.isNavigationBarHidden = true
    }
    
    private func bind() {
        viewModel.fullSizeImage
            .compactMap { $0 }
            .bind(to: rootView.imageView.rx.image)
            .disposed(by: disposeBag)
        viewModel.createImageDate
            .compactMap { $0 }
            .bind(to: rootView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.loadTrigger.accept(())
    }
}

// MARK: Gesture Setting
private extension PhotoDetailViewController {
    func setGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        rootView.scrollView.addGestureRecognizer(panGesture)
    }
    
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: rootView)
        let progress = min(max(translation.y / rootView.bounds.height, 0), 1)
        let scale = max(0.5, 1 - progress * 0.5)
        
        switch gesture.state {
        case .changed:
            let transform = CGAffineTransform(translationX: translation.x, y: translation.y)
                .scaledBy(x: scale, y: scale)
            rootView.imageView.transform = transform
            
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1 - progress)
            
            let backgroundAlpha = 1 - progress
            self.view.backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
            
            let overlayAlpha = max(0.0, min(1.0, 1 - progress * 5))
            rootView.headerView.alpha = overlayAlpha
            rootView.footerView.alpha = overlayAlpha
            
        case .ended, .cancelled:
            if translation.y > 200 {
                dismiss(animated: false)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
                    self.rootView.imageView.transform = .identity
                    self.view.backgroundColor = .black
                    self.rootView.headerView.alpha = 1
                    self.rootView.footerView.alpha = 1
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        if rootView.scrollView.zoomScale > rootView.scrollView.minimumZoomScale {
            return false
        }
        
        let velocity = panGesture.velocity(in: rootView)
        return abs(velocity.y) > abs(velocity.x)
    }
}
