//
//  DropDownPopOverViewController.swift
//  KibanaGo
//
//  Created by Rameez on 3/29/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

struct DropDownItem {
    var identifier: String
    var name: String
    
    init(dict: [String: Any]) {
        self.identifier = dict["identifier"] as? String ?? ""
        self.name       = dict["name"] as? String ?? ""
    }
}

class DropDownPopOverViewController: BaseViewController {
    
    public typealias DidSelectDropDownItem = (_ selectedItem: DropDownItem) -> Void
    
    var didSelectDropDown: DidSelectDropDownItem?
    
    @IBOutlet weak var dropDownTableView: UITableView!
    fileprivate var dataSource: [DropDownItem] = []
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dropDownTableView.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)
        loadDropDownMenuItems()
        self.preferredContentSize = CGSize(width: preferredContentSize.width, height: CGFloat(dataSource.count * 50)) 
    }


    private func loadDropDownMenuItems() {
        
        guard let url = Bundle.main.url(forResource: "DropDownMenu", withExtension: "plist"),
        let menuItems = NSArray(contentsOf: url) as? [[String: Any]] else { return }
        
        for item in menuItems {
            let dropDownItem = DropDownItem(dict: item)
            
            guard keyCloakEnabled else {
                dataSource.append(dropDownItem)
                continue
            }
            
            if dropDownItem.identifier == "Logout" {
                dataSource.append(dropDownItem)
            }
        }
    }

}

extension DropDownPopOverViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.dropDownCellIdentifier, for: indexPath) as? DropDownTableViewCell else { return UITableViewCell() }
        cell.dropDownItem = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = dataSource[indexPath.row]
        didSelectDropDown?(selectedItem)
    }
}

extension DropDownPopOverViewController {
    struct CellIdentifiers {
        static let dropDownCellIdentifier = "DropDownCellIdentifier"
    }
}
class DropDownTableViewCell: UITableViewCell {
    
    var dropDownItem: DropDownItem? {
        didSet {
            setupCell()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        nameLabel.style(CurrentTheme.bodyTextStyle())
    }
    
    private func setupCell() {
        nameLabel.text = dropDownItem?.name.localiz()
    }
}


