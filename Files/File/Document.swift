//
//  Document.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol DocumentDelegate: class {
    func document(document: Document, contentsDidUpdate update: TableUpdate)
}

class Document: NSObject {
    let directory: URL
    var delegateHashTable: NSHashTable<AnyObject>!
    var delegates: [DocumentDelegate] { return delegateHashTable.allObjects as! [DocumentDelegate] }
    private(set) var contents = [File]()

    /// filter
    typealias Filter = (_ file: File) -> Bool
    var filters = [Filter]()

    init(directory: URL) {
        self.directory = directory
        delegateHashTable = NSHashTable(options: NSPointerFunctions.Options.weakMemory)
    }

    func registerDelegate(delegate: DocumentDelegate) {
        delegateHashTable.add(delegate)
        delegate.document(document: self, contentsDidUpdate: .reloadAll)
    }

    func loadContents() {
        DispatchQueue.global().async {
            var files = [File]()

            /// load contents
            let contents = try? FileManager.default.contentsOfDirectory(atPath: self.directory.path)
            for name in contents ?? [] {
                let file = File(url: self.directory.appendingPathComponent(name))
                files.append(file)
            }

            /// sort
            files = files.sorted(by: { (file1, fil2) -> Bool in
                return true
            })

            /// filter
            self.filters.forEach { files = files.filter($0) }

            DispatchQueue.main.async {
                self.contents = files
                self.delegates.forEach( { $0.document(document: self, contentsDidUpdate: .reloadAll) })
            }
        }
    }

    func removeItems(_ indexs: [Int]) throws {
        var successIndexs = [Int]()
        indexs.sorted { $0 > $1 }.forEach {
            do {
                try FileManager.default.removeItem(at: contents[$0].url)
                successIndexs.append($0)
                contents.remove(at: $0)
            } catch {
            }
        }
        delegates.forEach { $0.document(document: self, contentsDidUpdate: .delete(indexs: successIndexs)) }
    }

    func moveItems(_ indexs: [Int], to directory: URL) {
        var successIndexs = [Int]()
        indexs.sorted { $0 > $1 }.forEach {
            do {
                let from = contents[$0].url
                let to = directory.appendingPathComponent(from.lastPathComponent)
                try FileManager.default.moveItem(at: from, to: to)
                successIndexs.append($0)
                contents.remove(at: $0)
            } catch {
            }
        }
        delegates.forEach { $0.document(document: self, contentsDidUpdate: .delete(indexs: successIndexs)) }
    }
}
