//
//  Music.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import AVFoundation

class Music {
    let url: URL
    private(set) lazy var metadata: Metadata = Metadata(url: url)

    init(url: URL) {
        self.url = url
    }
}

extension Music {
    struct Metadata {
        let url: URL
        let duration: Double
        let song: String
        let singer: String
        let albumName: String
        let artwork: UIImage?

        init(url: URL) {
            self.url = url
            let asset = AVURLAsset(url: url)
            var song: String?
            var singer: String?
            var albumName: String?
            var artwork: UIImage?
            asset.availableMetadataFormats.forEach { (format) in
                asset.metadata(forFormat: format).forEach({ (metadataItem) in
                    if metadataItem.commonKey == .commonKeyTitle {
                        song = metadataItem.value as? String
                    }  else if metadataItem.commonKey == .commonKeyArtist {
                        singer = metadataItem.value as? String
                    } else if metadataItem.commonKey == .commonKeyAlbumName {
                        albumName = metadataItem.value as? String
                    } else if metadataItem.commonKey == .commonKeyArtwork {
                        if let data = metadataItem.value as? Data {
                            artwork = UIImage(data: data)
                        }
                    }
                })
            }

            duration = TimeInterval(asset.duration.value) / TimeInterval(asset.duration.timescale)
            self.song = song ?? url.deletingPathExtension().lastPathComponent
            self.singer = singer ?? "未知"
            self.albumName = albumName ?? "未知"
            self.artwork = artwork
        }
    }
}

extension Music: Equatable {
    static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.url == rhs.url
    }
}

extension Music {
    static func artwork(for url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        guard TimeInterval(asset.duration.value) / TimeInterval(asset.duration.timescale) > 0 else { return nil }
        for format in asset.availableMetadataFormats {
            for metadataItem in asset.metadata(forFormat: format) {
                if metadataItem.commonKey == .commonKeyArtwork {
                    if let data = metadataItem.value as? Data {
                        return UIImage(data: data)
                    }
                }
            }
        }
        return nil
    }
}
