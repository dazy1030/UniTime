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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusbarImage")
            button.imageScaling = .scaleProportionallyDown
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private func constructMenu() {
        let menu = NSMenu()
        let view: MenuItemView = .instantiate()
        let menuItem = NSMenuItem()
        menuItem.view = view
        menu.addItem(menuItem)
        
        statusItem.menu = menu
    }
}

