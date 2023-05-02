//
//  AppDelegate.swift
//  meme 1.0
//
//  Created by sudo on 12/6/17.
//  Copyright © 2017 sudo. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var borrowInfo = [[BorrowInfo]]()
  
    let dataController = DataController(modelName: "BorrowTime")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let BorrowTableViewStarter = navigationController.topViewController as! BorrowTableViewController
        BorrowTableViewStarter.dataController = dataController
        
        // MARK: - Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (accepted, error) in
            if !accepted {
                print("Notifications access denied")
            }
        }
        return true
    }
    
    func scheduleNotification(at date: Date, name: String, memedImage: ImageInfo) {
        if memedImage.notificationIdentifier != nil {
            guard let notificationIdentifier = memedImage.notificationIdentifier else { return }
            memedImage.reminderDate = date
            try? self.dataController.viewContext.save()
            removeScheduleNotification(at: notificationIdentifier, at: memedImage)
        }
         let center = UNUserNotificationCenter.current()
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "🙌 Just a reminder"
        content.body = "Your \(name) has been out there for a while. Remind them that you want it back."
        content.sound = UNNotificationSound.default()
        memedImage.timeHasExpired = true
        try? self.dataController.viewContext.save()
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        memedImage.notificationIdentifier = request.identifier
        try? dataController.viewContext.save()
        UNUserNotificationCenter.current().delegate = self
        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Constants.DateText.dateAndTime
                memedImage.selectedDate = dateFormatter.string(from: date)
                let alertController = UIAlertController(title: "We will remind on:", message: "\(dateFormatter.string(from: date))", preferredStyle: .alert)
                var okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    NSLog("OK Pressed")
                                }
                _ = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
                                    UIAlertAction in
                                    NSLog("Cancel Pressed")
                                }
                alertController.addAction(okAction)
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)

            }
        }
    }
    
    func removeScheduleNotification(at identifier: String, at memedImage: ImageInfo) {
        let center = UNUserNotificationCenter.current()
        UNUserNotificationCenter.current().delegate = self
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        memedImage.notificationIdentifier = nil
//        memedImage.reminderDate = nil
        try? dataController.viewContext.save()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    func saveViewContext() {
        try? dataController.viewContext.save()
    }


}

