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
    var delegates: NSHashTable<AnyObject>!
    private(set) var contents = [File]()

    init(directory: URL) {
        self.directory = directory
        delegates = NSHashTable(options: NSPointerFunctions.Options.weakMemory)
    }

    func registerDelegate(delegate: DocumentDelegate) {
        delegates.add(delegate)
        delegate.document(document: self, contentsDidUpdate: .reloadAll)
    }

    func loadContents() {
        DispatchQueue.global().async {
            do {
                var files = [File]()
                let contents = try FileManager.default.contentsOfDirectory(atPath: self.directory.path)
                for name in contents {
                    let file = File(url: self.directory.appendingPathComponent(name))
                    files.append(file)
                }
                self.contents = files
                DispatchQueue.main.async {
                    (self.delegates.allObjects as! [DocumentDelegate]).forEach( { $0.document(document: self, contentsDidUpdate: .reloadAll) })
                }
            } catch {
            }
        }

    }
}
