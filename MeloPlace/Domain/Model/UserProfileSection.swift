//
//  UserProfileSection.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation

enum UserProfileSection: Int, Hashable {
    case profile = 0
    case myContents
    case tagedContents
    
    enum Item: Hashable {

        case profile(User)
        case myContents(MeloPlace?)
        case tagedContents(MeloPlace?)
        
    }
}
