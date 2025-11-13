//
//  PhotoItem.swift
//  PicMate
//
//  Created by 최안용 on 6/17/25.
//

import UIKit

final class PhotoItem: NSObject {
    var createDate: Date
    var identifier: String
    var mediaType: Int16
    var isFavorite: Bool
    var thumbnail: UIImage?
    
    init(
        createDate: Date,
        identifier: String,
        mediaType: Int16,
        isFavorite: Bool,
        thumbnail: UIImage? = nil
    ) {
        self.createDate = createDate
        self.identifier = identifier
        self.isFavorite = isFavorite
        self.mediaType = mediaType
        self.thumbnail = thumbnail
    }
}
