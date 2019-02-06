//
//  ConnectionViewController.swift
//  MacInfo
//
//  Created by Denis Dobanda on 21.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import SwiftSocket

class ConnectionViewController: UIViewController {

    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Show Dashboard" {
            var connection: TCPClient
            if let host = hostTextField.text,
                let portS = portTextField.text,
                let port = Int32(portS)
            {
                connection = TCPClient(address: host, port: port)
            } else {
                connection = TCPClient(address: "192.168.178.25", port: 57171)
            }
            switch connection.connect(timeout: 100) {
            case .success:
                AppDelegate.connection = connection
                return true
            case .failure(let e):
                print(e.localizedDescription)
                return false
            }
        }
        return false
    }
    

}
