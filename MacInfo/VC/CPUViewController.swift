//
//  DashboardViewController.swift
//  MacInfo
//
//  Created by Denis Dobanda on 21.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit
import SwiftSocket
import Charts

class CPUViewController: UIViewController, TCPConnectionMessageServiceAsync {
    
    private var cpuHistory = [(Double, Double)]() {
        didSet {
            updateHistory()
        }
    }
    
    @IBOutlet weak var cpuChartView: PieChartView!
    @IBOutlet weak var cpuHistoryView: LineChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppDelegate.addMessageDelegate(self)
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        AppDelegate.connection = nil
    }
    
    private func manageParsing(_ stringData: String) {
        let arr = stringData.split() { $0 == "\n" }
        for sub in arr {
            let s = String(sub)
            if s.first == "C" {
                parseCPU(String(s[s.index(s.startIndex, offsetBy: 2)...]))
            }
        }
    }
    
    private func parseCPU(_ data: String) {
        let arr = data.split() {$0 == "|"}
        let user = Double(String(arr[0]))! / 100.0
        let system = Double(String(arr[1]))! / 100.0
        let idle = Double(String(arr[2]))! / 100.0
        DispatchQueue.main.async { [weak self] in
            self?.setChart(dataPoints: ["User", "System", "Idle"], values: [user, system, idle])
            if let count = self?.cpuHistory.count, count >= 11 {
                self?.cpuHistory.removeFirst()
            }
            self?.cpuHistory.append((user, system))
        }
    }
    
    private func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: "\(dataPoints[i]) \(values[i]) %")
            dataEntries.append(dataEntry)
        }
        let set = PieChartDataSet(values: dataEntries, label: "CPU")
        set.colors = [UIColor.blue, UIColor.red, UIColor.gray]
        
        let data = PieChartData(dataSet: set)
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 2
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 0, weight: .light))
        data.setValueTextColor(.white)
        
        cpuChartView.data = data
        cpuChartView.highlightValues(nil)
    }
    
    private func updateHistory() {
        let values = (0..<cpuHistory.count).map() { (i) -> (ChartDataEntry, ChartDataEntry) in
                return (ChartDataEntry(x: Double(i), y: cpuHistory[i].0),
                        ChartDataEntry(x: Double(i), y: cpuHistory[i].1))
        }
        let userV = values.map() { $0.0 }
        let systemV = values.map() { $0.1 }
        
        let set1 = LineChartDataSet(values: userV, label: "User")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.setCircleColor(.blue)
        set1.lineWidth = 2
        set1.circleRadius = 1
        set1.fillAlpha = 65/255
        set1.fillColor = .blue
//        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        
        let set2 = LineChartDataSet(values: systemV, label: "System")
        set2.axisDependency = .left
        set2.setColor(.red)
        set2.setCircleColor(.red)
        set2.lineWidth = 2
        set2.circleRadius = 1
        set2.fillAlpha = 65/255
        set2.fillColor = .red
//        set2.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set2.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2])
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 0))
        
        cpuHistoryView.data = data
    }
    

    // MARK: - Deleagtion
    
    func TCPConnectionReceivedAsync(_ message: String) {
        manageParsing(message)
    }
    
    func TCPConnectionTerminatedAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        AppDelegate.removeMessageDelegate(self)
    }


}
