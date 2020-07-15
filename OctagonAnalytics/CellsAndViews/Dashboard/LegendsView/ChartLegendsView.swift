//
//  ChartLegendsView.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/4/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ChartLegendsView: UIView {
    private var finishedLoadingInitialTableCells = false

    static let CellIdentifier = String(describing: ChartLegendTableViewCell.self)
    
    @IBOutlet var tableView: UITableView!
    private var legends: [ChartLegendType] = []
    var onSelect: ((ChartLegendType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupTable()
    }
    
    func setLegends(_ legends: [ChartLegendType]) {
        finishedLoadingInitialTableCells = false
        self.legends = legends
        tableView.reloadData()
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
        cell.selectionStyle = .none
        if let legendCell = cell as?  ChartLegendTableViewCell {
            legendCell.legend = legends[indexPath.row]
            legendCell.bgColor = backgroundColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect?(legends[indexPath.row])
    }
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        var lastInitialDisplayableCell = false

        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if legends.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }

        if !finishedLoadingInitialTableCells {

            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }

            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.rowHeight/2)
            cell.alpha = 0

            UIView.animate(withDuration: 1, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
}
