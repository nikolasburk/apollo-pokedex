//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Nikolas Burk on 03/01/17.
//  Copyright © 2017 Nikolas Burk. All rights reserved.
//

import UIKit
import Apollo

let graphlQLEndpointURL = "https://api.graph.cool/simple/v1/ciwj0dtj30f6e0122nlykc9vp"
let apollo = ApolloClient(url: URL(string: graphlQLEndpointURL)!)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    return true
  }

}

