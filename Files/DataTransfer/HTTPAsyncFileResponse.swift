//
//  HTTPAsyncFileResponse.swift
//  Files
//
//  Created by 翟泉 on 2019/9/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import CocoaHTTPServer

class HTTPAsyncFileResponse: CocoaHTTPServer.HTTPAsyncFileResponse {
    override func httpHeaders() -> [AnyHashable : Any]! {
        return ["Access-Control-Allow-Origin": "*"]
    }
}

