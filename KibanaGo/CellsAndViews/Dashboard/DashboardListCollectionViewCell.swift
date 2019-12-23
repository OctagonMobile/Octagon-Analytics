//
//  DashboardListCollectionViewswift
//  KibanaGo
//
//  Created by Rameez on 1/21/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit

typealias ShowPopUpBlock = (_ rect: CGRect,_ text: String) -> Void

class DashboardListCollectionViewCell: UICollectionViewCell {
    
    /// Tap on info action block
    var showPopUpBlock: ShowPopUpBlock?
    
    /// Dashboard item to be shown on cell
    var dashboardItem: DashboardItem? {
        didSet {
            updateContent()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateSelectionColor()
        }
    }
    /// Title Label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Info Button
    @IBOutlet weak var infoButton: UIButton!
    
    /// Container view
    @IBOutlet weak var containerView: UIView!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        infoButton.imageView?.contentMode = .scaleAspectFit
        containerView.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    func updateUI() {
        // Reset background color
        titleLabel.style(CurrentTheme.textStyleWith(titleLabel.font.pointSize, weight: .regular))
        containerView.style(.roundCorner(5.0, 2.0, CurrentTheme.cellBackgroundColor))
        style(.shadow())
    }
    
    fileprivate func updateSelectionColor() {
        containerView.backgroundColor =  isHighlighted ? CurrentTheme.headerViewBackground : CurrentTheme.cellBackgroundColor
    }
    
    fileprivate func updateContent() {
        titleLabel.text = dashboardItem?.title
        let isEmpty = dashboardItem?.desc.isEmpty == true
        infoButton.isHidden = isEmpty
    }
    
    //MARK: Button Actions
    @IBAction func infoButtonAction(_ sender: Any) {
        
        guard let item = dashboardItem else  { return }
        let desc: String = item.desc.isEmpty == false ? item.desc : "No Description"
        showPopUpBlock?(infoButton.frame, desc)
    }
}
