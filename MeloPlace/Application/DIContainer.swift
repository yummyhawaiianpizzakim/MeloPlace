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
        self.registerUserRepository()
        self.registerMeloPlaceRepository()
    }
    
    func registerUseCase() {
        self.registerFetchUserUseCase()
        self.registerFetchMeloPlaceUseCase()
    }
    
    func registerViewModel() {
        self.registerMainViewModel()
        self.registerMapViewModel()
        self.registerBrowseViewModel()
        self.registerUserProfileViewModel()
        self.registerAddMeloPlaceViewModel()
        self.registerMeloLocationViewModel()
        self.registerMusicListViewModel()
        self.registerSelectDateViewModel()
        self.registerSignInViewModel()
        self.registerSignUpViewModel()
        self.registerMeloPlaceDetailViewModel()
        self.registerMapMeloPlaceListViewModel()
        self.registerSearchViewModel()
    }
}

private extension DIContainer {
    func registerFireBaseNetworkService() {
        self.container.register(FireBaseNetworkServiceProtocol.self) { resolver in
            return FireBaseNetworkService()
        }
        .inObjectScope(.container)
    }
}

private extension DIContainer {
    
}

private extension DIContainer {
    func registerUserRepository() {
        self.container.register(UserRepositoryProtocol.self) { resolver in
            let fireBaseService = FireBaseNetworkService.shared
            
            return UserRepository(fireBaseService: fireBaseService)
        }
        .inObjectScope(.container)
    }
    
    func registerMeloPlaceRepository() {
        self.container.register(MeloPlaceRepositoryProtocol.self) { resolver in
            let fireBaseService = FireBaseNetworkService.shared
            
            return MeloPlaceRepository(fireBaseService: fireBaseService)
        }
        .inObjectScope(.container)
    }
}

private extension DIContainer {
    func registerFetchUserUseCase() {
        self.container.register(FetchUserUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            
            return FetchUserUseCase(userRepository: userRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerFetchMeloPlaceUseCase() {
        self.container.register(FetchMeloPlaceUseCaseProtocol.self) { resolver in
            let meloPlaceRepository = resolver.resolve(MeloPlaceRepositoryProtocol.self)
            
            return FetchMeloPlaceUseCase(meloPlaceRepository: meloPlaceRepository!)
        }
        .inObjectScope(.container)
    }
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
    
    func registerUserProfileViewModel() {
        self.container.register(UserProfileViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            let fetchMeloPlaceUseCase = resolver.resolve(FetchMeloPlaceUseCaseProtocol.self)
            
            return UserProfileViewModel(fetchUserUseCase: fetchUserUseCase!, fetchMeloPlaceUseCase: fetchMeloPlaceUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerAddMeloPlaceViewModel() {
        self.container.register(AddMeloPlaceViewModel.self) { resolver in
            
            return AddMeloPlaceViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerMeloLocationViewModel() {
        self.container.register(MeloLocationViewModel.self) { resolver in
            
            return MeloLocationViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerMusicListViewModel() {
        self.container.register(MusicListViewModel.self) { resolver in
            return MusicListViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerSelectDateViewModel() {
        self.container.register(SelectDateViewModel.self) { resolver in
            return SelectDateViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerSignInViewModel() {
        self.container.register(SignInViewModel.self) { resolver in
            return SignInViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerSignUpViewModel() {
        self.container.register(SignUpViewModel.self) { resolver in
            return SignUpViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerMeloPlaceDetailViewModel() {
        self.container.register(MeloPlaceDetailViewModel.self) { resolver in
            return MeloPlaceDetailViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerMapMeloPlaceListViewModel() {
        self.container.register(MapMeloPlaceListViewModel.self) { resolver in
            return MapMeloPlaceListViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerSearchViewModel() {
        self.container.register(SearchViewModel.self) { resolver in
            return SearchViewModel()
        }
        .inObjectScope(.graph)
    }
}
