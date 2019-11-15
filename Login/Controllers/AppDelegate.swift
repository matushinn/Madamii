//
//  AppDelegate.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/04.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        // MARK: アプリが起動されるときに実行される処理を追記する場所
        
        // ナビゲーションアイテムの色変更
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.9412, green: 0.451, blue: 0.6078, alpha: 1)
        // ナビゲーションバーの色変更
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.9412, green: 0.451, blue: 0.6078, alpha: 1)
        // ナビゲーションタイトルの色変更
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITabBar.appearance().barTintColor = UIColor(red: 0.9412, green: 0.451, blue: 0.6078, alpha: 1)
        // タブバーアイテムの色変更
        UITabBar.appearance().tintColor = UIColor.white
        
        //連携完了
        NCMB.setApplicationKey(APIKey.applicationKey, clientKey: APIKey.clientKey)
        
        let ud = UserDefaults.standard
        let isLogin = ud.bool(forKey: "isLogin")
        
        if isLogin == true {
            // ログイン中だったら
            //画面の大きさ
            self.window = UIWindow(frame: UIScreen.main.bounds)
            //Bundle.mainはこの中
            let storyboard = UIStoryboard(name: "Main"
                , bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "MainController")
            self.window?.rootViewController = rootViewController
            //小技　見えていけない画面を減らすため。
            self.window?.backgroundColor = UIColor.white
            //その画面を表示
            self.window?.makeKeyAndVisible()
        } else {
            // ログインしていなかったら
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
            self.window?.rootViewController = rootViewController
            self.window?.backgroundColor = UIColor.white
            self.window?.makeKeyAndVisible()
        }
        return true
    }
    
    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // MARK: アプリが起動しているときに実行される処理を追記する場所
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

