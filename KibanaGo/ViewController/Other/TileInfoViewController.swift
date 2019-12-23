//
//  TileInfoViewController.swift
//  KibanaGo
//
//  Created by Rameez on 1/16/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import AlamofireImage
import iCarousel

class TileInfoViewController: BaseViewController {

    var tileList: [Tile]    =   []
    var selectedTile: Tile?
    
    @IBOutlet var carouselView: iCarousel!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    private func setup() {
        
        title = selectedTile?.timestampString
        
        // setup carousel
        carouselView.dataSource = self
        carouselView.delegate = self
        carouselView.type = .coverFlow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let index = tileList.lastIndex { (tile) -> Bool in
            return tile.imageUrl == selectedTile?.imageUrl
        } ?? 0

        carouselView.scrollToItem(at: index, animated: false)
        carouselView.reloadData()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return []
    }
    
    override func leftBarButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension TileInfoViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return tileList.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        guard let holderView = Bundle.main.loadNibNamed(NibNames.tileCarouselView, owner: self, options: nil)?.first as? TileCarouselView else { return UIView() }
        holderView.frame = carouselView.bounds
        holderView.tile = tileList[index]
        return holderView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let tile = tileList[carousel.currentItemIndex]
        title = tile.timestampString

    }
    
}

extension TileInfoViewController {
    struct NibNames {
        static let tileCarouselView = "TileCarouselView"
    }
}
