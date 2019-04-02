//
//  UIResponderExtensions.swift
//  Files
//
//  Created by 翟泉 on 2019/4/2.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

extension UIResponder {
    typealias Block = () -> Void
    typealias UserInfoBlock = (_ userInfo: Any?) -> Void

    private struct EventStrategy {
        let selector: Selector?
        let block: Block?
        let userInfoBlock: UserInfoBlock?

        init(selector: Selector? = nil, block: Block? = nil, userInfoBlock: UserInfoBlock? = nil) {
            self.selector = selector
            self.block = block
            self.userInfoBlock = userInfoBlock
        }

        func perform(target: NSObject, userInfo: Any?) {
            if let selector = selector {
                if NSStringFromSelector(selector).hasSuffix(":") {
                    target.perform(selector, with: userInfo)
                } else {
                    target.perform(selector)
                }
            } else if let block = block {
                block()
            } else if let userInfoBlock = userInfoBlock {
                userInfoBlock(userInfo)
            }
        }
    }

    static private var eventStrategyAssiciationKey: Int = 0

    private var eventStrategyDict: [String: EventStrategy] {
        get {
            var dict = objc_getAssociatedObject(self, &UIResponder.eventStrategyAssiciationKey) as? [String: EventStrategy]
            if dict == nil {
                dict = [String: EventStrategy]()
                objc_setAssociatedObject(self, &UIResponder.eventStrategyAssiciationKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return dict!
        }
        set {
            objc_setAssociatedObject(self, &UIResponder.eventStrategyAssiciationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIResponder {
    func routerEvent(with eventName: String, userInfo: Any?) {
        if let action = eventStrategyDict[eventName] {
            action.perform(target: self, userInfo: userInfo)
        } else {
            next?.routerEvent(with: eventName, userInfo: userInfo)
        }
    }

    func registerEventStrategy(with eventName: String, action: Selector) {
        eventStrategyDict[eventName] = EventStrategy(selector: action)
    }

    func registerEventStrategy(with eventName: String, block: @escaping Block) {
        eventStrategyDict[eventName] = EventStrategy(block: block)
    }

    func registerEventStrategy(with eventName: String, userInfoBlock: @escaping UserInfoBlock) {
        eventStrategyDict[eventName] = EventStrategy(userInfoBlock: userInfoBlock)
    }

    func eventStrategy<T>() -> T? {
        if let eventStrategy: T = self as? T {
            return eventStrategy
        } else {
            return next?.eventStrategy()
        }
    }
}
