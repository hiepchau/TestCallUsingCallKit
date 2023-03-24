//
//  ViewController.swift
//  TestCallUsingCallKit
//
//  Created by Châu Hiệp on 23/03/2023.
//

import UIKit
import CallKit

class ViewController: UIViewController {

    @IBOutlet weak var callButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func callButtonTapped(_ sender: UIButton) {
        call()
    }

    func call() {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
////            CallManager.shared.reportNewIncomingCall(handle: "hiepchau")
//            let callManager = CallManager()
//            let uuid = UUID()
//            callManager.reportNewIncomingCall(id: uuid, handle: "hiepchau")
//        })
        WebRTCClient.sharedInstance.createOffer()
    }
}


