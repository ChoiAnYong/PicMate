//
//  ViewModelType.swift
//  PicMate
//
//  Created by 최안용 on 6/25/25.
//

import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output
}
