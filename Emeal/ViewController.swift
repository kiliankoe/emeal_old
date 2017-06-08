//
//  ViewController.swift
//  Emeal
//
//  Created by Kilian Költzsch on 07.06.17.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {

    var readerSession: NFCNDEFReaderSession? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        readerSession?.begin()
    }
}

extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print(messages)
    }
}
