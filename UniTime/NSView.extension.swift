//
//  NSView.extension.swift
//  UniTime
//
//  Created by Naoki Odajima on 2020/05/21.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Cocoa

extension NSView {
    static func instantiateFromNib<T: NSView>() -> T {
        let nibName = String(describing: T.self)
        guard let nib = NSNib(nibNamed: nibName, bundle: nil) else {
            fatalError("failed to load \(nibName).")
        }
        var topLevelObjects: NSArray?
        guard nib.instantiate(withOwner: nil, topLevelObjects: &topLevelObjects),
            let objects = topLevelObjects as? [Any]
        else {
            fatalError("failed to instantiate \(nibName).")
        }
        for object in objects {
            if let view = object as? T {
                return view
            }
        }
        fatalError("\(nibName) is not found.")
    }
}
