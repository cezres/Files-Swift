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
        if method == "OPTIONS" {
            if path.hasPrefix("/upload") {
                return true
            }
        }
        if method == "POST" {
            if path.hasPrefix("/upload") {
                let parameters = path.urlParametersDecode
                uploadDirectory = DocumentDirectory.appendingPathComponent(parameters["directory"] ?? "/")

                guard let request = self.request() else { return false }
                guard let contentType = request.headerField("Content-Type") else { return false }
                guard let paramsSeparator = contentType.range(of: ";")?.lowerBound else { return false }
                let index = contentType.distance(from: contentType.startIndex, to: paramsSeparator)
                if index == NSNotFound || index >= contentType.count - 1 {
                    return false
                }
                let type = contentType.prefix(upTo: paramsSeparator)
                if type != "multipart/form-data" {
                    return false
                }
                let params = contentType.suffix(from: contentType.index(paramsSeparator, offsetBy: 1)).components(separatedBy: ";")
                params.forEach { (param) in
                    guard let paramsSeparator = param.range(of: "=")?.lowerBound else { return }
                    let index = param.distance(from: param.startIndex, to: paramsSeparator)
                    if (index == NSNotFound || index >= param.count - 1) {
                        return
                    }
                    let name = param[param.index(param.startIndex, offsetBy: 1)...param.index(paramsSeparator, offsetBy: -1)]
                    let value = param.suffix(from: param.index(paramsSeparator, offsetBy: 1))
                    if name == "boundary" {
                        request.setHeaderField("boundary", value: String(value))
                    }
                }
                if request.headerField("boundary") == nil {
                    return false
                }
                return true
            }
        }
        return super.expectsRequestBody(fromMethod: method, atPath: path)
    }

    override func supportsMethod(_ method: String!, atPath path: String!) -> Bool {
        if method == "POST" {
            if path.hasPrefix("/upload") {
                return true
            }
        }
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
                return HTTPAsyncFileResponse(filePath: filePath.path, for: self)
            }
            /// html
            if path == "/" {
                let path = Bundle.main.path(forResource: "build/index.html", ofType: nil)
                return HTTPFileResponse(filePath: path, for: self)
            } else {
                let path = Bundle.main.path(forResource: "build/\(path!)", ofType: nil)
                if path == nil {
                    let path = Bundle.main.path(forResource: "build/index.html", ofType: nil)
                    return HTTPFileResponse(filePath: path, for: self)
                }
                return HTTPFileResponse(filePath: path, for: self)
            }
        } else if method == "POST" {
            if path.hasPrefix("/upload") {
                return HTTPDataResponse(data: nil)
            }
        }
        return super.httpResponse(forMethod: method, uri: path)
    }


    var parser: MultipartFormDataParser?
    var storeFile: FileHandle?
    var uploadDirectory: URL?
    var uploadFilePath: URL?
    var filename: String?

    override func prepareForBody(withSize contentLength: UInt64) {
        let boundary = self.request()?.headerField("boundary")
        parser = MultipartFormDataParser(boundary: boundary, formEncoding: String.Encoding.utf8.rawValue)
        parser?.delegate = self
    }

    override func processBodyData(_ postDataChunk: Data!) {
        parser?.append(postDataChunk)
    }
}


extension FileHTTPConnection: MultipartFormDataParserDelegate {
    func processStartOfPart(with header: MultipartMessageHeader!) {
        let disposition = header.fields["Content-Disposition"] as! MultipartMessageHeaderField
        guard let filename = disposition.params["filename"] as? String else { return }
        if (filename == "") {
            return
        }
        guard let uploadDirectory = uploadDirectory else {
            return
        }
        self.filename = filename
        uploadFilePath = uploadDirectory.appendingPathComponent("upload_\(Int(Date().timeIntervalSince1970 * 1000))_\(filename)")
        if !FileManager.default.createFile(atPath: uploadFilePath!.path, contents: nil, attributes: nil) {
            print("Could not create file at path: \(uploadFilePath!)")
            return
        }
        storeFile = FileHandle(forWritingAtPath: uploadFilePath!.path)
    }

    func processContent(_ data: Data!, with header: MultipartMessageHeader!) {
        storeFile?.write(data)
    }

    func processEndOfPart(with header: MultipartMessageHeader!) {
        storeFile?.closeFile()
        storeFile = nil
        if let uploadFilePath = uploadFilePath, let filename = filename {
            let filePath = generateFilePath(name: filename.deletingPathExtension, pathExtension: filename.pathExtension, directory: uploadDirectory!)
            try? FileManager.default.moveItem(at: uploadFilePath, to: filePath)
        }
    }
}
