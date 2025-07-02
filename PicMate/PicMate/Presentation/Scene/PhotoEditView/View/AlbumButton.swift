//
//  AlbumButton.swift
//  PicMate
//
//  Created by 최안용 on 7/1/25.
//

import UIKit

final class AlbumButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String?, isAddButton: Bool = false) {
        super.init(frame: .zero)
        
        configure(title: title ?? "이름 없음", isAddButton: isAddButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AlbumButton {
    func configure(title: String, isAddButton: Bool) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .sheetLayer
        config.cornerStyle = .medium
        
        if isAddButton {
            config.image = .init(systemName: "rectangle.badge.plus")
        } else {
            config.image = .init(systemName: "tray.and.arrow.down")
        }
        config.imagePadding = 5
        config.imagePlacement = .top
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 10,
            bottom: 8,
            trailing: 10
        )
            
        self.setTitleColor(.white, for: .normal)
        
        let font = UIFont.font(.pretendardMedium, ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer(attributes)
        )
        
        self.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            updatedConfig?.baseBackgroundColor = button.isHighlighted ? .tabTitle : .sheetLayer
            button.configuration = updatedConfig
        }
        
        self.configuration = config
    }
}
