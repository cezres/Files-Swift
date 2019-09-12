//
//  MusicPlayer+RemoteComtrol.swift
//  Files
//
//  Created by 翟泉 on 2019/4/24.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import MediaPlayer

extension MusicPlayer {
    func configRemoteComtrol() {
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            MusicPlayer.shared.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            do {
                try MusicPlayer.shared.resume()
                return .success
            } catch {
                return .commandFailed
            }
        }
        MPRemoteCommandCenter.shared().stopCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            MusicPlayer.shared.stop()
            return MPRemoteCommandHandlerStatus.success
        }

        /// Previous/Next
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            do {
                try MusicPlayer.shared.next()
                return .success
            } catch {
                return .commandFailed
            }
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            do {
                try MusicPlayer.shared.previous()
                return .success
            } catch {
                return .commandFailed
            }
        }
    }
}
