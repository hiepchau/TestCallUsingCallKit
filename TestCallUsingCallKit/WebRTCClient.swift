//
//  WebRTCClient.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 24/03/2023.
//

import UIKit
import Foundation
import SocketIO
import WebRTC

class WebRTCClient: NSObject {
    private let peerConnection: RTCPeerConnection
    private let socketIOManager = SocketIOManager.sharedInstance
    static let sharedInstance = WebRTCClient()
    override init() {
        // Initialize WebRTC related components
        let rtcConfig = RTCConfiguration()
        rtcConfig.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let defaultPeerConnectionFactory = RTCPeerConnectionFactory()
        peerConnection = defaultPeerConnectionFactory.peerConnection(with: rtcConfig, constraints: constraints, delegate: nil)
        
        super.init()
        
        // Set the peerConnection delegate
        peerConnection.delegate = self
        
        // Connect to the socket
        socketIOManager.establishConnection {
            print("Socket connected, ready to create WebRTC offer")
            self.addSocketHandlers()
        }
    }
    
    func createOffer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"], optionalConstraints: nil)
        
        peerConnection.offer(for: constraints) { [weak self] (sdp, error) in
            guard let self = self, let sdp = sdp else { return }
            self.peerConnection.setLocalDescription(sdp) { (error) in
                guard error == nil else { return }
                // Emit the offer to the server
                let offer = ["sdp": sdp.sdp, "type": "offer"]
                self.socketIOManager.getSocket().emit("sendOffer", offer)
            }
        }
    }
    
    private func addSocketHandlers() {
        socketIOManager.getSocket().on("receiveAnswer") { [weak self] data, ack in
            guard let self = self, let answerData = data[0] as? [String: Any], let sdpString = answerData["sdp"] as? String, let sdpType = answerData["type"] as? String else { return }
            let sdp = RTCSessionDescription(type: self.sdpTypeFromString(sdpType), sdp: sdpString)
            self.peerConnection.setRemoteDescription(sdp) { (error) in
                print("Set remote description completed with error: \(String(describing: error))")
            }
        }
        
        socketIOManager.getSocket().on("receiveIceCandidate") { [weak self] data, ack in
            guard let self = self, let candidateData = data[0] as? [String: Any], let sdp = candidateData["candidate"] as? String, let sdpMLineIndex = candidateData["sdpMLineIndex"] as? Int32, let sdpMid = candidateData["sdpMid"] as? String else { return }
            let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
            self.peerConnection.add(candidate)
        }
    }
    
    func sdpTypeFromString(_ sdpTypeString: String) -> RTCSdpType {
        switch sdpTypeString {
        case "offer":
            return .offer
        case "pranswer":
            return .prAnswer
        case "answer":
            return .answer
        default:
            fatalError("Unknown SDP type: \(sdpTypeString)")
        }
    }
}
    
// MARK: - RTCPeerConnectionDelegate
extension WebRTCClient: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let candidateData: [String: Any] = ["candidate": candidate.sdp, "sdpMLineIndex": candidate.sdpMLineIndex, "sdpMid": candidate.sdpMid]
        socketIOManager.getSocket().emit("sendIceCandidate", candidateData)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("ICE connection state changed to: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ICE gathering state changed to: \(newState.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("Signaling state changed to: \(stateChanged.rawValue)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("Media stream was removed")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print("Peer connection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("Data channel was opened")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("Media stream was added")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
}




