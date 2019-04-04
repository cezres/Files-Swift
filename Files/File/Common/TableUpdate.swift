//
//  ListUpdate.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

struct TableUpdate: Equatable {
    struct MoveIndex: Equatable {
        let index: Int
        let newIndex: Int

        static func ==(lhs: MoveIndex, rhs: MoveIndex) -> Bool {
            return lhs.index == rhs.index && lhs.newIndex == rhs.newIndex
        }
    }

    enum UpdateType {
        case insert
        case delete
        case reload
        case move
        case reloadAll
        case reloadVisible
    }

    let type: UpdateType
    let indexs: [Int]!
    let moveIndexs: [MoveIndex]!

    private init(indexs: [Int]?, moveIndexs: [MoveIndex]?, type: UpdateType) {
        self.indexs = indexs ?? []
        self.moveIndexs = moveIndexs ?? []
        self.type = type
    }

    static func ==(lhs: TableUpdate, rhs: TableUpdate) -> Bool {
        return lhs.type == rhs.type && lhs.indexs == rhs.indexs && lhs.moveIndexs == rhs.moveIndexs
    }
}

extension TableUpdate {
    static func insert(indexs: [Int]) -> TableUpdate {
        return TableUpdate(indexs: indexs, moveIndexs: nil, type: .insert)
    }
    static func delete(indexs: [Int]) -> TableUpdate {
        return TableUpdate(indexs: indexs, moveIndexs: nil, type: .delete)
    }
    static func reload(indexs: [Int]) -> TableUpdate {
        return TableUpdate(indexs: indexs, moveIndexs: nil, type: .reload)
    }
    static func move(moveIndexs: [(Int, Int)]) -> TableUpdate {
        let indexs = moveIndexs.map({ MoveIndex(index: $0.0, newIndex: $0.1) })
        return TableUpdate(indexs: nil, moveIndexs: indexs, type: .move)
    }
    static let reloadAll: TableUpdate = TableUpdate(indexs: nil, moveIndexs: nil, type: .reloadAll)
    static let reloadVisible: TableUpdate = TableUpdate(indexs: nil, moveIndexs: nil, type: .reloadVisible)
}

protocol TableUpdateProtocol {
    func tableUpdate(update: TableUpdate)
}

extension TableUpdateProtocol where Self: UICollectionView {
    func tableUpdate(update: TableUpdate) {
        switch update.type {
        case .reloadAll:
            reloadData()
        case .insert:
            insertItems(at: update.indexs.map({ IndexPath(row: $0, section: 0) }))
        case .delete:
            deleteItems(at: update.indexs.map({ IndexPath(row: $0, section: 0) }))
        case .reload:
            reloadItems(at: update.indexs.map({ IndexPath(row: $0, section: 0) }))
        case .move:
            update.moveIndexs.map {(
                index: IndexPath(row: $0.index, section: 0),
                newIndex: IndexPath(row: $0.newIndex, section: 0)
            )}.forEach {
                moveItem(at: $0.index, to: $0.newIndex)
            }
        case .reloadVisible:
            reloadItems(at: visibleCells.map({ indexPath(for: $0)! }))
        }
    }
}

extension UICollectionView: TableUpdateProtocol {}

extension TableUpdateProtocol where Self: UITableView {
    func tableUpdate(update: TableUpdate) {
        switch update.type {
        case .reloadAll:
            reloadData()
        case .insert:
            insertRows(at: update.indexs.map({ IndexPath(row: $0, section: 0) }), with: .none)
        case .delete:
            deleteRows(at: update.indexs.map({ IndexPath(row: $0, section: 0) }), with: .none)
        case .reload:
            reloadRows(at: update.indexs.map({ IndexPath(row: $0, section: 0) }), with: .none)
        case .move:
            update.moveIndexs.map {(
                index: IndexPath(row: $0.index, section: 0),
                newIndex: IndexPath(row: $0.newIndex, section: 0)
            )}.forEach {
                moveRow(at: $0.index, to: $0.newIndex)
            }
        case .reloadVisible:
            reloadRows(at: visibleCells.map({ indexPath(for: $0)! }), with: .none)
        }
    }
}

extension UITableView: TableUpdateProtocol {}
