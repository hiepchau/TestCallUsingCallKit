//
//  CallManager.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 23/03/2023.
//

import Foundation
import CallKit
//import AVFoundation

class CallManager: NSObject, CXProviderDelegate {
    static let shared = CallManager()
    private let callController = CXCallController()
    private let provider = CXProvider(configuration: CXProviderConfiguration())

    override init() {
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    public func reportNewIncomingCall(id: UUID, handle: String) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: CXHandle.HandleType.generic, value: handle)
        update.hasVideo = false
        update.localizedCallerName = "Test Call Medda"

        provider.reportNewIncomingCall(with: id, update: update) { error in
            if let error = error {
                print("Error reporting incoming call: \(error.localizedDescription)")
            } else {
                print("Incoming call successfully reported")
            }
        }
    }
    
    public func startCall(id: UUID, handle: String) {
        let handle = CXHandle(type: CXHandle.HandleType.generic, value: handle)
        let action = CXStartCallAction(call: id, handle: handle)
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            if let error = error {
                print(String(describing: error))
            } else {
                print("call success")
            }
        }
    }

    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Answer call")
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Start call")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("End call")
        action.fulfill()
    }

}
//    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
//        print("Audio session activated")
//
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
//            try audioSession.setActive(true, options: [])
//        } catch {
//            print("Error configuring audio session: \(error.localizedDescription)")
//        }
//    }
//
//    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
//        print("Audio session deactivated")
//    }
