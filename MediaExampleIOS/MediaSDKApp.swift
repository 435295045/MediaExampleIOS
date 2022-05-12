//
//  MediaSDKApp.swift
//  MediaSDK
//
//  Created by tyang on 2022/1/5.
//

import SwiftUI
import MediaRTC
import JJSwiftLog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        //log
        JJLogger.setup(level: .verbose);
        //SDK
        MediaSDK.initiate();
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }
}

@main
struct MediaSDKApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate;

    init() {
        print("Application is starting...")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
