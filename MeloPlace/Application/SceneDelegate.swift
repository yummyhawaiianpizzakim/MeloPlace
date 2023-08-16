//
//  SceneDelegate.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import UIKit
import SpotifyiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    lazy var rootViewController = SpotifyViewController()
    var spotifyService = SpotifyService.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.backgroundColor = .systemBackground
        let navigationController = UINavigationController()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        appCoordinator = AppCoordinator(navigation: navigationController)
        appCoordinator?.start()
        
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window!.makeKeyAndVisible()
//        window!.windowScene = windowScene
//        window!.rootViewController = rootViewController
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
//        let parameters = rootViewController.appRemote.authorizationParameters(from: url)
//        if let code = parameters?["code"] {
//            rootViewController.responseCode = code
//        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//            rootViewController.accessToken = access_token
//        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
//            print("No access token error =", error_description)
//        }
        
        let parameters = spotifyService.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            spotifyService.responseCode = code
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            spotifyService.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//        if let accessToken = rootViewController.appRemote.connectionParameters.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        } else if let accessToken = rootViewController.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
//        }
        
        if let accessToken = spotifyService.appRemote.connectionParameters.accessToken {
            spotifyService.appRemote.connectionParameters.accessToken = accessToken
            spotifyService.appRemote.connect()
        } else if let accessToken = spotifyService.accessToken {
            spotifyService.appRemote.connectionParameters.accessToken = accessToken
            spotifyService.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
//        if rootViewController.appRemote.isConnected {
//            rootViewController.appRemote.disconnect()
//        }
        
        if spotifyService.appRemote.isConnected {
            spotifyService.appRemote.disconnect()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

