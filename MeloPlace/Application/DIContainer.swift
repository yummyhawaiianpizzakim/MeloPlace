//
//  DIContainer.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import Swinject

class DIContainer {
    static let shared = DIContainer()
    
    let container = Container()
    
    private init() {
        registerInfraStructure()
        registerService()
        registerRepository()
        registerUseCase()
        registerViewModel()
    }
    
    func registerInfraStructure() {
    }
    
    func registerService() {
    }
    
    func registerRepository() {
    }
    
    func registerUseCase() {
    }
    
    func registerViewModel() {
        self.registerMainViewModel()
        self.registerMapViewModel()
        self.registerBrowseViewModel()
        self.registerSettingViewModel()
    }
}

private extension DIContainer {
    
}

private extension DIContainer {
    
}

private extension DIContainer {
    
}

private extension DIContainer {
    
}

private extension DIContainer {
    func registerMainViewModel() {
        self.container.register(MainViewModel.self) { resolver in
            
            return MainViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerMapViewModel() {
        self.container.register(MapViewModel.self) { resolver in
            
            return MapViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerBrowseViewModel() {
        self.container.register(BrowseViewModel.self) { resolver in
            
            return BrowseViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerSettingViewModel() {
        self.container.register(SettingViewModel.self) { resolver in
            
            return SettingViewModel()
        }
        .inObjectScope(.graph)
    }
    
}
