//
//  ListUpdate.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

enum ListUpdateType {
    case insert
    case delete
    case reload
    case move
    case reloadAll
    case reloadVisible
}

struct ListUpdate: Equatable {
    var indexs: [Int] {
        return _indexs ?? []
    }
    var moveIndexs: [MoveIndex] {
        return _moveIndex ?? []
    }
    let type: ListUpdateType

    /// Init

    static func insert(indexs: [Int]) -> ListUpdate {
        return ListUpdate(indexs: indexs, moveIndexs: nil, type: .insert)
    }
    static func delete(indexs: [Int]) -> ListUpdate {
        return ListUpdate(indexs: indexs, moveIndexs: nil, type: .delete)
    }
    static func reload(indexs: [Int]) -> ListUpdate {
        return ListUpdate(indexs: indexs, moveIndexs: nil, type: .reload)
    }
    static func move(moveIndexs: [(Int, Int)]) -> ListUpdate {
        var _moveIndexs = [MoveIndex]()
        for (a, b) in moveIndexs {
            _moveIndexs.append(MoveIndex(index: a, newIndex: b))
        }
        return ListUpdate(indexs: nil, moveIndexs: _moveIndexs, type: .reload)
    }
    static let reloadAll: ListUpdate = ListUpdate(indexs: nil, moveIndexs: nil, type: .reloadAll)
    static let reloadVisible: ListUpdate = ListUpdate(indexs: nil, moveIndexs: nil, type: .reloadVisible)

    private let _indexs: [Int]?
    private let _moveIndex: [MoveIndex]?

    private init(indexs: [Int]?, moveIndexs: [MoveIndex]?, type: ListUpdateType) {
        _indexs = indexs
        _moveIndex = moveIndexs
        self.type = type
    }

    static func ==(lhs: ListUpdate, rhs: ListUpdate) -> Bool {
        return lhs.type == rhs.type && lhs.indexs == rhs.indexs && lhs.moveIndexs == rhs.moveIndexs
    }
}


extension ListUpdate {
    struct MoveIndex: Equatable {
        let index: Int
        let newIndex: Int
        var value: (Int, Int) {
            return (index, newIndex)
        }

        static func ==(lhs: MoveIndex, rhs: MoveIndex) -> Bool {
            return lhs.index == rhs.index && lhs.newIndex == rhs.newIndex
        }
    }
}
