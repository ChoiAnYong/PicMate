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
import Then
import SnapKit

final class FullPhotoViewController: UIViewController {
    private let segmentedControl = PMSegmentedControl(items: ["전체사진", "즐겨찾기"])
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    private let allPhotoVM = PhotoPageViewModel(isFavorite: false)
    private let favoritePhotoVM = PhotoPageViewModel(isFavorite: true)
    
    private lazy var allPhotoVC = PhotoPageViewController(viewModel: allPhotoVM)
    private lazy var favoritePhotoVC = PhotoPageViewController(viewModel: favoritePhotoVM)
    private lazy var pages = [allPhotoVC, favoritePhotoVC]
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPhotoAssets()
        setStyle()
        setUI()
        setLayout()
        setDelegate()
        bind()
        PHPhotoLibrary.shared().register(self)
        navigationItem.title = "사진"
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

// MARK: - Setting
private extension FullPhotoViewController {
    func setStyle() {
        view.do {
            $0.backgroundColor = .white
        }
        
        pageViewController.do {
            $0.view.backgroundColor = .background
        }
        
        segmentedControl.do {
            $0.selectedSegmentIndex = 0
        }
    }
    
    func setUI() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubViews(segmentedControl, pageViewController.view)
        if let firstVC = pages.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    func setLayout() {
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func setDelegate() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        allPhotoVC.setPhotoCollectionViewDelegate(self)
        favoritePhotoVC.setPhotoCollectionViewDelegate(self)
    }
    
    func bind() {
        segmentedControl.rx.selectedSegmentIndex
            .bind(onNext: { [weak self] index in
                guard let self = self else { return }
                let direction: UIPageViewController.NavigationDirection = index == 0 ? .reverse : .forward
                self.pageViewController.setViewControllers(
                    [self.pages[index]],
                    direction: direction,
                    animated: true
                )
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UIPageViewController
extension FullPhotoViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? PhotoPageViewController,
            let index = pages.firstIndex(of: vc) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? PhotoPageViewController,
              let index = pages.firstIndex(of: vc) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pages.count {
            return nil
        }
        return pages[nextIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        if let target = pendingViewControllers.first,
           let index = pages.firstIndex(where: { $0 === target }) {
            segmentedControl.selectedSegmentIndex = index
        }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if !completed, let previous = previousViewControllers.first,
           let index = pages.firstIndex(where: { $0 === previous }) {
            segmentedControl.selectedSegmentIndex = index
        }
    }
}

private extension FullPhotoViewController {
    func loadPhotoAssets() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized:
                print("📸 사진 라이브러리 접근 허용됨")
                self.allPhotoVM.reloadTrigger.accept(())
                self.favoritePhotoVM.reloadTrigger.accept(())
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

// MARK: - PHPhotoLibraryChangeObserver
extension FullPhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            self?.allPhotoVM.reloadTrigger.accept(())
            self?.favoritePhotoVM.reloadTrigger.accept(())
        }
    }
}

// MARK: - PhotoCollctionViewDelegate
extension FullPhotoViewController: PhotoCollctionViewDelegate {
    func didSelectPhoto(_ photo: PhotoItem) {
        let destination = PhotoDetailViewController(item: photo)
        destination.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async { [weak self] in
            self?.present(destination, animated: true)
        }
    }
}
