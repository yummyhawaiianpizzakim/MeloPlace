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
        self.registerFireBaseNetworkService()
    }
    
    func registerService() {
        self.registerSpotifyService()
        self.registerLocationService()
    }
    
    func registerRepository() {
        self.registerSignRepository()
        self.registerSpotifyRepository()
        self.registerCommentRepository()
        self.registerImageRepository()
        self.registerMapRepository()
        self.registerUserRepository()
        self.registerMeloPlaceRepository()
    }
    
    func registerUseCase() {
        self.registerFetchBrowseUseCase()
        self.registerSignInUseCase()
        self.registerSignUpUseCase()
        self.registerSearchMusicUseCase()
        self.registerFetchSpotifyUserProfileUseCase()
        self.registerTryConnectSpotifyUseCase()
        self.registerPlayMusicUseCase()
        self.registerUpdatePlayerStateUseCase()
        self.registerObservePlayerStateUseCase()
        self.registerUploadImageUseCase()
        self.registerPostCommentUseCase()
        self.registerFetchCommentUseCase()
        self.registerFetchCurrentLocationUseCase()
        self.registerSearchLocationNameUseCase()
        self.registerReverseGeoCodeUseCase()
        self.registerUpdateLocationUseCase()
        self.registerFetchUserUseCase()
        self.registerUpdateUserUseCase()
        self.registerFetchMeloPlaceUseCase()
        self.registerFetchMapMeloPlaceUseCase()
        self.registerCreateMeloPlaceUseCase()
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
        self.registerAnotherUserProfileViewModel()
        self.registerCommentViewModel()
        self.registerSearchUserViewModel()
        self.registerFollowingUserListViewModel()
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
    func registerSpotifyService() {
        self.container.register(SpotifyServiceProtocol.self) { resolver in
            return SpotifyService()
        }
        .inObjectScope(.container)
    }
    
    func registerLocationService() {
        self.container.register(LocationManagerProtocol.self) { resolver in
            return LocationManager()
        }
        .inObjectScope(.container)
    }
}

private extension DIContainer {
    func registerSignRepository() {
        self.container.register(SignRepositoryProtocol.self) { resolver in
            let firebaseService = resolver.resolve(FireBaseNetworkServiceProtocol.self)
            
            return SignRepository(firebaseService: firebaseService!)
        }
        .inObjectScope(.container)
    }
    
    func registerSpotifyRepository() {
        self.container.register(SpotifyRepositoryProtocol.self) { resolver in
            let spotifyService = resolver.resolve(SpotifyServiceProtocol.self)
            
            return SpotifyRepository(spotifyService: spotifyService!)
        }
        .inObjectScope(.container)
    }
    
    func registerImageRepository() {
        self.container.register(ImageRepositoryProtocol.self) { resolver in
            let firebaseService = resolver.resolve(FireBaseNetworkServiceProtocol.self)
            
            return ImageRepository(fireBaseService: firebaseService!)
        }
        .inObjectScope(.container)
    }
    
    func registerCommentRepository() {
        self.container.register(CommentRepositoryProtocol.self) { resolver in
            let firebaseService = resolver.resolve(FireBaseNetworkServiceProtocol.self)
            
            return CommentRepository(fireBaseService: firebaseService!)
        }
        .inObjectScope(.container)
    }
    
    func registerMapRepository() {
        self.container.register(MapRepositoryProtocol.self) { resolver in
            let locationManager = resolver.resolve(LocationManagerProtocol.self)
            
            return MapRepository(locationManager: locationManager!)
        }
        .inObjectScope(.container)
    }
    
    func registerUserRepository() {
        self.container.register(UserRepositoryProtocol.self) { resolver in
            let fireBaseService = resolver.resolve(FireBaseNetworkServiceProtocol.self)
            
            return UserRepository(fireBaseService: fireBaseService!)
        }
        .inObjectScope(.container)
    }
    
    func registerMeloPlaceRepository() {
        self.container.register(MeloPlaceRepositoryProtocol.self) { resolver in
            let fireBaseService = resolver.resolve(FireBaseNetworkServiceProtocol.self)
            
            return MeloPlaceRepository(fireBaseService: fireBaseService!)
        }
        .inObjectScope(.container)
    }
}

