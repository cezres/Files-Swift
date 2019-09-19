//
//  File.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import FastImageCache
import DifferenceKit

class File {
    let url: URL
    lazy private(set) var name: String = url.lastPathComponent
    lazy private(set) var pathExtension: String = url.pathExtension
    lazy private(set) var relativePath: String = {
        guard let range = url.path.range(of: DocumentDirectory.path) else { return url.path }
        return String(url.path[range.upperBound...])
    }()
    lazy private(set) var identifier: String = {
        let UUIDBytes = FICUUIDBytesFromMD5HashOfString(relativePath)
        return FICStringWithUUIDBytes(UUIDBytes)
    }()
    lazy private(set) var type: FileType = {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if isDirectory.boolValue {
            return DirectoryFileType()
        }
        return File.types.first { $0.pathExtensions.contains(pathExtension.lowercased()) } ?? UnknownFileType()
    }()
    lazy private(set) var attributes = Attributes(url: url)

    init(url: URL) {
        self.url = url
    }

    // MARK: - Thumbnail
    func thumbnail(completion: @escaping (File, UIImage) -> Void) {
        type.thumbnail(file: self) { [weak self](image) in
            guard let self = self else { return }
            completion(self, image)
        }
    }

    // MARK: - Open
    func open(document: Document, controller: DocumentBrowserViewController) {
        type.openFile(self, document: document, controller: controller)
    }

    // MARK: - Types
    fileprivate static var types = [FileType]()

    static func register(type: FileType) {
        types.append(type)
    }
}

extension File {
    struct Attributes {
        let url: URL
        let attributes: [FileAttributeKey: Any]

        var size: UInt? {
            return (attributes[.size] as? NSNumber)?.uintValue
        }
        var modificationDate: Date? {
            return attributes[.modificationDate] as? Date
        }

        init(url: URL) {
            self.url = url
            attributes = (try? FileManager.default.attributesOfItem(atPath: url.path)) ?? [:]
        }
    }
}

extension File: Equatable {
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension File: Differentiable {
    typealias DifferenceIdentifier = Int

    var differenceIdentifier: File.DifferenceIdentifier {
        return url.hashValue
    }
}

extension File: CustomStringConvertible {
    var description: String {
        return "\(name) \(type.name))"
    }
}

protocol FileType {
    var name: String { get }
    var sortIndex: Int { get }
    var pathExtensions: [String] { get }
    func thumbnail(file: File, completion: @escaping (UIImage) -> Void)
    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController)
}

extension FileType {
    var sortIndex: Int {
        return File.types.lastIndex(where: { $0.name == self.name }) ?? Int.max
    }
}

struct DirectoryFileType: FileType {
    let name = "Directory"
    let pathExtensions: [String] = [""]

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
        let documentBrowser = DocumentBrowserViewController(directory: file.url)
        controller.navigationController?.pushViewController(documentBrowser, animated: true)
    }

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        completion(UIImage(named: "icon_directory")!)
    }
}

struct UnknownFileType: FileType {
    let name = "Unknown"
    let pathExtensions: [String] = []

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
    }

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        completion(UIImage(named: "icon_unknown")!)
    }
}
