//
//  SpotifyService.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import Alamofire
import RxSwift
import RxRelay
import SpotifyiOS

enum SpotifyServiceError: Error {
    case noToken
    case noResponce
}

protocol SpotifyServiceProtocol: AnyObject {
    var responseCode: String? { get set }
    var appRemote: SPTAppRemote { get set }
    var accessToken: String? { get set }
    var isToken: PublishSubject<Bool> { get }
    var isPaused: PublishSubject<Bool> { get }
    func tryConnect()
    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) 
    func searchMusic(query: String?, type: String) -> Observable<SpotifySearchDTO>
    func fetchSpotifyUserProfile() -> Observable<SpotifyUserProfileDTO>
    func playMusic(uri: String)
    func stopPlayingMusic() 
    func didTapPauseOrPlay()
    
}

final class SpotifyService: NSObject, SpotifyServiceProtocol {
    private let urlNetworkService: URLNetworkSessionServiceProtocol
    
    let accessTokenKey = "access-token-key"
    let redirectUri = URL(string:"MeloPlace://")!
    let spotifyClientId = "d9637d39e5de4cdb818324214648b5fe"
    let spotifyClientSecretKey = "3f3aad9ff9314f15a83111f524df3479"

    /*
    Scopes let you specify exactly what types of data your application wants to
    access, and the set of scopes you pass in your call determines what access
    permissions the user is asked to grant.
    For more information, see https://developer.spotify.com/web-api/using-scopes/.
    */
    let scopes: SPTScope = [
                                .userReadEmail, .userReadPrivate,
                                .userReadPlaybackState, .userModifyPlaybackState, .userReadCurrentlyPlaying,
                                .streaming, .appRemoteControl,
                                .playlistReadCollaborative, .playlistModifyPublic, .playlistReadPrivate, .playlistModifyPrivate,
                                .userLibraryModify, .userLibraryRead,
                                .userTopRead, .userReadPlaybackState, .userReadCurrentlyPlaying,
                                .userFollowRead, .userFollowModify,
                            ]
    let stringScopes = [
                            "user-read-email", "user-read-private",
                            "user-read-playback-state", "user-modify-playback-state", "user-read-currently-playing",
                            "streaming", "app-remote-control",
                            "playlist-read-collaborative", "playlist-modify-public", "playlist-read-private", "playlist-modify-private",
                            "user-library-modify", "user-library-read",
                            "user-top-read", "user-read-playback-position", "user-read-recently-played",
                            "user-follow-read", "user-follow-modify",
                        ]
    let token = BehaviorRelay<String>(value: "")
    let isToken = PublishSubject<Bool>()
    let isSession = PublishSubject<Bool>()
    let isPaused = PublishSubject<Bool>()

    // MARK: - Spotify Authorization & Configuration
    var responseCode: String? {
        didSet {
            fetchAccessToken { (dictionary, error) in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                guard let dictionary else { return }
                let accessToken = dictionary["access_token"] as! String
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    if !accessToken.isEmpty {
//                        print("accesstoken: \(accessToken)")
                        self.token.accept(accessToken)
                        self.isToken.onNext(true)
                    } else {
                        print("accesstoken fail: \(accessToken)")
                        self.isToken.onNext(false)
                    }
                    self.appRemote.connect()
                }
            }
        }
    }

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    lazy var accessToken = UserDefaults.standard.string(forKey: self.accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: self.accessTokenKey)
        }
    }

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: self.spotifyClientId, redirectURL: self.redirectUri)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating
        // otherwise another app switch will be required
        configuration.playURI = ""
//        configuration.playURI = nil
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    var lastPlayerState: SPTAppRemotePlayerState?
    
    init(urlNetworkService: URLNetworkSessionServiceProtocol) {
        self.urlNetworkService = urlNetworkService
    }
    
    func didTapPauseOrPlay() {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }

}

// MARK: - SPTAppRemoteDelegate
extension SpotifyService: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension SpotifyService: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }
    
    func update(playerState: SPTAppRemotePlayerState) {

        lastPlayerState = playerState
        if playerState.isPaused {
            self.isPaused.onNext(true)
        } else {
            self.isPaused.onNext(false)
        }
    }
}

// MARK: - SPTSessionManagerDelegate
extension SpotifyService: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
            self.isSession.onNext(false)
        } else {
            self.isSession.onNext(false)
        }
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
        self.isSession.onNext(true)
    }
}

// MARK: - Networking
extension SpotifyService {

    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((self.spotifyClientId + ":" + self.spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]

        var requestBodyComponents = URLComponents()
        let scopeAsString = self.stringScopes.joined(separator: " ")

        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: self.spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode!),
            URLQueryItem(name: "redirect_uri", value: self.redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString),
        ]

        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                      print("Error fetching token \(error?.localizedDescription ?? "")")
                      return completion(nil, error)
                  }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
//            print("Access Token Dictionary=", responseObject ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }

    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
        
    }
}

extension SpotifyService {
    func tryConnect() {
        guard let sessionManager = sessionManager else { return }
        sessionManager.initiateSession(with: self.scopes, options: .clientOnly)
    }
    
    func playMusic(uri: String) {
        appRemote.playerAPI?.play(uri, callback: { (result, error) in
            if let error = error {
                print("Error playing track: \(error.localizedDescription)")
            } else {
                print("Track is now playing")
            }
        })
        
        appRemote.playerAPI?.seek(toPosition: 0, callback: { re, error in
            print("seek??")
        })
    }
    
    func playBackMusic() {
        appRemote.playerAPI?.seek(toPosition: 0)
    }
    
    func playMusicSeek(to position: Int) {
        appRemote.playerAPI?.seek(toPosition: position)
    }
    
    func stopPlayingMusic() {
        appRemote.playerAPI?.resume()
    }
    
    func searchMusic(query: String?, type: String) -> Observable<SpotifySearchDTO> {
        guard let query, !query.isEmpty else { return Observable.empty() }
        return self.urlNetworkService.request(SpotifyTarget
            .searchMusic(token: self.token.value, query: query, type: type))
            .asObservable()
    }
    
    func fetchSpotifyUserProfile() -> Observable<SpotifyUserProfileDTO>  {
        let token = self.token.value
        return self.urlNetworkService.request(SpotifyTarget
            .userProfile(token: token))
            .asObservable()
    }
    
    func seekMusic(to position: Int) {
        
    }
    
}

enum SpotifyTarget {
    case userProfile(token: String)
    case searchMusic(token: String, query: String, type: String)
}

extension SpotifyTarget: TargetType {
    var baseURL: String {
        return "https://api.spotify.com"
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .searchMusic, .userProfile:
            return .get
        }
    }
    
    var header: Alamofire.HTTPHeaders {
        switch self {
        case .userProfile(token: let token), .searchMusic(token: let token, _, _):
            return ["Accept":"application/json",
                    "Content-Type":"application/json",
                    "Authorization":"Bearer \(token)"]
        }
    }
    
    var path: String {
        switch self {
        case .userProfile:
            return "/v1/me"
        case .searchMusic:
            return "/v1/search"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .userProfile(_):
            return nil
        case .searchMusic(_, query: let query, type: let type):
            let body = [
                "q": query,
                "type": type
            ]
            return body
        }
    }
    
    var encoding: Alamofire.ParameterEncoding {
        return URLEncoding.default
    }
    
}
