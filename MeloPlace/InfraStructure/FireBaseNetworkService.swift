//
//  FireBaseNetworkService.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import RxSwift
import RxRelay

enum NetworkServiceError: Error {
    case noNetworkService // NetworkService X
    case noAuthError // uid X
    case permissionDenied // wrong access
    case needFilterError
    case noUrlError
    case noDataError
}

enum UserCase {
    case currentUser
    case anotherUser(_ uid: String)

    var path: String {
        return "users"
    }
}

enum StoragePath {
    case profileImages
    case backgroundImages
    case meloPlaceImages
    case another(_ path: String)

    var path: String {
        switch self {
        case .profileImages:
            return "profileImages"
        case .backgroundImages:
            return "backgroundImages"
        case .meloPlaceImages:
            return "meloPlaceImages"
        case .another(let path):
            return path
        }
    }
}

enum CRUD {
    case create
    case read
    case update
    case delete
}

enum Access {
    case user
    case meloPlace
    
    var path: String {
        switch self {
        case .user:
            return "users"
        case .meloPlace:
            return "meloPlace"
        }
    }
}

protocol FireBaseNetworkServiceProtocol {
    func signIn(email: String, password: String) -> Single<Bool>
    func signOut() -> Single<Bool>
    func signUp(email: String, password: String, spotifyID: String, userDTO: UserDTO) -> Single<Bool>
    func fetchUserInforWithSpotifyID(spotifyID: String) -> Observable<UserDTO?>
    func create<T: DTOProtocol>(dto: T, userCase: UserCase, access: Access) -> Single<T>
    func read<T: DTOProtocol>(type: T.Type, userCase: UserCase, access: Access) -> Observable<T>
}

class FireBaseNetworkService: FireBaseNetworkServiceProtocol {
    static let shared = FireBaseNetworkService()
    var db: Firestore
    var auth: Auth
    private var storage: Storage
    private(set) var uid: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.uid.accept(auth.currentUser?.uid)
    }
    
}

extension FireBaseNetworkService {
    func signIn(email: String, password: String) -> Single<Bool> {
        return Single.create { [weak self] single in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                self.auth.signIn(withEmail: email, password: password) { (authResult, error) in
                    if let error = error {
                        single(.failure(error))
                    }
                    
                    self.uid.accept(self.auth.currentUser?.uid)
//                    print("currentuser uid: \(self.auth.currentUser?.uid)")
                    single(.success(true))
                }
            } catch let error {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func signOut() -> Single<Bool> {
        return Single<Bool>.create { single in
            do {
                try self.auth.signOut()
                self.uid.accept(nil)
                single(.success(true))
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
                single(.failure(signOutError))
            }
            
            return Disposables.create()
        }
        
    }
    
    func signUp(email: String, password: String, spotifyID: String, userDTO: UserDTO) -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard let self = self else {
                single(.failure(NetworkServiceError.noNetworkService))
                return Disposables.create()
            }
            let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
            self.auth.createUser(withEmail: email, password: password) { result, error in
                do {
                    if let error = error { throw error }
                    guard let authResult = result else { throw NetworkServiceError.noAuthError }
                    try self.createUser(uuid: authResult.user.uid, email: email, password: password, spotifyID: spotifyID, userDTO: userDTO)
                    self.uid.accept(self.auth.currentUser?.uid)
                    single(.success(true))
    //                print("net signUp")
                } catch let error {
                    single(.failure(error))
    //                print("net signUp error")
                }
            }
            
            return Disposables.create()
        }

    }

    private func createUser(uuid: String, email: String, password: String, spotifyID: String, userDTO: UserDTO) throws {
        let userDto = UserDTO(id: uuid, email: email, password: password, spotifyID: spotifyID, userDTO: userDTO)
        try db.collection(UserCase.currentUser.path).document(uuid)
            .setData(from: userDto)
    }
    
    func fetchUserInforWithSpotifyID(spotifyID: String) -> Observable<UserDTO?> {
        return Observable.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            
            self.db.collection(Access.user.path)
                .whereField("spotifyID", isEqualTo: spotifyID)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    
                    if let snapshot = querySnapshot?.documents.first {
                        do {
                            let dto = try snapshot.data(as: UserDTO.self)
                            observer.onNext(dto)
                        } catch {
                            observer.onError(error)
                        }
                    } else {
                        observer.onNext(nil)
                    }
                }
            
