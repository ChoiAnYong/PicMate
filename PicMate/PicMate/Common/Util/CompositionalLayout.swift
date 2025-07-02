//
//  CompositionalLayout.swift
//  PicMate
//
//  Created by 최안용 on 6/26/25.
//

import UIKit

struct CompositionalLayout {
    static func createCleanUpMonthListLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(58)
                )
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 10,
                trailing: 20
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(58)
                ),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(42)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            header.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 0,
                trailing: 0
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
}
