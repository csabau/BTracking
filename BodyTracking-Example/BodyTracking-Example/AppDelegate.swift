//
//  AppDelegate.swift
//  BodyTracking-Example
//
//  Created by Grant Jarvis on 2/8/21.
//

import UIKit
import SwiftUI



@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   public var uiWindow: UIWindow?
 
    

    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(DataModel.shared)

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        //----------------------------------+
        //new code for a new UIWindow
        //setting the AR window / contentView level to main / normal
        window.windowLevel = .normal
        //+----------------------------------//
        window.makeKeyAndVisible()
        //newWindow(isHidden: true)
        //----------------------------------+
        let uiWindow = UIWindow(frame: CGRect(x:0, y: 70, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 70) /*UIScreen.main.bounds*/  /*CGRect(x:0, y: UIScreen.main.bounds.height - 200, width:UIScreen.main.bounds.width, height: 200)*/)
        self.uiWindow = uiWindow
        uiWindow.windowLevel = UIWindow.Level(UIWindow.Level.normal.rawValue + 1)
        uiWindow.isOpaque = false

        //Render SwiftUI based UI
        let content = ControlView()
            .background(Color.clear)

        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        hosting.view.isOpaque = false

        uiWindow.rootViewController = hosting
        uiWindow.isHidden = true

       // uiWindow.makeKeyAndVisible()
        //+----------------------------------//
        
        return true
    }
    
  

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}
