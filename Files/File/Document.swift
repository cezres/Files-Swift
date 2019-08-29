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
    var filters = [Filter]()

    /// private
    private let watch: WatchFolder
    private let queue: DispatchQueue

    init(directory: URL) {
        self.directory = directory
        watch = WatchFolder(url: directory)
        queue = DispatchQueue(label: String(describing: Document.self) + directory.hashValue.description)
        super.init()
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
        indexs.sorted { $0 > $1 }.forEach {
            try? FileManager.default.removeItem(at: contents[$0].url)
        }
    }

    func moveItems(_ indexs: [Int], to directory: URL) {
        indexs.sorted { $0 > $1 }.forEach {
            let from = contents[$0].url
            let to = directory.appendingPathComponent(from.lastPathComponent)
            try? FileManager.default.moveItem(at: from, to: to)
        }
    }
}

/// Load contents
extension Document {
    func loadContents() {
        queue.async {
            /// load contents
            let contents = try! FileManager.default.contentsOfDirectory(atPath: self.directory.path)
            var files = contents.map { File(url: self.directory.appendingPathComponent($0)) }

            /// sort
            files = files.sorted(by: { (file1, fil2) -> Bool in
                return true
            })

            /// filter
            self.filters.forEach { files = files.filter($0) }

            /// changeset
            let changeset = StagedChangeset(source: self.contents, target: files)

            DispatchQueue.main.async {
                self.contents = files
                self.delegate?.document(document: self, contentsDidUpdate: changeset)
            }
        }
    }
}

/// Document+WatchFolderDelegate
extension Document: WatchFolderDelegate {
    func watchFolderNotification(_ folder: WatchFolder) {
        loadContents()
    }
}

/// UICollectionView+Reload
extension UICollectionView {
    func reload<C>(using stagedChangeset: StagedChangeset<C>) {
        reload(using: stagedChangeset, interrupt: nil) { _ in }
    }
}
