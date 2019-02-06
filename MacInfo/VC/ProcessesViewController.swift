//
//  ProcessesViewController.swift
//  MacInfo
//
//  Created by Denis Dobanda on 22.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ProcessesViewController: UIViewController, TCPConnectionMessageServiceAsync, UITableViewDataSource {

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    
    @IBOutlet weak var table: UITableView!
    
    private var processes = [(String, Double, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.addMessageDelegate(self)
        table.dataSource = self
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        AppDelegate.connection = nil
    }
    
    private func manageParsing(_ stringData: String) {
        let arr = stringData.split() { $0 == "\n" }
        for sub in arr {
            let s = String(sub)
            if s.first == "P" {
                parseProc(String(s[s.index(s.startIndex, offsetBy: 2)...]))
            } else if s.first == "L" {
                parseProcs(String(s[s.index(s.startIndex, offsetBy: 2)...]))
            }
            
        }
    }
    
    private func parseProc(_ data: String) {
        let arr = data.split() {$0 == "|"}
        let total = Int(String(arr[0]))!
        let running = Int(String(arr[1]))!
        let sleeping = Int(String(arr[2]))!
        let threads = Int(String(arr[3]))!
        DispatchQueue.main.async { [weak self] in
            self?.firstLabel.text = "\(total) total"
            self?.secondLabel.text = "\(running) running"
            self?.thirdLabel.text = "\(sleeping) sleeping"
            self?.fourthLabel.text = "\(threads) threads"
//            if let pr = self?.processes {
//                for i in 0..<pr.count {
////                    self?.table.beginUpdates()
////                    self?.table.deleteRows(at: [IndexPath(row: i, section: 0)], with: .fade)
////                    self?.table.endUpdates()
//
//                }
//            }
            self?.processes.removeAll()
            self?.table.reloadData()
        }
    }
    
    private func parseProcs(_ data: String) {
        let arr = data.split() {$0 == "|"}
        if arr.count != 4 {return}
//        let pid = Int(String(arr[0]))!
        let name = String(arr[1])
        let cpu = Double(String(arr[2]))!
        let mem = String(arr[3])
        DispatchQueue.main.async { [weak self] in
//            self?.table.beginUpdates()
            self?.processes.append((name, cpu, mem))
//            self?.table.insertRows(at: [IndexPath(row: self!.processes.count - 1, section: 0)], with: UITableView.RowAnimation.bottom)
//            self?.table.endUpdates()
            self?.table.reloadData()
        }
    }
    
    // MARK: - Delegates
    
    func TCPConnectionReceivedAsync(_ message: String) {
        manageParsing(message)
    }
    
    func TCPConnectionTerminatedAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        AppDelegate.removeMessageDelegate(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return processes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Process Cell", for: indexPath)
        if let c = cell as? ProcessTableViewCell {
            let p = processes[indexPath.row]
            c.name = p.0
            c.cpu = p.1
            c.mem = p.2
        }
        return cell
    }
    
}
