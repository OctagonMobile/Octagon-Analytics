//
//  VectorMapViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/16/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class VectorMapViewController: PanelBaseViewController {

    private var countryCodes: [String: String] = [:]

    @IBOutlet weak var worldMapView: WorldMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        readCountryCodes()
        
        worldMapView.tapActionBlock = { [weak self] (selectedCountryCode, countryName) in
            
            guard let strongSelf = self, let buckets = self?.panel?.buckets, let agg = self?.panel?.bucketAggregation else { return }
            let mappedCountryCode = self?.countryCodes.allKeysForValue(val: selectedCountryCode).first
            guard let selectedCountry = buckets.filter({ $0.key == mappedCountryCode }).first else { return }
            
            var dateComponant: DateComponents?
            if let selectedDates =  self?.panel?.currentSelectedDates,
                let fromDate = selectedDates.0, let toDate = selectedDates.1 {
                dateComponant = fromDate.getDateComponents(toDate)
            }
            
            let filter = FilterProvider.shared.createFilter(selectedCountry, dateComponents: dateComponant, agg: agg)
            
            if !Session.shared.containsFilter(filter) {
                strongSelf.selectFieldAction?(strongSelf, filter, nil)
            }
        }
        
        worldMapView.mapViewRegionChangeBlock = { [weak self] animated in
            guard let strongSelf = self else { return }
            self?.deselectFieldAction?(strongSelf)
        }
    }
    
    override func setupPanel() {
        super.setupPanel()
        
        headerview?.backgroundColor = CurrentTheme.cellBackgroundColor.withAlphaComponent(0.6)
        headerview?.style(.roundCorner(5.0, 0.0, .clear))
        worldMapView?.highlightedColor = CurrentTheme.worldMapColor

    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        guard let buckets = panel?.buckets else { return }
        
        let countriesToBeHighlighted = buckets.compactMap( { $0.key })
        let mappedCountryCodes = countriesToBeHighlighted.compactMap( { countryCodes[$0] } )
        worldMapView.countryToBeHighlighted = mappedCountryCodes
        worldMapView.refreshMapView()
    }
    
    private func readCountryCodes() {
        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "plist"),
        let codes = NSDictionary(contentsOf: url) as? [String: String] else { return }
        countryCodes = codes
    }
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

