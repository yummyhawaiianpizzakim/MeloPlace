//
//  UserProfileSection.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation

enum UserProfileSection: Int, Hashable {
    case profile = 0
    case likes
    case collections
    
    enum Item: Hashable {

        case profile(User)
        case likes(MeloPlace?)
        case collections(MeloPlace?)
        
    }
}
