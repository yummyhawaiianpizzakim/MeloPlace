//
//  UserProfileLayout.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import UIKit

enum UserProfileLayout: Int, CaseIterable {
    case contents = 0
    case likes
    
    var appOffset: CGFloat {
            return UIScreen.main.bounds.width / 50
        }

    func createLayout(index: Int) -> NSCollectionLayoutSection {
        switch self {
        case .contents:
            return index == 0 ? self.generateProfileLayout() : self.generateLikesLayout()
        case .likes:
            return index == 0 ? self.generateProfileLayout() : self.generateLikesLayout()
        }
    }
    
    private func generateProfileLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(appOffset * 32))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(appOffset * 32))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func generateLikesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/2),
            heightDimension: .fractionalWidth(1/2)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        return section
    }
    
}
