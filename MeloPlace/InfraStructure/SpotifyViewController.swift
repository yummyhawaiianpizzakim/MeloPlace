////
////  SpotifyViewController.swift
////  MeloPlace
////
////  Created by 김요한 on 2023/08/10.
////
//
//import Foundation
//import UIKit
//import RxSwift
//import Alamofire
//import SpotifyiOS
//
//class SpotifyViewController: UIViewController {
//    let spotify = Spotify()
//    let service = SpotifyService()
//
//    var aaa = ""
//
//    // MARK: - Spotify Authorization & Configuration
//    var responseCode: String? {
//        didSet {
//            fetchAccessToken { (dictionary, error) in
//                if let error = error {
//                    print("Fetching token request error \(error)")
//                    return
//                }
//                let accessToken = dictionary!["access_token"] as! String
//                DispatchQueue.main.async {
//                    self.appRemote.connectionParameters.accessToken = accessToken
//                    self.aaa = accessToken
//                    self.appRemote.connect()
//                }
//            }
//        }
//    }
//
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
//        appRemote.connectionParameters.accessToken = self.accessToken
//        appRemote.delegate = self
//        return appRemote
//    }()
//
//    lazy var accessToken = UserDefaults.standard.string(forKey: self.spotify.accessTokenKey) {
//        didSet {
//            let defaults = UserDefaults.standard
//            defaults.set(accessToken, forKey: self.spotify.accessTokenKey)
//        }
//    }
//
//    lazy var configuration: SPTConfiguration = {
//        let configuration = SPTConfiguration(clientID: self.spotify.spotifyClientId, redirectURL: self.spotify.redirectUri)
//        // Set the playURI to a non-nil value so that Spotify plays music after authenticating
//        // otherwise another app switch will be required
//        configuration.playURI = ""
//        // Set these url's to your backend which contains the secret to exchange for an access token
//        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
//        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
//        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
//        return configuration
//    }()
//
//    lazy var sessionManager: SPTSessionManager? = {
//        let manager = SPTSessionManager(configuration: configuration, delegate: self)
//        return manager
//    }()
//
//    private var lastPlayerState: SPTAppRemotePlayerState?
//
//    // MARK: - Subviews
//    let stackView = UIStackView()
//    let connectLabel = UILabel()
//    let connectButton = UIButton(type: .system)
//    let imageView = UIImageView()
//    let trackLabel = UILabel()
//    let playPauseButton = UIButton(type: .system)
//    let signOutButton = UIButton(type: .system)
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: App Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        style()
//        layout()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        updateViewBasedOnConnected()
//    }
//
//    func update(playerState: SPTAppRemotePlayerState) {
//        if lastPlayerState?.track.uri != playerState.track.uri {
//            fetchArtwork(for: playerState.track)
//        }
//        lastPlayerState = playerState
//        trackLabel.text = playerState.track.name
//
//        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
//        if playerState.isPaused {
//            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: configuration), for: .normal)
//        } else {
//            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: configuration), for: .normal)
//        }
//    }
//
//    // MARK: - Actions
//    @objc func didTapPauseOrPlay(_ button: UIButton) {
//        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
//            appRemote.playerAPI?.resume(nil)
//        } else {
//            appRemote.playerAPI?.pause(nil)
//        }
//    }
//
//    @objc func didTapSignOut(_ button: UIButton) {
//        if appRemote.isConnected == true {
//            appRemote.disconnect()
//        }
//    }
//
//    @objc func didTapConnect(_ button: UIButton) {
//        guard let sessionManager = sessionManager else { return }
//        sessionManager.initiateSession(with: self.spotify.scopes, options: .clientOnly)
//    }
//
//    // MARK: - Private Helpers
//    private func presentAlertController(title: String, message: String, buttonTitle: String) {
//        DispatchQueue.main.async {
//            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
//            controller.addAction(action)
//            self.present(controller, animated: true)
//        }
//    }
//}
//
//// MARK: Style & Layout
//extension SpotifyViewController {
//    func style() {
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .vertical
//        stackView.spacing = 20
//        stackView.alignment = .center
//
//        connectLabel.translatesAutoresizingMaskIntoConstraints = false
//        connectLabel.text = "Connect your Spotify account"
//        connectLabel.font = UIFont.preferredFont(forTextStyle: .title3)
//        connectLabel.textColor = .systemGreen
//
//        connectButton.translatesAutoresizingMaskIntoConstraints = false
//        connectButton.configuration = .filled()
//        connectButton.setTitle("Continue with Spotify", for: [])
//        connectButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
//        connectButton.addTarget(self, action: #selector(didTapConnect), for: .primaryActionTriggered)
//
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
//
//        trackLabel.translatesAutoresizingMaskIntoConstraints = false
//        trackLabel.font = UIFont.preferredFont(forTextStyle: .body)
//        trackLabel.textAlignment = .center
//
//        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
//        playPauseButton.addTarget(self, action: #selector(didTapPauseOrPlay), for: .primaryActionTriggered)
//
//        signOutButton.translatesAutoresizingMaskIntoConstraints = false
//        signOutButton.setTitle("Sign out", for: .normal)
//        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        signOutButton.addTarget(self, action: #selector(didTapSignOut(_:)), for: .touchUpInside)
//    }
//
//    func layout() {
//
//        stackView.addArrangedSubview(connectLabel)
//        stackView.addArrangedSubview(connectButton)
//        stackView.addArrangedSubview(imageView)
//        stackView.addArrangedSubview(trackLabel)
//        stackView.addArrangedSubview(playPauseButton)
//        stackView.addArrangedSubview(signOutButton)
//
//        view.addSubview(stackView)
//
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
//    }
//
//    func updateViewBasedOnConnected() {
//        if appRemote.isConnected == true {
//            connectButton.isHidden = true
//            signOutButton.isHidden = false
//            connectLabel.isHidden = true
//            imageView.isHidden = false
//            trackLabel.isHidden = false
//            playPauseButton.isHidden = false
//        }
//        else { // show login
//            signOutButton.isHidden = true
//            connectButton.isHidden = false
//            connectLabel.isHidden = false
//            imageView.isHidden = true
//            trackLabel.isHidden = true
//            playPauseButton.isHidden = true
//        }
//    }
//}
//
//// MARK: - SPTAppRemoteDelegate
//extension SpotifyViewController: SPTAppRemoteDelegate {
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        updateViewBasedOnConnected()
//        appRemote.playerAPI?.delegate = self
//        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//            if let error = error {
//                print("Error subscribing to player state:" + error.localizedDescription)
//            }
//        })
//        fetchPlayerState()
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        updateViewBasedOnConnected()
//        lastPlayerState = nil
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        updateViewBasedOnConnected()
//        lastPlayerState = nil
//    }
//}
//
//// MARK: - SPTAppRemotePlayerAPIDelegate
//extension SpotifyViewController: SPTAppRemotePlayerStateDelegate {
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        debugPrint("Spotify Track name: %@", playerState.track.name)
//        update(playerState: playerState)
//    }
//}
//
//// MARK: - SPTSessionManagerDelegate
//extension SpotifyViewController: SPTSessionManagerDelegate {
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
//            print("AUTHENTICATE with WEBAPI")
//        } else {
//            presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
//        }
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
//    }
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        self.aaa = session.accessToken
//        appRemote.connectionParameters.accessToken = session.accessToken
//        appRemote.connect()
//    }
//}
//
//// MARK: - Networking
//extension SpotifyViewController {
//
//    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
//        let url = URL(string: "https://accounts.spotify.com/api/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let spotifyAuthKey = "Basic \((self.spotify.spotifyClientId + ":" + self.spotify.spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
//        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
//                                       "Content-Type": "application/x-www-form-urlencoded"]
//
//        var requestBodyComponents = URLComponents()
//        let scopeAsString = self.spotify.stringScopes.joined(separator: " ")
//
//        requestBodyComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: self.spotify.spotifyClientId),
//            URLQueryItem(name: "grant_type", value: "authorization_code"),
//            URLQueryItem(name: "code", value: responseCode!),
//            URLQueryItem(name: "redirect_uri", value: self.spotify.redirectUri.absoluteString),
//            URLQueryItem(name: "code_verifier", value: ""), // not currently used
//            URLQueryItem(name: "scope", value: scopeAsString),
//        ]
//
//        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,                              // is there data
//                  let response = response as? HTTPURLResponse,  // is there HTTP response
//                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
//                  error == nil else {                           // was there no error, otherwise ...
//                      print("Error fetching token \(error?.localizedDescription ?? "")")
//                      return completion(nil, error)
//                  }
//            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
//            print("Access Token Dictionary=", responseObject ?? "")
//            completion(responseObject, nil)
//        }
//        task.resume()
//    }
//
//    func fetchArtwork(for track: SPTAppRemoteTrack) {
//        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
//            if let error = error {
//                print("Error fetching track image: " + error.localizedDescription)
//            } else if let image = image as? UIImage {
//                self?.imageView.image = image
//            }
//        })
//    }
//
//    func fetchPlayerState() {
//        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
//            if let error = error {
//                print("Error getting player state:" + error.localizedDescription)
//            } else if let playerState = playerState as? SPTAppRemotePlayerState {
//                self?.update(playerState: playerState)
//            }
//        })
//
//    }
//
//    func searchMusic(query: String, type: String) -> Observable<SpotifySearchDTO> {
//        let baseURLString = "https://api.spotify.com/v1"
//        let searchRequestURLString = "/search"
//        var accessTokenString = ""
//        let headers: HTTPHeaders = ["Accept":"application/json",
//                                    "Content-Type":"application/json",
//                                    "Authorization":"Bearer \(self.aaa)"]
//        print(self.aaa)
//        let parameters = [
//            "q": query,
//            "type": type
//        ]
//
//        let url = baseURLString + searchRequestURLString
//
//        return Observable.create {[weak self] observer in
//            AF.request(url,
//                       method: .get,
//                       parameters: parameters,
//                       headers: headers
//            )
//            .validate()
//            .responseDecodable(of: SpotifySearchDTO.self) { response in
//                switch response.result {
//                case .success(let dto):
//                    print("dto: \(dto)")
//                    return observer.onNext(dto)
//                case .failure(let error):
//                    print("dto: \(error)")
//                    return observer.onError(error)
//                }
//            }
//
//            return Disposables.create()
//        }
//
//    }
//}
