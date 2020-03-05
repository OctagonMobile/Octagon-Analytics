//
//  BaseHeatMapViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/23/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import AMPopTip
import DTMHeatmap

class BaseHeatMapViewController: MapBaseViewController {

    typealias ShouldEnableDashboardScrolling = (_ enable: Bool) -> Void

    @IBOutlet weak var filterOverlayView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var drillDownButton: UIButton!

    internal var mapPanel: HeatMapPanel? {
        return (panel as? HeatMapPanel)
    }

    internal var precision: Int {
        return mapPanel?.bucketAggregation?.params?.precision ?? 5
    }

    var enableDashboardScrolling: ShouldEnableDashboardScrolling?
    internal var resizableView: SPUserResizableView?
    internal let popTip = PopTip()

    ///Minimum distance required to consider the tap point to marked location on map (In Meters)
    internal var minimumDistanceForTap: Double = 100.0
    
    /// True if edit mode is ON (Defaulat value Off)
    internal var editMode: Bool = false {
        didSet {
            filterEditModeUpdated()
        }
    }
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        //Setup Pop tip
        popTip.bubbleColor = .clear
        
        configureFilterView()
        
    }

    override func setupPanel() {
        super.setupPanel()
        let theme = CurrentTheme
        filterButton.backgroundColor = theme.cellBackgroundColor
        drillDownButton.backgroundColor = theme.cellBackgroundColor
        
        filterButton.style(.roundCorner(5.0, 0.0, .clear))
        drillDownButton.style(.roundCorner(5.0, 0.0, .clear))
        
        filterButton.style(.shadow())
        drillDownButton.style(.shadow())
        
        if let zoom = mapPanel?.zoomForPrecision(precision) {
            mapView.setCenterCoordinate(coordinate: mapView.centerCoordinate, zoomLevel: zoom, animated: false)
        }

    }
    
    override func handleResponse(_ result: Any?) {
        guard let _ =  result as? [Any] else {
            updatePanelContent()
            return
        }
        
        hideNoItemsAvailable()
        
        shouldLoadData = false
        updatePanelContent()
    }
    
    //MARK: Actions
    @IBAction func drillDownButtonAction(_ sender: Any) {
        editMode = false
        
        if !editMode {
            // Saved
            calculateSelectedBoundingRectAndApplyFilter()
        }
    }
    
    @IBAction func filtetButtonAction(_ sender: UIButton) {
        editMode = !editMode
    }

}

extension BaseHeatMapViewController {
    internal func markedLocation(closestToLocation location: CLLocation) -> MapDetails? {
        
        guard let mapDetailsArray = (panel as? HeatMapPanel)?.mapDetail else { return nil }
        
        var closestmapDetail: MapDetails?
        var smallestDistance: CLLocationDistance = minimumDistanceForTap
        
        for mapDetail in mapDetailsArray {
            guard let distance = mapDetail.location?.distance(from: location), distance <= smallestDistance else { continue }
            
            closestmapDetail = mapDetail
            smallestDistance = distance
        }
        
        DLog("closestLocation: \(String(describing: closestmapDetail?.location)), distance: \(smallestDistance)")
        
        return closestmapDetail
    }
    
    internal func configureFilterView() {
        let frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        resizableView = SPUserResizableView(frame: frame)
        resizableView?.borderColor = CurrentTheme.cellBackgroundColor
        resizableView?.holderColor = CurrentTheme.enabledStateBackgroundColor
        resizableView?.showEditingHandles()
        resizableView?.delegate = self
        let resizableContentView = UIView(frame: frame)
        resizableContentView.backgroundColor = CurrentTheme.enabledStateBackgroundColor.withAlphaComponent(0.4)
        resizableView?.contentView = resizableContentView
        if let resizable = resizableView {
            filterOverlayView.addSubview(resizable)
        }
    }
    
    internal func filterEditModeUpdated() {
        
        filterOverlayView.isHidden = !editMode
        
        let imageName = editMode ? "MapFilter-Edit" : "MapFilter-Normal"
        filterButton.setImage(UIImage(named: imageName), for: .normal)

        filterButton.backgroundColor = editMode ? CurrentTheme.enabledStateBackgroundColor : CurrentTheme.cellBackgroundColor
        
        let endAlpha: CGFloat = editMode ? 1.0 : 0.0
        let startAlpha: CGFloat   = editMode ? 0.0 : 1.0
        
        if editMode {
            self.drillDownButton.isHidden = false
        }
        drillDownButton.alpha = startAlpha
        UIView.animate(withDuration: 0.3, animations: {
            self.drillDownButton.alpha = endAlpha
        }) { (completed) in
            if !self.editMode {
                self.drillDownButton.isHidden = true
            }
        }
    }

