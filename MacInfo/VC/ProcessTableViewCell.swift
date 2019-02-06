//
//  ProcessTableViewCell.swift
//  MacInfo
//
//  Created by Denis Dobanda on 22.10.18.
//  Copyright © 2018 Denis Dobanda. All rights reserved.
//

import UIKit

class ProcessTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel! { didSet { updateUI() } }
    @IBOutlet weak var cpuLabel: UILabel! { didSet { updateUI() } }
    @IBOutlet weak var memLabel: UILabel! { didSet { updateUI() } }
    
    var name: String? { didSet { updateUI() } }
    var cpu: Double? { didSet { updateUI() } }
    var mem: String? { didSet { updateUI() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func updateUI() {
        if let n = name, let l = nameLabel {
            l.text = n
        }
        if let c = cpu, let l = cpuLabel {
            l.text = "\(c) %"
        }
        if let m = mem, let l = memLabel {
            l.text = m
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
