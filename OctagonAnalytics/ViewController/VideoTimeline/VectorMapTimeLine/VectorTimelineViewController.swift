//
//  VectorTimelineViewController.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit
import TGPControls
import ReplayKit

enum VectorMapVideoState {
    case notStarted
    case play
    case pause
}
class VectorTimelineViewController: VideoTimelineBaseViewController, CountryGeoJsonParser {
    
    @IBOutlet weak var vectorMapView: VectorMapView!
    @IBOutlet weak var legendsBaseView: UIView!
    @IBOutlet weak var mapBaseView: UIView!
    var vectorBase: VectorMapBaseView!

    private var legendsView: ChartLegendsView!
    private var countryCodes: [String: String] = [:]
    private var ranges: [ClosedRange<Int>] = []
    private var state: VectorMapVideoState = .notStarted
    private var timeInterVal: TimeInterval =  0.4
    private var deviceRotated: Bool = false
    private var regionList: [WorldMapVectorRegion] = []
    private lazy var data: [[String: [VectorMap]]]  = {
        var index = 0
        return correct().map {
            defer {
                index += 1
            }
           return $0.reGroup(by: ranges)
        }
    }()
    var vectorMapData: [VectorMapContainer]! {
        didSet {
            if !vectorMapData.isEmpty {
                calculateRanges()
            }
        }
    }

    
    func correct() -> [VectorMapContainer] {
         readCountryCodes()
        var containers = [VectorMapContainer]()
        for container in vectorMapData {
            var correctedList = [VectorMap]()
            for map in container.data {
                var corrected = map
                let filtered = countryCodeArray.filter {
                    let country = ($0["country"]!).lowercased().replacingOccurrences(of: " ", with: "_")
                    return country == map.countryCode
                }
                if let code = filtered.first?["code"] {
                    corrected.countryCode = countryCodes[code] ?? code
                    correctedList.append(corrected)
                }
            }
            containers.append(VectorMapContainer(date: container.date, data: correctedList))
        }
        return containers
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        regionList = readCountryGeoJson()
        addVectorBaseMapView()
        NotificationCenter.default.addObserver(self, selector: #selector(VectorTimelineViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        setupView()
        setupSliders()
        
        self.colors = CurrentTheme.barChartRaceColors(5)
        readCountryCodes()
        addLegendView()
        updatePlayButton(.play)
        dateLabel.textColor = CurrentTheme == .dark ?  .black : .white 
    }
    
    func addVectorBaseMapView() {
        vectorBase = UINib.init(nibName: String(describing: VectorMapBaseView.self), bundle: nil).instantiate(withOwner: self, options: nil).first as? VectorMapBaseView
        mapBaseView.addSubview(vectorBase!)
        vectorBase?.translatesAutoresizingMaskIntoConstraints = false
        vectorBase?.fillSuperView()
        view.sendSubviewToBack(vectorBase!)
        
    }

    @objc
    func rotated() {
        deviceRotated = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            reset()
        }
    }

    func mapViewOnLayout() {
        if UIDevice.current.userInterfaceIdiom == .phone && deviceRotated {
            deviceRotated = false
            reset()
        }
    }
    
