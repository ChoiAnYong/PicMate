//
//  BaseViewProtocol.swift
//  PicMate
//
//  Created by 최안용 on 6/15/25.
//

import Foundation

protocol BaseViewProtocol {
    func setUpView()
    func setStyle()
    func setUI()
    func setLayout()
}

extension BaseViewProtocol {
    func setUpView() {
        setStyle()
        setUI()
        setLayout()
    }
}