            return Disposables.create()
        }
    }
    
}

extension FireBaseNetworkService {
    @discardableResult
    private func documentReference(userCase: UserCase) throws -> DocumentReference {
        switch userCase {
        case .currentUser:
            guard let currentUserUid = uid.value else { throw NetworkServiceError.noAuthError }
            return db.collection(userCase.path).document(currentUserUid)
        case let .anotherUser(uid):
            return db.collection(userCase.path).document(uid)
        }
    }
    
    func create<T: DTOProtocol>(dto: T, userCase: UserCase, access: Access) -> Single<T> {
        return Single<T>.create { [weak self] single in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                let ref = try self.documentReference(userCase: userCase)
                switch access {
                case .user:
                    try ref
                        .setData(from: dto)
                case .meloPlace:
                    try ref.collection(access.path)
                        .document("\(dto.id)")
                        .setData(from: dto)
                }
                single(.success(dto))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func read<T: DTOProtocol>(type: T.Type, userCase: UserCase, access: Access) -> Observable<T> {
        return Observable<T>.create { [weak self] obserser in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                let ref = try self.documentReference(userCase: userCase)
                switch access {
                case .user:
                    ref.getDocument(as: type) { result in
                        switch result {
                        case .success(let user):
//                            print("onNext \(user)")
//                            print("read user success")
                            obserser.onNext(user)
                        case .failure(let error):
//                            print("onError \(error)")
//                            print("read user error")
                            obserser.onError(error)
                        }
                        obserser.onCompleted()
                        
                    }
                case .meloPlace:
                    ref.collection(access.path).getDocuments { snapshot, error in
                        guard let snapshot = snapshot else { return }
                        for document in snapshot.documents {
                            do {
                                let data = try document.data(as: type)
//                                print(data)
                                obserser.onNext(data)
                                
                            } catch let error {
                                obserser.onError(error)
                            }
                        }
                        obserser.onCompleted()
                    }
//                    obserser.onCompleted()
                }
                
            } catch let error {
                obserser.onError(error)
            }
//            obserser.onCompleted()
            
            return Disposables.create()
        }
    }
}

extension FireBaseNetworkService {
    /// uploadDataStorage
        /// - Parameters:
        ///   - data: Image Data
        ///   - path: profileImages / backgroundImages / another(_ path: String)
        /// - Returns: success -> File Name, failure -> error
        func uploadDataStorage(data: Data, path: StoragePath) -> Single<String> {
            return Single<String>.create { [weak self] single in
                do {
                    guard let self = self else { throw NetworkServiceError.noNetworkService }
                    guard let uid = self.uid.value else { throw NetworkServiceError.noAuthError }
                    let fileName = "\(path.path)/\(uid)-\(UUID())"
                    let StorageReference = self.storage.reference().child("\(fileName)")
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    StorageReference.putData(data, metadata: metaData) { metaData, error in
                        if let error = error {
                            single(.failure(error))
                            return
                        }
                        StorageReference.downloadURL { (url, error) in
                            guard let downloadUrl = url else {
                                single(.failure(NetworkServiceError.noUrlError))
                                return
                            }
                            single(.success(downloadUrl.absoluteString))
                        }
                    }
                } catch let error {
                    single(.failure(error))
                }
                
                return Disposables.create()
            }
        }
        
        /// downloadDataStorage
        /// - Parameter fileName: File Name
        /// - Returns: success -> Image Data, failure -> error
        func downloadDataStorage(fileName: String) -> Single<Data> {
            return Single<Data>.create { [weak self] single in
                do {
                    guard let self = self else { throw NetworkServiceError.noNetworkService }
                    
                    let storageReference = self.storage.reference().child(fileName)
                    let megaByte = Int64(1 * 1024 * 1024)
                    
                    storageReference.getData(maxSize: megaByte) { data, error in
                        guard let imageData = data else {
                            single(.failure(NetworkServiceError.noDataError))
                            return
                        }
                        single(.success(imageData))
                    }
                } catch let error {
                    single(.failure(error))
                }
                
                return Disposables.create()
            }
        }
}