    func reset() {
        var videoPaused = false
        if state == .play {
            pauseVideo()
            videoPaused = true
        }
        self.vectorMapView.reset()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.vectorMapView.createRegions()
            if videoPaused {
                self.playVideo()
            }
        }
    }
    private func calculateRanges() {
        let totalRange = 5
        
        var lowerBound = Int.max
        var upperBound = Int.min
        
        for container in  vectorMapData {
            for vectorMap in container.data {
                let value = Int(vectorMap.value)
                if value > upperBound {
                    upperBound = value
                }
                if value < lowerBound && value > 0 {
                    lowerBound = value
                }
            }
        }
        
        let interval = (upperBound-lowerBound)/totalRange
        var totalRanges = [ClosedRange<Int>]()
        for currentIndex in 0..<totalRange {
            var currentUppedBound = (lowerBound + interval - 1)
            if currentIndex == (totalRange - 1) {
                currentUppedBound = upperBound
            }
            totalRanges.append(lowerBound...currentUppedBound)
            lowerBound = lowerBound + interval
        }
        ranges = totalRanges
            
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupVectorMap()
    }
    
    private func addLegendView() {
        legendsView = UINib.init(nibName: String(describing: ChartLegendsView.self), bundle: nil).instantiate(withOwner: self, options: nil).first as? ChartLegendsView
        legendsView.setColor(.clear)
        legendsBaseView.addSubview(legendsView)
        legendsView.translatesAutoresizingMaskIntoConstraints = false
        legendsView.fillSuperView()
    }    
    
    private func setupVectorMap() {
        zoomToRegion {
            self.vectorMapView.set(regions: self.regionList/*[zoomRegion]*/,
                                   mapView: self.vectorBase.mapView)
            self.play()
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.vectorMapView.set(regions: self.worldMapView.regionList,
//                                   mapView: self.vectorBase.mapView)
//
//            self.play()
//        }
    }
    
    func zoomToRegion(onComplete: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
        return
        let zoomTo = "United States"
        var zoomRegion = WorldMapVectorRegion(name: zoomTo,
                                              code: nil,
                                              polygonSet: [])
        
        for region in self.regionList {
            if region.name?.lowercased() == zoomTo.lowercased() {
                zoomRegion = region
                break
            }
        }
        
        vectorBase.zoomTo(zoomRegion, worldRegions: self.regionList) {
            onComplete()
        }
    }

    
    func play() {
        state = .play
        let rangeColorDict = Dictionary(uniqueKeysWithValues: zip(ranges.map{$0.toString}, colors))
        updateLegends(rangeColorDict)
        if currentIndex >= data.count {
            currentIndex = 0
        }
        timer = Timer.scheduledTimer(withTimeInterval: timeInterVal, repeats: true) { (timer) in
            if self.currentIndex >= self.data.count {
                timer.invalidate()
                self.state = .notStarted
                if self.recorder.isRecording {
                    self.stopRecording()
                }
                self.updatePlayButton(self.state)
                return
            }
            self.highlight(index: self.currentIndex)
            self.currentIndex += 1
        }
    }

    func stop() {
        timer?.invalidate()
        currentIndex = 0
        state = .notStarted
    }
    
    
    private func highlight(index: Int) {
        let content = data[index]
        dateLabel.text = vectorMapData[index].date.stringVal()
        let rangesList = ranges
        var dataDict: [String: ([VectorMap], UIColor)] = [:]
        var rangesIncluded = [String: UIColor]()
        for (key, value) in content {
            var rangeIndex = 0
            for current in 0..<rangesList.count {
                if rangesList[current].toString == key {
                    rangeIndex = current
                    break
                }
            }
            let color =  colors[rangeIndex]
            dataDict[key] = (value, color)
            rangesIncluded[key] = color
        }
        vectorMapView.highlight(dataDict)
//        updateLegends(rangesIncluded)
    }
    
    private func readCountryCodes() {
        guard let url = Bundle.main.url(forResource: "CountryCodes", withExtension: "plist"),
            let codes = NSDictionary(contentsOf: url) as? [String: String] else { return }
        countryCodes = codes
    }
    
    private func updateLegends(_ ranges: [String: UIColor]) {
        var chartLegends = [ChartLegend]()
        for (range, color) in ranges {
            chartLegends.append(ChartLegend.init(text: range, color: color, shape: .rect(width: 25, height: 20)))
        }
        chartLegends.sort {
            return ($0.text.toRange?.upperBound ?? 0) < ($1.text.toRange?.upperBound ?? 0)
        }
        legendsView?.setLegends(chartLegends)
    }
    
    @IBAction func buttonTapped(_ button: UIButton) {
        updateState()
    }
    
    func updateState() {
        switch state {
        case .notStarted:
            play()
        case .play:
            timer?.invalidate()
            state = .pause
        case .pause:
            play()
        }
        updatePlayButton(state)
    }
    
    func updatePlayButton(_ state: VectorMapVideoState) {
        var playButtonTitle = (state == .play) ? "videoPause" : "videoPlay"
        playButtonTitle += CurrentTheme.isDarkTheme ? "-Dark" : "-Light"
        playButton.setImage(UIImage(named: playButtonTitle), for: .normal)
    }
    
   //Overridden Methods
    override func speedUpdated() {
        timeInterVal = TimeInterval(speed)
        if state == .play {
            pauseVideo()
            playVideo()
        }
        vectorMapView.currentSpeed = TimeInterval(speed)
    }
    override func recordingStarted() {
        currentIndex = 0
        self.play()
    }
    
    override func recordingStopped() {
        stop()
    }
    
    override func pauseVideo() {
        timer?.invalidate()
        state = .pause
    }
    
    override func playVideo() {
        self.play()
    }
    
    override func stopVideo() {
        stop()
    }
    
    override func controlsToggled() {
        
    }
    
    //Deinit
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
