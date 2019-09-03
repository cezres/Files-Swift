//
//  Document.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import WatchFolder
import DifferenceKit

protocol DocumentDelegate: class {
    func document(document: Document, contentsDidUpdate changeset: StagedChangeset<[File]>)
}

class Document: NSObject {
    let directory: URL
    weak var delegate: DocumentDelegate?
    private(set) var contents = [File]()

    /// filter
    typealias Filter = (_ file: File) -> Bool
    var filter: Filter?

    /// private
    private let watch: WatchFolder
    private let queue: DispatchQueue

    init(directory: URL, filter: Filter? = nil) {
        self.directory = directory
        watch = WatchFolder(url: directory)
        queue = DispatchQueue(label: String(describing: Document.self) + directory.hashValue.description)
        super.init()
        self.filter = filter
        watch.delegate = self
        try! watch.start()
        loadContents()
    }

    deinit {
        watch.invalidate()
    }
}

/// Operations
extension Document {
    func removeItems(_ indexs: [Int]) throws {
        try indexs.sorted { $0 > $1 }.forEach {
            try FileManager.default.removeItem(at: contents[$0].url)
        }
    }

    func moveItems(_ indexs: [Int], to directory: URL) throws {
        try indexs.sorted { $0 > $1 }.forEach {
            let from = contents[$0].url
            let to = directory.appendingPathComponent(from.lastPathComponent)
            try FileManager.default.moveItem(at: from, to: to)
        }
    }

    func createItem(name: String) throws {
        try FileManager.default.createDirectory(at: directory.appendingPathComponent(name, isDirectory: true), withIntermediateDirectories: false, attributes: nil)
    }

    func copyItems(_ indexs: [Int], to directory: URL) throws {
        try indexs.forEach {
            let from = contents[$0].url
            let to = directory.appendingPathComponent(from.lastPathComponent)
            try FileManager.default.copyItem(at: from, to: to)
        }
    }
}

/// Load contents
extension Document {
    func loadContents() {
        print("\(#function) \(directory.lastPathComponent)")
        queue.async {
            /// load contents
            let contents = try! FileManager.default.contentsOfDirectory(atPath: self.directory.path)
            var files = contents.map { File(url: self.directory.appendingPathComponent($0)) }

            /// sort
            files = files.sorted(by: { (file1, fil2) -> Bool in
                return true
            })

            /// filter
            if let filter = self.filter {
                files = files.filter(filter)
            }

            /// changeset
            let changeset = StagedChangeset(source: self.contents, target: files)

            DispatchQueue.main.sync {
                self.contents = files
                self.delegate?.document(document: self, contentsDidUpdate: changeset)
            }
        }
    }
}

/// Document+WatchFolderDelegate
extension Document: WatchFolderDelegate {
    func watchFolderNotification(_ folder: WatchFolder) {
        print("\(#function) \(directory.lastPathComponent)")
        loadContents()
    }
}

/// UICollectionView+Reload
extension UICollectionView {
    func reload<C>(using stagedChangeset: StagedChangeset<C>) {
        reload(using: stagedChangeset, interrupt: nil) { _ in }
    }
}