    internal func calculateSelectedBoundingRectAndApplyFilter() {
        guard let resizable = resizableView else { return }
        
        let frame = resizable.frame
        let topLeftPoint = CGPoint(x: frame.origin.x , y: frame.origin.y)
        let topRightPoint = CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y)
        let bottomLeftPoint = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height)
        let bottomRightPoint = CGPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height)
        
        let topLeftCoordinate = mapView.convert(topLeftPoint, toCoordinateFrom: filterOverlayView)
        let topRightCoordinate = mapView.convert(topRightPoint, toCoordinateFrom: filterOverlayView)
        let bottomLeftCoordinate = mapView.convert(bottomLeftPoint, toCoordinateFrom: filterOverlayView)
        let bottomRightCoordinate = mapView.convert(bottomRightPoint, toCoordinateFrom: filterOverlayView)
        
        guard let fieldName = panel?.bucketAggregation?.field, let bucketType = panel?.bucketType else { return }
        
        let rectangleCoordinate = LocationFilter.CoordinateRectangle(topLeft: topLeftCoordinate, topRight: topRightCoordinate, bottomLeft: bottomLeftCoordinate, bottomRight: bottomRightCoordinate)
        let selectedFilter = LocationFilter(fieldName: fieldName, type: bucketType, rectangle: rectangleCoordinate)
        if !Session.shared.containsFilter(selectedFilter) {
            selectFieldAction?(self, selectedFilter, nil)
        }
        
    }
    
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer)  {
        
        let tapPoint = gesture.location(in: mapView)
        let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        let tappedLocation = CLLocation(latitude: tapCoordinate.latitude, longitude: tapCoordinate.longitude)
        
        DLog("Tapped Coordinate = \(String(describing: tapCoordinate))")
        if let closest = markedLocation(closestToLocation: tappedLocation) {
            // Show pop up with details of closest location
            showLocationDetails(closest)
        }
    }

    internal func showLocationDetails(_ mapDetail: MapDetails) {
        
        guard let locationDetailsView = Bundle.main.loadNibNamed("LocationPopUpView", owner: self, options: nil)?.first as? LocationPopUpView else { return }
        locationDetailsView.setup(mapDetail)
        
        let spacing: CGFloat = 14.0
        // Originating frame is from the center (hence devide by 2)
        let xValue = (locationDetailsView.frame.width / 2) + spacing
        let yValue = mapView.frame.height - (locationDetailsView.frame.height / 2) - spacing
        let originatingFrame = CGRect(x: xValue , y: yValue, width: 0, height: 0)
        popTip.show(customView: locationDetailsView, direction: .none, in: mapView, from: originatingFrame)
    }

}

extension BaseHeatMapViewController: SPUserResizableViewDelegate {
    func userResizableViewDidBeginEditing(_ userResizableView: SPUserResizableView!) {
        // Disable scrolling
        enableDashboardScrolling?(false)
    }
    
    func userResizableViewDidEndEditing(_ userResizableView: SPUserResizableView!) {
        // Enable Scrolling
        enableDashboardScrolling?(true)
    }
    
}

extension BaseHeatMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Dismiss location details pop up if shown
        popTip.hide()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard let customMapView = (mapView as? CustomMapView) else { return }
        
        let oldPrecision = precision
        mapPanel?.updatePrecisionFor(customMapView.getZoom())
        let newPrecision = precision
        
        if oldPrecision != newPrecision {
            shouldLoadData = true
            loadChartData()
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is DTMHeatmap {
            return DTMHeatmapRenderer(overlay: overlay)
        }
        
        let renderer = MKTileOverlayRenderer(overlay: overlay)
        return renderer
    }
}

extension BaseHeatMapViewController {
    struct DoubleRange {
        var min: Double
        var max: Double
        
        init(min: Double, max: Double) {
            self.min = min
            self.max = max
        }
    }
    
    func convertToNewRange(_ value: Double, _ oldRange: DoubleRange, _ newRange: DoubleRange) -> Double {
        
        var oldRangeValue       = oldRange.max - oldRange.min
        if oldRangeValue <= 0 {
            oldRangeValue = 1
        }
        let newRangeValue       = newRange.max - newRange.min
        return (((value - oldRange.min) * newRangeValue) / oldRangeValue) + newRange.min
    }
}
