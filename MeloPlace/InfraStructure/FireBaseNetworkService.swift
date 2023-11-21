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
    case comment(meloPlaceID: String)
    
    var path: String {
        switch self {
        case .user:
            return "users"
        case .meloPlace:
            return "meloPlace"
        case .comment:
            return "comment"
        }
    }
}

enum FirebaseFilter {
    case coordinate([FirebaseQueryDTO])
    case date([FirebaseQueryDTO])
    case isEqualTo([FirebaseQueryDTO])
    case taged([FirebaseQueryDTO])
    case anotherUser([FirebaseQueryDTO])
    case `in`([FirebaseQueryDTO])
}

struct FirebaseQueryDTO {
    var key: String
    var value: Any
}

protocol FireBaseNetworkServiceProtocol {
    var uid: BehaviorRelay<String?> { get }
    func determineUserID(id: String?) throws -> String
    func signIn(email: String, password: String) -> Single<Bool>
    func signOut() -> Single<Bool>
    func signUp(userDTO: UserDTO) -> Single<Bool>
    func fetchUserInfor(withSpotifyID id: String) -> Observable<UserDTO?>
    
    func create<T: DTOProtocol>(dto: T, access: Access) -> Single<T>
    func read<T: DTOProtocol>(type: T.Type, access: Access, firebaseFilter: FirebaseFilter) -> Observable<T>
    func update<T: DTOProtocol>(dto:T, access: Access) -> Single<T>
    func delete<T: DTOProtocol>(dto: T, access: Access) -> Single<T>
    func readForPagination<T: DTOProtocol>(type: T.Type, access: Access, firebaseFilter: FirebaseFilter) -> Observable<T>
    func initMeloPlaceLastSnapshot()
    func initCommentLastSnapshot()
    
    func uploadDataStorage(data: Data, path: StoragePath) -> Single<String>
    func downloadDataStorage(fileName: String) -> Single<Data>
}

class FireBaseNetworkService: FireBaseNetworkServiceProtocol {
    static let shared = FireBaseNetworkService()
    var db: Firestore
    var auth: Auth
    private var storage: Storage
    var uid: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    var userLastSnapshot: QueryDocumentSnapshot?
    var meloPlaceLastSnapshot: QueryDocumentSnapshot?
    var commentLastSnapshot: QueryDocumentSnapshot?
    
    init() {
        self.db = Firestore.firestore()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.uid.accept(auth.currentUser?.uid)
    }
    
