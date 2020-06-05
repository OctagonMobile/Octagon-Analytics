//
//  ChartLegendsView.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ChartLegendsView: UIView {
    
    static let CellIdentifier = String(describing: ChartLegendTableViewCell.self)
    
    @IBOutlet var tableView: UITableView!
    private var legends: [ChartLegendType] = []
    var onSelect: ((ChartLegendType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTable()
    }
    
    func setLegends(_ legends: [ChartLegendType]) {
        tableView.alpha = 0.0
        self.legends = legends
        tableView.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.tableView.alpha = 1.0
        }
    }
    
    func setupTable() {
        let cellNib = UINib.init(nibName: ChartLegendsView.CellIdentifier, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ChartLegendsView.CellIdentifier)
        tableView.separatorStyle = .none
    }
    
    func setColor(_ color: UIColor) {
        backgroundColor = color
        tableView.layer.backgroundColor = color.cgColor
        tableView.backgroundColor = color
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension ChartLegendsView: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChartLegendsView.CellIdentifier,
                                                 for: indexPath)
        if let legendCell = cell as? ChartLegendTableViewCell {
            legendCell.legend = legends[indexPath.row]
            legendCell.bgColor = backgroundColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect?(legends[indexPath.row])
    }
}
