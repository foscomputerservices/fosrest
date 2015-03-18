//
//  FOSAppDelegate.swift
//  FOSREST
//
//  Created by David Hunt on 3/18/15.
//  Copyright (c) 2015 David Hunt. All rights reserved.
//

import UIKit
import FOSRest

@UIApplicationMain
class FOSAppDelegate : UIResponder, UIApplicationDelegate {

    var window: UIWindow!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        let adapter = FOSParseServiceAdapter()
        FOSLogInfoS("Adapter created: \(adapter.description)")

        return true
    }

}