private extension DIContainer {
    func registerFetchBrowseUseCase() {
        self.container.register(FetchBrowseUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            let meloPlaceRepository = resolver.resolve(MeloPlaceRepositoryProtocol.self)
            
            return FetchBrowseUseCase(userRepository: userRepository!,
                                      meloPlaceRepository: meloPlaceRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerSignInUseCase() {
        self.container.register(SignInUseCaseProtocol.self) { resolver in
            let signRepository = resolver.resolve(SignRepositoryProtocol.self)
            
            return SignInUseCase(signRepository: signRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerSignUpUseCase() {
        self.container.register(SignUpUseCaseProtocol.self) { resolver in
            let signRepository = resolver.resolve(SignRepositoryProtocol.self)
                
            return SignUpUseCase(signRepository: signRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerSearchMusicUseCase() {
        self.container.register(SearchMusicUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return SearchMusicUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerFetchSpotifyUserProfileUseCase() {
        self.container.register(FetchSpotifyUserProfileUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return FetchSpotifyUserProfileUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerTryConnectSpotifyUseCase() {
        self.container.register(TryConnectSpotifyUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return TryConnectSpotifyUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerPlayMusicUseCase() {
        self.container.register(PlayMusicUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return PlayMusicUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerUpdatePlayerStateUseCase() {
        self.container.register(UpdatePlayerStateUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return UpdatePlayerStateUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerObservePlayerStateUseCase() {
        self.container.register(ObservePlayerStateUseCaseProtocol.self) { resolver in
            let spotifyRepository = resolver.resolve(SpotifyRepositoryProtocol.self)
                
            return ObservePlayerStateUseCase(spotifyRepository: spotifyRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerUploadImageUseCase() {
        self.container.register(UploadImageUseCaseProtocol.self) { resolver in
            let imageRepository = resolver.resolve(ImageRepositoryProtocol.self)
            
            return UploadImageUseCase(imageRepository: imageRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerPostCommentUseCase() {
        self.container.register(PostCommentUseCaseProtocol.self) { resolver in
            let commentRepository = resolver.resolve(CommentRepositoryProtocol.self)
            
            return PostCommentUseCase(commentRepository: commentRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerFetchCommentUseCase() {
        self.container.register(FetchCommentUseCaseProtocol.self) { resolver in
            let commentRepository = resolver.resolve(CommentRepositoryProtocol.self)
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            
            return FetchCommentUseCase(commentRepository: commentRepository!,
                                       userRepository: userRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerFetchCurrentLocationUseCase() {
        self.container.register(FetchCurrentLocationUseCaseProtocol.self) { resolver in
            let mapRepository = resolver.resolve(MapRepositoryProtocol.self)
            
            return FetchCurrentLocationUseCase(mapRepository: mapRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerSearchLocationNameUseCase() {
        self.container.register(SearchLocationNameUseCaseProtocol.self) { resolver in
            let mapRepository = resolver.resolve(MapRepositoryProtocol.self)
            
            return SearchLocationNameUseCase(mapRepository: mapRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerReverseGeoCodeUseCase() {
        self.container.register(ReverseGeoCodeUseCaseProtocol.self) { resolver in
            let mapRepository = resolver.resolve(MapRepositoryProtocol.self)
            
            return ReverseGeoCodeUseCase(mapRepository: mapRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerUpdateLocationUseCase() {
        self.container.register(UpdateLocationUseCaseProtocol.self) { resolver in
            let mapRepository = resolver.resolve(MapRepositoryProtocol.self)
            
            return UpdateLocationUseCase(mapRepository: mapRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerFetchUserUseCase() {
        self.container.register(FetchUserUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            
            return FetchUserUseCase(userRepository: userRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerUpdateUserUseCase() {
        self.container.register(UpdateUserUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            
            return UpdateUserUseCase(userRepository: userRepository!)
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
    
    func registerFetchMapMeloPlaceUseCase() {
        self.container.register(FetchMapMeloPlaceUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolve(UserRepositoryProtocol.self)
            let meloPlaceRepository = resolver.resolve(MeloPlaceRepositoryProtocol.self)
            let mapRepository = resolver.resolve(MapRepositoryProtocol.self)
            
            return FetchMapMeloPlaceUseCase(userRepository: userRepository!,
                                            meloPlaceRepository: meloPlaceRepository!,
                                            mapRepository: mapRepository!)
        }
        .inObjectScope(.container)
    }
    
    func registerCreateMeloPlaceUseCase() {
        self.container.register(CreateMeloPlaceUseCaseProtocol.self) { resolver in
            let meloPlaceRepository = resolver.resolve(MeloPlaceRepositoryProtocol.self)
            
            return CreateMeloPlaceUseCase(meloPlaceRepository: meloPlaceRepository!)
        }
        .inObjectScope(.container)
    }
}

private extension DIContainer {
    func registerMainViewModel() {
        self.container.register(MainViewModel.self) { resolver in
            let fetchMeloPlaceUseCase = resolver.resolve(FetchMeloPlaceUseCaseProtocol.self)
            let playMusicUseCase = resolver.resolve(PlayMusicUseCaseProtocol.self)
            let updatePlayerStateUseCase = resolver.resolve(UpdatePlayerStateUseCaseProtocol.self)
            let observePlayerStateUseCase = resolver.resolve(ObservePlayerStateUseCaseProtocol.self)
            
            return MainViewModel(fetchMeloPlaceUseCase: fetchMeloPlaceUseCase!,
                                 playMusicUseCase: playMusicUseCase!,
                                 updatePlayerStateUseCase: updatePlayerStateUseCase!,
                                 observePlayerStateUseCase: observePlayerStateUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerMapViewModel() {
        self.container.register(MapViewModel.self) { resolver in
            let updateLocationUseCase = resolver.resolve(UpdateLocationUseCaseProtocol.self)
            let fetchMapMeloPlaceUseCase = resolver.resolve(FetchMapMeloPlaceUseCaseProtocol.self)
            let fetchCurrentLocationUseCase = resolver.resolve(FetchCurrentLocationUseCaseProtocol.self)
            let reverseGeoCodeUseCase = resolver.resolve(ReverseGeoCodeUseCaseProtocol.self)
            
            return MapViewModel(updateLocationUseCase: updateLocationUseCase!,
                                fetchMapMeloPlaceUseCase: fetchMapMeloPlaceUseCase!,
                                fetchCurrentLocationUseCase: fetchCurrentLocationUseCase!,
                                reverseGeoCodeUseCase: reverseGeoCodeUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerBrowseViewModel() {
        self.container.register(BrowseViewModel.self) { resolver in
            let fetchBrowseUseCase = resolver.resolve(FetchBrowseUseCaseProtocol.self)
            let playMusicUseCase = resolver.resolve(PlayMusicUseCaseProtocol.self)
            let updatePlayerStateUseCase = resolver.resolve(UpdatePlayerStateUseCaseProtocol.self)
            let observePlayerStateUseCase = resolver.resolve(ObservePlayerStateUseCaseProtocol.self)
            
            return BrowseViewModel(fetchBrowseUseCase: fetchBrowseUseCase!,
                                   playMusicUseCase: playMusicUseCase!,
                                   updatePlayerStateUseCase: updatePlayerStateUseCase!,
                                   observePlayerStateUseCase: observePlayerStateUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerUserProfileViewModel() {
        self.container.register(UserProfileViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            let fetchMeloPlaceUseCase = resolver.resolve(FetchMeloPlaceUseCaseProtocol.self)
            let updateUserUseCase = resolver.resolve(UpdateUserUseCaseProtocol.self)
            
            return UserProfileViewModel(fetchUserUseCase: fetchUserUseCase!,
                                        fetchMeloPlaceUseCase: fetchMeloPlaceUseCase!,
                                        updateUserUseCase: updateUserUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerAddMeloPlaceViewModel() {
        self.container.register(AddMeloPlaceViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            let createMeloPlaceUseCase = resolver.resolve(CreateMeloPlaceUseCaseProtocol.self)
            let uploadImageUseCase = resolver.resolve(UploadImageUseCaseProtocol.self)
            
            return AddMeloPlaceViewModel(fetchUserUseCase: fetchUserUseCase!,
                                         createMeloPlaceUseCase: createMeloPlaceUseCase!,
                                         uploadImageUseCase: uploadImageUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerMeloLocationViewModel() {
        self.container.register(MeloLocationViewModel.self) { resolver in
            let updateLocationUseCase = resolver.resolve(UpdateLocationUseCaseProtocol.self)
            let fetchCurrentLocationUseCase = resolver.resolve(FetchCurrentLocationUseCaseProtocol.self)
            let reverseGeoCodeUseCase = resolver.resolve(ReverseGeoCodeUseCaseProtocol.self)
            
            return MeloLocationViewModel(updateLocationUseCase: updateLocationUseCase!,
                                         fetchCurrentLocationUseCase: fetchCurrentLocationUseCase!,
                                         reverseGeoCodeUseCase: reverseGeoCodeUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerMusicListViewModel() {
        self.container.register(MusicListViewModel.self) { resolver in
            let searchMusicUseCase = resolver.resolve(SearchMusicUseCaseProtocol.self)
            let playMusicUseCase = resolver.resolve(PlayMusicUseCaseProtocol.self)
            
            return MusicListViewModel(searchMusicUseCase: searchMusicUseCase!,
                                      playMusicUseCase: playMusicUseCase!)
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
            let tryConnectSpotifyUseCase = resolver.resolve(TryConnectSpotifyUseCaseProtocol.self)
            let signInUseCase = resolver.resolve(SignInUseCaseProtocol.self)
            
            return SignInViewModel(tryConnectSpotifyUseCase: tryConnectSpotifyUseCase!,
                                   signInUseCase: signInUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerSignUpViewModel() {
        self.container.register(SignUpViewModel.self) { resolver in
            let signUpUseCase = resolver.resolve(SignUpUseCaseProtocol.self)
            
            return SignUpViewModel(signUpUseCase: signUpUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerMeloPlaceDetailViewModel() {
        self.container.register(MeloPlaceDetailViewModel.self) { resolver in
            let playMusicUseCase = resolver.resolve(PlayMusicUseCaseProtocol.self)
            let updatePlayerStateUseCase = resolver.resolve(UpdatePlayerStateUseCaseProtocol.self)
            let observePlayerStateUseCase = resolver.resolve(ObservePlayerStateUseCaseProtocol.self)
            
            return MeloPlaceDetailViewModel(playMusicUseCase: playMusicUseCase!,
                                            updatePlayerStateUseCase: updatePlayerStateUseCase!,
                                            observePlayerStateUseCase: observePlayerStateUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerMapMeloPlaceListViewModel() {
        self.container.register(MapMeloPlaceListViewModel.self) { resolver in
            return MapMeloPlaceListViewModel()
        }
        .inObjectScope(.graph)
    }
    
    func registerAnotherUserProfileViewModel() {
        self.container.register(AnotherUserProfileViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            let fetchMeloPlaceUseCase = resolver.resolve(FetchMeloPlaceUseCaseProtocol.self)
            let updateUserUseCase = resolver.resolve(UpdateUserUseCaseProtocol.self)
            
            return AnotherUserProfileViewModel(fetchUserUseCase: fetchUserUseCase!,
                                               fetchMeloPlaceUseCase: fetchMeloPlaceUseCase!,
                                               updateUserUseCase: updateUserUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerCommentViewModel() {
        self.container.register(CommentViewModel.self) { resolver in
            let fetchCommentUseCase = resolver.resolve(FetchCommentUseCaseProtocol.self)
            let postCommentUseCase = resolver.resolve(PostCommentUseCaseProtocol.self)
            
            return CommentViewModel(fetchCommentUseCase: fetchCommentUseCase!,
                                    postCommentUseCase: postCommentUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerSearchViewModel() {
        self.container.register(SearchViewModel.self) { resolver in
            let searchLocationNameUseCase = resolver.resolve(SearchLocationNameUseCaseProtocol.self)
            
            return SearchViewModel(searchLocationNameUseCase: searchLocationNameUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerSearchUserViewModel() {
        self.container.register(SearchUserViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            
            return SearchUserViewModel(fetchUserUseCase: fetchUserUseCase!)
        }
        .inObjectScope(.graph)
    }
    
    func registerFollowingUserListViewModel() {
        self.container.register(FollowingUserListViewModel.self) { resolver in
            let fetchUserUseCase = resolver.resolve(FetchUserUseCaseProtocol.self)
            
            return FollowingUserListViewModel(fetchUserUseCase: fetchUserUseCase!)
        }
        .inObjectScope(.graph)
    }
}
