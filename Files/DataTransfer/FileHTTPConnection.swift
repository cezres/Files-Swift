//
//  FileHTTPConnection.swift
//  Files
//
//  Created by 翟泉 on 2019/9/15.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import CocoaHTTPServer

class FileHTTPConnection: HTTPConnection {
    override func expectsRequestBody(fromMethod method: String!, atPath path: String!) -> Bool {
        return super.expectsRequestBody(fromMethod: method, atPath: path)
    }

    override func supportsMethod(_ method: String!, atPath path: String!) -> Bool {
        return super.supportsMethod(method, atPath: path)
    }

    override func httpResponse(forMethod method: String!, uri path: String!) -> (CocoaHTTPServer.HTTPResponse & NSObjectProtocol)! {
        if method == "GET" {
            if path.hasPrefix("/document/files") {
                let parameters = path.urlParametersDecode
                let directory = DocumentDirectory.appendingPathComponent(parameters["directory"] ?? "")
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
                    let dict = contents.map({ File(url: directory.appendingPathComponent($0)) }).map { (file) -> [String: Any] in
                        return [
                            "path": file.relativePath,
                            "icon": "/document/icon?path=\(file.relativePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)",
                            "type": file.type.name,
                            "name": file.name,
                            "size": file.attributes.size ?? "",
                            "modificationDate": file.attributes.modificationDate?.timeIntervalSince1970 ?? ""
                        ]
                    }
                    let json = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    return HTTPDataResponse(data: String(data: json, encoding: .utf8)?.data(using: .unicode))
                } catch {
                    return HTTPDataResponse(data: error.localizedDescription.data(using: .utf8))
                }
            } else if path.hasPrefix("/document/icon") {
                let parameters = path.urlParametersDecode
                let filePath = DocumentDirectory.appendingPathComponent(parameters["path"] ?? "/")
                let semaphore = DispatchSemaphore(value: 0)
                var image: UIImage?
                File(url: URL(fileURLWithPath: filePath.path.removingPercentEncoding!)).thumbnail { (_, result) in
                    image = result
                    semaphore.signal()
                }
                semaphore.wait()
                if let image = image {
                    return HTTPDataResponse(data: image.pngData())
                } else {
                    return super.httpResponse(forMethod: method, uri: path)
                }
            } else if path.hasPrefix("/document/data") {
                let parameters = path.urlParametersDecode
                let filePath = DocumentDirectory.appendingPathComponent(parameters["path"] ?? "/")
                do {
                    let data = try Data(contentsOf: filePath)
                    return HTTPDataResponse(data: data)
                } catch {
                    return HTTPDataResponse(data: error.localizedDescription.data(using: .utf8))
                }
            }
            else if path == "/" {
                let path = Bundle.main.path(forResource: "build/index.html", ofType: nil)
                return HTTPFileResponse(filePath: path, for: self)
            } else {
                let path = Bundle.main.path(forResource: "build/\(path!)", ofType: nil)
                return HTTPFileResponse(filePath: path, for: self)
            }
        }
        return super.httpResponse(forMethod: method, uri: path)
    }
}