    func determineUserID(id: String?) throws -> String {
        if let id { return id }
        guard let id = self.uid.value else { throw NetworkServiceError.noAuthError }
        
        return id
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
    
    func signUp(userDTO: UserDTO) -> Single<Bool> {
        return Single<Bool>.create { [weak self] single in
            guard let self = self else {
                single(.failure(NetworkServiceError.noNetworkService))
                return Disposables.create()
            }
            let email = userDTO.email.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = userDTO.password.trimmingCharacters(in: .whitespacesAndNewlines)
            self.auth.createUser(withEmail: email, password: password) { result, error in
                do {
                    if let error = error { throw error }
                    guard let authResult = result else { throw NetworkServiceError.noAuthError }
                    try self.createUser(uuid: authResult.user.uid, userDTO: userDTO)
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

    private func createUser(uuid: String, userDTO: UserDTO) throws {
        let userDto = UserDTO(id: uuid,
                              spotifyID: userDTO.spotifyID,
                              name: userDTO.name,
                              email: userDTO.email,
                              password: userDTO.password,
                              imageURL: userDTO.imageURL,
                              imageWidth: userDTO.imageWidth,
                              imageHeight: userDTO.imageHeight,
                              follower: userDTO.follower,
                              following: userDTO.following)
        try db.collection(Access.user.path).document(uuid)
            .setData(from: userDto)
    }
    
    func fetchUserInfor(withSpotifyID id: String) -> Observable<UserDTO?> {
        return Observable.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            
            self.db.collection(Access.user.path)
                .whereField("spotifyID", isEqualTo: id)
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
    private func makeQuery(collection: CollectionReference, filter: FirebaseFilter? = nil) throws -> Query {
        var query: Query
        
        if let filter = filter {
            switch filter {
            case .coordinate(let queryDTO):
                let westLat = queryDTO[0]
                let eastLat = queryDTO[1]
                let userID = queryDTO[2]
                guard let userIDs = queryDTO[2].value as? [String]
                else { throw NetworkServiceError.needFilterError }
                
                query = collection
                    .whereField(westLat.key, isGreaterThan: westLat.value)
                    .whereField(eastLat.key, isLessThan: eastLat.value)
                    .whereField(userID.key, in: userIDs)
                
                return query
            case .date(let date):
                guard
                    let date = date.first,
                    let value = date.value as? Bool
                else { throw NetworkServiceError.needFilterError }
                query = collection
                    .order(by: date.key, descending: value)
                
                return query
            case .isEqualTo(let data):
                guard let firstFilter = data.first
                else { throw NetworkServiceError.needFilterError }
                query = collection
                    .whereField(firstFilter.key, isEqualTo: firstFilter.value)
                
                return query
            case .taged(let data):
                guard let data = data.first,
                      let values = data.value as? [String],
                      !values.isEmpty
                else { throw NetworkServiceError.needFilterError }
                query = collection
                    .whereField(data.key, arrayContains: data.value)
                
                return query
            case .anotherUser(let data):
                guard let data = data.first,
                      let value = data.value as? String,
                      value != ""
                else { throw NetworkServiceError.needFilterError }
                let startValue = "\(value)"
                let endValue = "\(value)\u{f8ff}"
                query = collection
                    .whereField(data.key, isGreaterThanOrEqualTo: startValue)
                    .whereField(data.key, isLessThanOrEqualTo: endValue)
                
                return query
            case .in(let data):
                guard let data = data.first,
                      let values = data.value as? [Any],
                      !values.isEmpty
                else { throw NetworkServiceError.needFilterError }
                query =
                collection.whereField(data.key, in: values)
                
                return query
            }
        } else {
            query = collection
            return query
        }
    }
    
    private func makePaginateQuery(
        collection: CollectionReference,
        filter: FirebaseFilter,
        lastSnapShot: QueryDocumentSnapshot?) throws -> Query {
            var query: Query
                switch filter {
                case .date(let datas):
                    guard
                        let date = datas.first,
                        let value = date.value as? Bool
                    else { throw NetworkServiceError.needFilterError }
                    if let lastSnapShot {
                        query = collection
                            .order(by: date.key, descending: value)
                            .limit(to: 20)
                            .start(afterDocument: lastSnapShot)
                        
                        return query
                    } else {
                        query = collection
                            .order(by: date.key, descending: value)
                            .limit(to: 20)
                        
                        return query
                    }
                    
                case .coordinate(_):
                    break
                case .isEqualTo(_):
                    break
                case .taged(_):
                    break
                case .anotherUser(_):
                    break
                case .in(let data):
                    guard let data = data.first,
                          let values = data.value as? [Any],
                          !values.isEmpty
                    else { throw NetworkServiceError.needFilterError }
                    
                    query = collection.whereField(data.key, in: values)
                    
                    return query
                }
            
            query = collection
            
            return query
        }
    
    
    @discardableResult
    private func collectionReference(access: Access) throws -> CollectionReference {
        switch access {
        case .user:
            return self.db.collection(access.path)
        case .meloPlace:
            return self.db.collection(access.path)
        case .comment(let meloPlaceID):
            return self.db.collection(Access.meloPlace.path).document(meloPlaceID).collection(access.path)
        }
    }
    
    func create<T: DTOProtocol>(dto: T, access: Access) -> Single<T> {
        return Single<T>.create { [weak self] single in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                let ref = try self.collectionReference(access: access)
                switch access {
                case .user:
                    try ref
                        .document(dto.id)
                        .setData(from: dto)
                case .meloPlace:
                    try ref
                        .document(dto.id)
                        .setData(from: dto)
                case .comment(_):
                    try ref
                        .document(dto.id)
                        .setData(from: dto)
                }
                single(.success(dto))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    func read<T: DTOProtocol>(type: T.Type, access: Access, firebaseFilter: FirebaseFilter) -> Observable<T> {
        return Observable<T>.create { [weak self] observer in
            do {
                guard let self = self
                else { throw NetworkServiceError.noNetworkService }
                
                let ref = try self.collectionReference(access: access)
                
                switch access {
                case .user:
                    let query = try self.makeQuery(collection: ref, filter: firebaseFilter)
                    query.getDocuments { snapshot, error in
                        guard let snapshot else { return }
                        for document in snapshot.documents {
                            do {
                                let user = try document.data(as: type)
                                observer.onNext(user)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                case .meloPlace:
                    let query = try self.makeQuery(collection: ref, filter: firebaseFilter)
                    
                    query.getDocuments { snapshot, error in
                        guard let snapshot
                        else { return }
                        for document in snapshot.documents {
                            do {
                                let meloPlace = try document.data(as: type)
                                observer.onNext(meloPlace)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                case .comment(_):
                    let query =
                    try self.makeQuery(collection: ref, filter: firebaseFilter)
                    
                    query.getDocuments { snapshot, error in
                        if let error = error { return }
                        guard let snapshot
                        else { return }
                        
                        for document in snapshot.documents {
                            do {
                                let comment = try document.data(as: type)
                                observer.onNext(comment)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                    
                }
            } catch let error {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func update<T: DTOProtocol>(dto:T, access: Access) -> Single<T> {
        return Single<T>.create { [weak self] single in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                let ref = try self.collectionReference(access: access)
                switch access {
                case .user:
                    try ref
                        .document(dto.id)
                        .setData(from: dto, merge: true)
                case .meloPlace:
                    try ref
                        .document(dto.id)
                        .setData(from: dto, merge: true)
                case .comment(_):
                    try ref
                        .document(dto.id)
                        .setData(from: dto, merge: true)
                }
                single(.success(dto))
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
    
    /// Delete
    /// - Parameters:
    ///   - userCase: current User / another User
    ///   - access: quests / receiveQuests / userInfo
    ///   - dto: DTO (Codable)
    /// - Returns: Single<T>
    func delete<T: DTOProtocol>(dto: T, access: Access) -> Single<T> {
        return Single<T>.create { [weak self] single in
            do {
                guard let self = self else { throw NetworkServiceError.noNetworkService }
                let ref = try self.collectionReference(access: access)
                switch access {
                case .user:
                    ref.document(dto.id)
                        .delete(completion: { error in
                            if let error {
                                single(.failure(error))
                            } else {
                                single(.success(dto))
                            }
                        })
                case .meloPlace:
                    ref.document(dto.id)
                        .delete(completion: { error in
                            if let error {
                                single(.failure(error))
                            } else {
                                single(.success(dto))
                            }
                        })
                case .comment(_):
                    ref.document(dto.id)
                        .delete(completion: { error in
                            if let error {
                                single(.failure(error))
                            } else {
                                single(.success(dto))
                            }
                        })
                }
            } catch let error {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    func readForPagination<T: DTOProtocol>(type: T.Type, access: Access, firebaseFilter: FirebaseFilter) -> Observable<T> {
        return Observable<T>.create { [weak self] observer in
            do {
                guard let self = self
                else { throw NetworkServiceError.noNetworkService }
                
                let ref = try self.collectionReference(access: access)
                
                switch access {
                case .user:
                    let query = try self.makePaginateQuery(collection: ref, filter: firebaseFilter, lastSnapShot: self.meloPlaceLastSnapshot)
                    query.getDocuments { snapshot, error in
                        guard let snapshot else { return }
                        self.userLastSnapshot = snapshot.documents.last
                        for document in snapshot.documents {
                            do {
                                let user = try document.data(as: type)
                                print(user)
                                observer.onNext(user)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                case .meloPlace:
                    let query = try self.makePaginateQuery(collection: ref, filter: firebaseFilter, lastSnapShot: self.meloPlaceLastSnapshot)
                    
                    query.addSnapshotListener { snapshot, error in
                        guard let snapshot
                        else {
                            observer.onError(error!)
                            return  }
                        self.meloPlaceLastSnapshot = snapshot.documents.last
                        for document in snapshot.documents {
                            do {
                                let meloPlace = try document.data(as: type)
                                observer.onNext(meloPlace)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                case .comment(_):
                    let query = try self.makePaginateQuery(collection: ref, filter: firebaseFilter, lastSnapShot: self.commentLastSnapshot)
                    
                    query.addSnapshotListener { snapshot, error in
                        guard let snapshot else { return }
                    self.commentLastSnapshot = snapshot.documents.last
                        for document in snapshot.documents {
                            do {
                                let comment = try document.data(as: type)
                                observer.onNext(comment)
                            } catch let error {
                                observer.onError(error)
                            }
                        }
                        observer.onCompleted()
                    }
                    
                }
            } catch let error {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func initMeloPlaceLastSnapshot() {
        self.meloPlaceLastSnapshot = nil
    }
    
    func initCommentLastSnapshot() {
        self.commentLastSnapshot = nil
    }
    
    func initUserLastSnapshot() {
        self.userLastSnapshot = nil
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
