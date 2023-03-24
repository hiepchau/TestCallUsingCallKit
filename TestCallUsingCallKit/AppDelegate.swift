//
//  AppDelegate.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 23/03/2023.
//

import UIKit
import PushKit
import CallKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.voipRegistration()
        return true
    }
    
    func handleIncomingMessage(text: String) {
        // Parse the incoming message as JSON
        guard let data = text.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let message = jsonObject as? [String: Any] else {
            return
        }
        
        // Check for the necessary information to handle a call
        guard let voip = message["voip"] as? String, voip == "1",
              let caller = message["caller"] as? String,
              let callUUIDString = message["call_uuid"] as? String,
              let callUUID = UUID(uuidString: callUUIDString) else {
            return
        }
        
        // Report the new incoming call
        let callManager = CallManager()
        callManager.reportNewIncomingCall(id: callUUID, handle: caller)
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
}
