//
//  SocketIOManager.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 24/03/2023.
//

import UIKit
import SocketIO

class SocketIOManager {
    static let sharedInstance = SocketIOManager()
    
    private let socketManager: SocketManager
    private let socket: SocketIOClient
    
    private init() {
        let socketURL = URL(string: "https://bteam-socket.beetechsoft.vn")!
        let config: SocketIOClientConfiguration = [.log(true), .compress, .secure(true), .forceWebsockets(true)]
        socketManager = SocketManager(socketURL: socketURL, config: config)
        socket = socketManager.defaultSocket
        
        socket.on(clientEvent: .error) { data, ack in
            print("SOCKET ERROR(\(data).")
        }
        socket.on(clientEvent: .disconnect) { data, ack in
            print("SOCKET DISCONNECT.")
        }
        
        addHandlers()
    }
    func getSocket() -> SocketIOClient {
        let socket = socket
        return socket
    }
    func establishConnection(_ onConnectedEvent:@escaping ()->Void) {
        socket.connect()
        socket.on(clientEvent: .connect, callback: { data, ack in
            print("SOCKET CONNECTED.")
            onConnectedEvent()
        })
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    private func addHandlers() {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let text = data[0] as? String else { return }
            self?.handleIncomingMessage(text: text)
            print("SOCKET CONNECTED.")
        }
    }

    private func handleIncomingMessage(text: String) {
        // Handle incoming message text
    }
}
