//
//  Spotify.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/10.
//

import Foundation

class Spotify {
    
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
}
