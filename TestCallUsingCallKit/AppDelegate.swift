//
//  AppDelegate.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 23/03/2023.
//

import UIKit
import PushKit
import CallKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.voipRegistration()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Request authorization for notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let voip = userInfo["voip"] as? String, voip == "1",
              let caller = userInfo["caller"] as? String,
              let callUUIDString = userInfo["call_uuid"] as? String,
              let callUUID = UUID(uuidString: callUUIDString) else {
            completionHandler(.noData)
            return
        }
        
        let callManager = CallManager()
        callManager.reportNewIncomingCall(id: callUUID, handle: caller)
        
        completionHandler(.newData)
    }
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    func pushRegistry(registry: PKPushRegistry!, didUpdatePushCredentials credentials: PKPushCredentials!, forType type: String!) {
        // Register VoIP push token (a property of PKPushCredentials) with server
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Incoming push received")
        let id = UUID()
        CallManager.shared.reportNewIncomingCall(id: id, handle: "hiepchau")
        completion()
    }
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
    //Setup FCM
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        // Send the FCM token to your server to use for sending notifications.
    }
    
    //Handle incoming notifications via FCM
    func messaging(_ messaging: Messaging, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            guard let voip = userInfo["voip"] as? String, voip == "1",
                  let caller = userInfo["caller"] as? String,
                  let callUUIDString = userInfo["call_uuid"] as? String,
                  let callUUID = UUID(uuidString: callUUIDString) else {
                completionHandler(.noData)
                return
            }
            
            let callManager = CallManager()
            callManager.reportNewIncomingCall(id: callUUID, handle: caller)
            
            completionHandler(.newData)
        }


}
