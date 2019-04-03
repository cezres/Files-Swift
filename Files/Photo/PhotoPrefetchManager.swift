//
//  PhotoPrefetchManager.swift
//  Files
//
//  Created by 翟泉 on 2019/3/20.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class PhotoPrefetchManager {
    struct CacheItem {
        let url: URL
        weak var original: UIImage!
        var thumbnails: NSHashTable<UIImage>
    }

    var maxConcurrentOperationCount = 4
    var thumbnailWidth: CGFloat = 400.0

    private let cache: NSCache<NSString, AnyObject>!
    private let thumbnailCache: NSCache<NSString, AnyObject>!
    private let dispatchQueue: DispatchQueue!
    private var prefetchOperations = [PrefetchOperation]()
    private var prefetchingOperations = [PrefetchOperation]()

    init() {
        cache = NSCache()
        cache.totalCostLimit = 1000 * 1000 * 20
        thumbnailCache = NSCache()
        thumbnailCache.totalCostLimit = 1000 * 1000 * 30
        dispatchQueue = DispatchQueue(label: "PhotoPrefetchManager")
    }

    func requestImage(url: URL, targetSize: RequestTargetSize = .original, completion: @escaping (_ image: UIImage) -> Void) {
        prefetch(url: url, targetSize: targetSize, completion: completion)
    }

    func cancelImageRequest() {
    }

    func prefetch(urls: [URL]) {
        urls.forEach({ prefetch(url: $0) })
    }

    func prefetch(url: URL, targetSize: RequestTargetSize = .original, completion: ((_ result: UIImage) -> Void)? = nil) {
        dispatchQueue.async {
            if let image = self.cache.object(forKey: url.path as NSString) as? UIImage {
                DispatchQueue.main.async {
                    completion?(image)
                }
//                print("缓存中: \(url.lastPathComponent)")
            } else if let operation = self.prefetchingOperations.first(where: { $0.url == url }) {
                operation.completionBlock = completion
//                print("正在加载: \(url.lastPathComponent)")
            } else {
//                print("队列中: \(url.lastPathComponent)")
                let operation = PrefetchOperation(url, targetSize: targetSize)
                if let index = self.prefetchOperations.firstIndex(where: { $0 == operation }) {
                    if completion == nil {
                        operation.completionBlock = self.prefetchOperations[index].completionBlock
                    } else {
                        operation.completionBlock = completion
                    }
                    self.prefetchOperations.remove(at: index)
                } else {
                    operation.completionBlock = completion
                }
                self.prefetchOperations.append(operation)
                self.handleOperations()
            }
        }
    }

    func cancelPrefetching(urls: [URL]) {

    }

    private func handleOperations() {
        dispatchQueue.async {
            guard self.prefetchOperations.count > 0 else { return }
            guard self.prefetchingOperations.count < self.maxConcurrentOperationCount else { return }
            let operation = self.prefetchOperations.removeLast()
            self.prefetchingOperations.append(operation)
            DispatchQueue.global().async {
//                print("Cacheing \(operation.url.lastPathComponent)")
                if let image = UIImage(contentsOfFile: operation.url.path) {
                    let result: UIImage
                    switch (operation.targetSize) {
                    case .original:
                        result = image.decode()
                    case .custom(let size):
                        result = image.scale(width: size.width).decode()
                    case .thumbnail:
                        result = image.scale(width: self.thumbnailWidth).decode()
                    }
                    self.cache.setObject(result, forKey: operation.url.path as NSString)
                    if let block = operation.completionBlock {
                        DispatchQueue.main.async {
//                            print("加载完成回调: \(operation.url.lastPathComponent)")
                            block(result)
                        }
                    }
                }
//                print("Cahced \(operation.url.lastPathComponent)")
                self.dispatchQueue.async {
                    self.prefetchingOperations.removeAll(where: { $0 == operation })
                    self.handleOperations()
                }
            }
        }
    }
}

enum RequestTargetSize {
    case original
    case thumbnail
    case custom(size: CGSize)
}

private class PrefetchOperation: Equatable, CustomStringConvertible {
    let url: URL
    let targetSize: RequestTargetSize
    var completionBlock: ((_ result: UIImage) -> Void)?

    init(_ url: URL, targetSize: RequestTargetSize) {
        self.url = url
        self.targetSize = targetSize
    }

    func completion(block: @escaping (_ result: UIImage) -> Void) {
        self.completionBlock = block
    }

    static func == (lhs: PrefetchOperation, rhs: PrefetchOperation) -> Bool {
        return lhs.url == rhs.url
    }

    var description: String {
        return url.lastPathComponent + " \(String(describing: completionBlock))"
    }
}
