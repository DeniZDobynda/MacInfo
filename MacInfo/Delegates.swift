//
//  Delegates.swift
//  MacInfo
//
//  Created by Denis Dobanda on 22.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import Foundation

public protocol TCPConnectionMessageServiceAsync {
    var hashValue: Int {get}
    
    func TCPConnectionReceivedAsync(_ message: String)
    func TCPConnectionTerminatedAsync()
}
