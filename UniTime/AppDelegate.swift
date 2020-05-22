//
//  AppDelegate.swift
//  UniTime
//
//  Created by Naoki Odajima on 2020/05/20.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let timeConvertVC = TimeConvertViewController(nibName: NSNib.Name("TimeConvertViewController"),
                                                          bundle: nil)
    private lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = timeConvertVC
        popover.behavior = .transient
        return popover
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusbarImage")
            button.imageScaling = .scaleProportionallyDown
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseDown])
        }
    }
    
    @objc
    private func statusItemClicked(_ sender: NSStatusBarButton) {
        NSApp.activate(ignoringOtherApps: true)
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds,
                     of: button,
                     preferredEdge: .minY)
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
}

