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
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            guard let weakself = self else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            if weakself.play() {
                return MPRemoteCommandHandlerStatus.success
            }
            else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
        }
        MPRemoteCommandCenter.shared().stopCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            self?.stop()
            return MPRemoteCommandHandlerStatus.success
        }

        // MARK: Previous/Next
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
//            self?.next()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
//            self?.previous()
            return MPRemoteCommandHandlerStatus.success
        }
    }
}
