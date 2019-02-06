//
//  SettingsViewController.swift
//  MacInfo
//
//  Created by Denis Dobanda on 22.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, TCPConnectionMessageServiceAsync {

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.addMessageDelegate(self)
    }

    @IBAction func shutDown(_ sender: UIButton) {
        _ = AppDelegate.connection!.send(string: "shut down")
    }
    
    func TCPConnectionReceivedAsync(_ message: String) {
        
    }
    
    func TCPConnectionTerminatedAsync() {
        AppDelegate.removeMessageDelegate(self)
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
}
