//
//  MediaPlayerUtils.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import MobileCoreServices

extension MediaPlayerView {
    static func MIMEType(with file: URL) -> String? {
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, file.pathExtension as CFString, nil) else { return nil }
        let MIMEType = UTTypeCopyPreferredTagWithClass(UTI as! CFString, kUTTagClassMIMEType)
        return MIMEType?.takeUnretainedValue() as String?
    }
}
