//
//  VectorTimelineViewController.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit

class VectorTimelineViewController: UIViewController {
    
    @IBOutlet weak var worldMapView: WorldMapView!
    @IBOutlet weak var vectorMapView: VectorMapView!
    
    private var countryCodes: [String: String] = [:]
    private let colorsArray: [UIColor] = [.red, .blue, .cyan, .green, .magenta]
    let ranges:[ClosedRange<Int>] = [0...0, 1...50, 51...100, 101...150, 151...200]
    
    let hightlight = ["IT", "US", "JP", "CN", "CA", "DE", "GB", "IN", "AU", "KR", "AE", "RU", "ZA", "EC", "AR", "CO", "ES", "FR", "PR", "CH", "NL", "CL", "SE", "DK", "TR", "FI", "MX", "AT", "IE", "PL", "NO", "PE"]
    lazy var data = { return [
        VectorMapContainer(date: "01-01-2020", data: getRandomData()),
        VectorMapContainer(date: "01-02-2020", data: getRandomData()),
        VectorMapContainer(date: "01-03-2020", data: getRandomData()),
        VectorMapContainer(date: "01-04-2020", data: getRandomData()),
        VectorMapContainer(date: "01-05-2020", data: getRandomData()),
        VectorMapContainer(date: "01-06-2020", data: getRandomData())
        ].map { $0.reGroup(by: ranges) }
    }()
    
    func getRandomData() -> [VectorMap] {
        var data = [VectorMap]()
        for code in hightlight {
            let value = Float.random(in: 1..<200)
            data.append(VectorMap(countryCode: countryCodes[code] ?? "", value: value))
        }
        return data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        readCountryCodes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVectorMap()
    }
    
    private func setupVectorMap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.vectorMapView.set(regions: self.worldMapView.regionList,
                                   mapView: self.worldMapView.mapView)
            self.play()
        }
    }
    
    func play() {
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
            if index >= self.data.count {
                timer.invalidate()
                return
            }
            self.highlight(index: index)
            index += 1
        }
    }

    private func highlight(index: Int) {
        let content = data[index]
        var dataDict: [String: ([VectorMap], UIColor)] = [:]
        for (key, value) in content {
            guard let range = key.toRange, let index = ranges.firstIndex(of: range) else {
                continue
            }
            let color =  colorsArray[index]
            dataDict[key] = (value, color)
        }
        vectorMapView.highlight(dataDict)
    }
    
    private func readCountryCodes() {
        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "plist"),
            let codes = NSDictionary(contentsOf: url) as? [String: String] else { return }
        countryCodes = codes
    }
}
