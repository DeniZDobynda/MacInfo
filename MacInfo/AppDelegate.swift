//
//  AppDelegate.swift
//  MacInfo
//
//  Created by Denis Dobanda on 21.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import CoreData
import SwiftSocket

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var tcpClient: TCPClient?
    private var alive = false
    
    static var connection: TCPClient? {
        get {
            return AppDelegate.instance.tcpClient
        }
        set {
            if AppDelegate.instance.tcpClient != nil {
                AppDelegate.instance.closeConnection()
            }
            AppDelegate.instance.tcpClient = newValue
            if newValue != nil {
                switch newValue!.send(string: "0") {
                case .failure(let e):
                    print(e)
                case .success:
                    AppDelegate.instance.startListening()
                }
            }
        }
    }
    
    private func startListening() {
        alive = true
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            while self != nil, self!.alive {
                if let server = self?.tcpClient, let data = server.read(1024*10),
                    let strData = String(bytes: data, encoding: .utf8) {
                    self?.lastMessage = strData
                    if strData.contains("terminate") {
                        self?.alive = false
                        server.close()
                        self?.connectionClosed()
                        return
                    }
                }
                sleep(1)
            }
        }
    }
    
    private func stopListening() {
        alive = false
    }
    
    private func closeConnection() {
        if let server = tcpClient {
            switch server.send(string: "close") {
            case .failure(let e):
                print(e)
            case .success: break
            }
            server.close()
        }
        stopListening()
        connectionClosed()
    }
    
    private var lastMessage: String? {
        didSet {
            if let message = lastMessage {
                delegates.forEach() {$0.TCPConnectionReceivedAsync(message)}
            }
        }
    }
    
    private var delegates: [TCPConnectionMessageServiceAsync] = [] {
        didSet {
            if let message = lastMessage {
                delegates.last?.TCPConnectionReceivedAsync(message)
            }
        }
    }
    
    private func connectionClosed() {
        delegates.forEach() {$0.TCPConnectionTerminatedAsync()}
    }
    
    static func addMessageDelegate(_ delegate: TCPConnectionMessageServiceAsync) {
        AppDelegate.instance.delegates.append(delegate)
    }
    
    static func removeMessageDelegate(_ delegate: TCPConnectionMessageServiceAsync) {
        for i in 0..<AppDelegate.instance.delegates.count {
            if AppDelegate.instance.delegates[i].hashValue == delegate.hashValue {
                AppDelegate.instance.delegates.remove(at: i)
                return
            }
        }
    }
    
    static var instance: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MacInfo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

