//
//  MapTrackingViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/3/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import MapKit
import DTMHeatmap

class MapTrackingViewController: MapBaseViewController, UITableViewDataSource, UITableViewDelegate {

    fileprivate var trackingPanel: MapTrackingPanel? {
        return (panel as? MapTrackingPanel)
    }
    
    fileprivate var mapControlsView: MapTrackControlView?
    
    fileprivate var mapTrackingColors: [UIColor] = CurrentTheme.mapTrackingColors
    fileprivate var mapTrackingUserPathColors: [UIColor] = CurrentTheme.mapTrackingUserPathColors

    fileprivate var legendRowHeight: CGFloat = 40.0
    
    /// Slider Timestamp moving from
    fileprivate var previouslySelectedTimestamp: Date?

    //MARK:
    @IBOutlet weak var controlsHolderView: UIView!    
    @IBOutlet weak var pathListTableView: UITableView!
    @IBOutlet weak var pathListTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pathListHolderView: UIView!
    
    //MARK: Overridden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }
    
    override func setupPanel() {
        super.setupPanel()
        
        controlsHolderView.style(.roundCorner(5.0, 0.0, .clear))
        
        if mapControlsView == nil {
            initializeTrackControl()
        } else {
            mapControlsView?.reset()
        }
        
        // Remove all overlays/Annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        pathListHolderView.backgroundColor = CurrentTheme.cellBackgroundColor.withAlphaComponent(0.8)
        pathListHolderView?.style(.roundCorner(5.0, 0.0, .clear))
    }
    
    override func updatePanelContent() {
        
        // Remove all overlays/Annotations before redrawing
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        super.updatePanelContent()
        
        // Connect Coordinates with dotted line
        var colorIndex = 0
        for pathTracker in trackingPanel?.pathTrackersArray ?? [] {
            
            var locations = pathTracker.mapTrackPoints.compactMap({ $0.location?.coordinate })
            
//            var ccc = locations
            let polyline = MapTrackingPolyline(coordinates: &locations, count: locations.count)
            
            if colorIndex >= mapTrackingColors.count { colorIndex = 0 }
            polyline.color = mapTrackingColors[colorIndex]
            pathTracker.color = mapTrackingColors[colorIndex]
            pathTracker.userPathColor = mapTrackingUserPathColors[colorIndex]
            colorIndex += 1
            
            mapView.addOverlay(polyline)
        }

        // Create Circle overlays
        colorIndex = 0
        for pathTracker in trackingPanel?.pathTrackersArray ?? [] {
            if colorIndex >= mapTrackingColors.count { colorIndex = 0 }
            let color = mapTrackingColors[colorIndex]
            for (index,track) in pathTracker.mapTrackPoints.enumerated() {
                guard let coordinate = track.location?.coordinate else { continue }
                let circle  = MapTrackingCircle(center: coordinate, radius: 50)
                circle.isFirstCircle = (index == 0)
                circle.isLastCircle = (index == pathTracker.mapTrackPoints.count - 1)
                circle.color = color
                mapView.addOverlay(circle)
            }
            colorIndex += 1
        }
        
        //Update Track Controls View
        mapControlsView?.mapTrackPanel = trackingPanel
        
        if let firstTimestamp = trackingPanel?.sortedTracks.first?.timestamp {
            previouslySelectedTimestamp = firstTimestamp
            updateUsersAnnotationIfExist(firstTimestamp)
        }
        
        // Zoom in/out to show all coordinates overlays
        let circleOverlays = mapView.overlays.filter({ $0 is MKCircle })
        if let first = circleOverlays.first {
            
            let rect = circleOverlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
        }

        pathListTableView.reloadData()
        let isSelected = pathListTableHeightConstraint.constant > 0
        updateLegendView(isSelected: isSelected)

    }
    
    //MARK: Private Methods
    
    private func initializeTrackControl() {
        mapControlsView = Bundle.main.loadNibNamed(NibName.mapTrackControlView, owner: self, options: nil)?.first as? MapTrackControlView
        guard let mapControlsView = mapControlsView else { return }
        mapControlsView.frame = controlsHolderView.bounds
        mapControlsView.translatesAutoresizingMaskIntoConstraints = false
        mapControlsView.timestampSelectionUpdateBlock = { [weak self] (sender, selectedTimestamp) in
            self?.updateUsersAnnotationIfExist(selectedTimestamp)
        }
        mapControlsView.listButtonActionBlock = { [weak self] (sender, isSelected) in
            self?.updateLegendView(isSelected: isSelected)
        }
        controlsHolderView.addSubview(mapControlsView)
        
        //Constraints
        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["controlsHolderView": controlsHolderView, "mapControlsView": mapControlsView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[mapControlsView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mapControlsView]-0-|", options: [], metrics: nil, views: views)
        controlsHolderView.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
    
    private func updateLegendView(isSelected: Bool) {
        pathListTableHeightConstraint.constant = isSelected ? calculatedLegendListHeight() : 0.0
        if isSelected { pathListHolderView.isHidden = false }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.displayContainerView.layoutIfNeeded()
        }, completion: { (completed) in
            if !isSelected { self.pathListHolderView.isHidden = true }
        })
    }
    
    private func calculatedLegendListHeight() -> CGFloat {
        
        var calculatedHeight = CGFloat(trackingPanel?.pathTrackersArray.count ?? 0) * legendRowHeight
        if calculatedHeight > view.frame.height {
            calculatedHeight = view.frame.height
        }
        return calculatedHeight
    }
    
    /// Used to update the user annotation for all paths
    private func updateUsersAnnotationIfExist(_ selectedTimestamp: Date) {

        DLog("\n**** selectedTimestamp = \(selectedTimestamp)***")
        var colorIndex = 0
        for path in (trackingPanel?.pathTrackersArray ?? []) {
            

            guard let pinAnnotation = path.getPinAnnotation(), let pointAnnotation = pinAnnotation.annotation as? UserPointAnnotation else { continue }

            if colorIndex >= mapTrackingColors.count { colorIndex = 0 }
            pointAnnotation.color = mapTrackingColors[colorIndex]
            colorIndex += 1

            
            guard let prevSelectedTimestamp = previouslySelectedTimestamp else {
                mapView.removeOverlays(path.userTraversedPathOverlays)
                path.userTraversedPathOverlays.removeAll()
                continue
            }
            
            let isForward = selectedTimestamp > prevSelectedTimestamp
            DLog("Color Index = \(colorIndex)")

            var filteredMapTrackPointsArray = path.mapTrackPoints.compactMap { (mapTrack) -> MapTrackPoint? in
                
                guard let timestamp = mapTrack.timestamp, let currentUserTimestamp = path.userCurrentPositionPoint?.timestamp else { return nil }
                if isForward {
                    return timestamp >= currentUserTimestamp && timestamp <= selectedTimestamp ? mapTrack : nil
                } else {
                    return timestamp <= currentUserTimestamp && timestamp >= selectedTimestamp ? mapTrack : nil
                }
            }
            
            
            if isForward {
                filteredMapTrackPointsArray =  Array(filteredMapTrackPointsArray.dropFirst())
                drawUserPath(path, toPointList: filteredMapTrackPointsArray)
            } else {
                path.userCurrentPositionPoint = filteredMapTrackPointsArray.first
                filteredMapTrackPointsArray =  Array(filteredMapTrackPointsArray.dropFirst())
                removeUserPath(path, filteredPointArray: filteredMapTrackPointsArray)
            }

            if let annotationNewPoint = path.userCurrentPositionPoint, let coordinate = annotationNewPoint.location?.coordinate {
                pointAnnotation.mapTrack = annotationNewPoint
                pointAnnotation.coordinate = coordinate
            }

            // Add/Remove Annotation
            if let firstTimeStampOfPath = path.mapTrackPoints.first?.timestamp,
                selectedTimestamp >=  firstTimeStampOfPath,
                !isAnnotationAlreadyAdded(pointAnnotation) {
                mapView.addAnnotation(pointAnnotation)
            } else if let firstTimeStampOfPath = path.mapTrackPoints.first?.timestamp,
                selectedTimestamp < firstTimeStampOfPath, isAnnotationAlreadyAdded(pointAnnotation) {
                mapView.removeAnnotation(pointAnnotation)
            }
        }
        
        previouslySelectedTimestamp = selectedTimestamp
        DLog("\n\n\n")
    }
    
    func drawUserPath(_ path: MapPath, toPointList: [MapTrackPoint]) {
        
        for (_ , movedPoint) in toPointList.enumerated() {
            guard let fromLoacation = path.userCurrentPositionPoint?.location, let toLocation = movedPoint.location,
            fromLoacation != toLocation else { continue }
            
            var locations: [CLLocationCoordinate2D] = [fromLoacation.coordinate, toLocation.coordinate]
            let polyline = MapTrackingPolyline(coordinates: &locations, count: locations.count)
            polyline.userPathColor = path.userPathColor ?? CurrentTheme.darkBackgroundColor
            polyline.isUserPath = true
            path.userTraversedPathOverlays.append(polyline)
            mapView.addOverlay(polyline)
            path.userCurrentPositionPoint = movedPoint
        }
    }
    
    func removeUserPath(_ path: MapPath, filteredPointArray: [MapTrackPoint]) {
        
        for _ in 0..<filteredPointArray.count {
            
            let lastItemIndex = path.userTraversedPathOverlays.count - 1
            if lastItemIndex >= 0 {
                mapView.removeOverlay(path.userTraversedPathOverlays[lastItemIndex])
                path.userTraversedPathOverlays = Array(path.userTraversedPathOverlays.dropLast())
            }
        }
    }
    
    private func isAnnotationAlreadyAdded(_ pointAnnotation: UserPointAnnotation) -> Bool {
        
        let isAlreadyAdded = mapView.annotations.contains { (annotation) -> Bool in
            return (annotation as? UserPointAnnotation)?.identifier == pointAnnotation.identifier
        }
        return isAlreadyAdded
    }
}

extension MapTrackingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            if let mapTrackingCircle = overlay as? MapTrackingCircle {
                circleRenderer.alpha = mapTrackingCircle.fillAlpha
                circleRenderer.lineWidth = mapTrackingCircle.strokeLineWidth
                circleRenderer.fillColor = mapTrackingCircle.fillColor
                circleRenderer.strokeColor = mapTrackingCircle.strokeColor
            }
            return circleRenderer
            
        } else if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.lineWidth = 4
            if (overlay as? MapTrackingPolyline)?.isUserPath == false {
                polylineRenderer.lineDashPattern = [12, 10]
                polylineRenderer.strokeColor = (overlay as? MapTrackingPolyline)?.color ?? CurrentTheme.darkBackgroundColor
            } else {
                polylineRenderer.strokeColor = (overlay as? MapTrackingPolyline)?.userPathColor ?? CurrentTheme.darkBackgroundColor
            }

            return polylineRenderer
            
        } else {
            if overlay is DTMHeatmap {
                return DTMHeatmapRenderer(overlay: overlay)
            }
            
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer

        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = MapPath.CellIdetifiers.pinCellId
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MapTrackingAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        if let userAnnotation = annotation as? UserPointAnnotation {
            (annotationView as? MapTrackingAnnotationView)?.annotationBackgroundColor = userAnnotation.color
        }
        return annotationView
        
    }

    // MARK: TableView Datasource, Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackingPanel?.pathTrackersArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackingPathListCell, for: indexPath) as? TrackingPathListCell else { return UITableViewCell() }
        cell.mapPath = trackingPanel?.pathTrackersArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return legendRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMapPath = trackingPanel?.pathTrackersArray[indexPath.row]
        guard let fieldName = visState?.userField, let fieldValue = selectedMapPath?.userIdentifier else { return }
        let selectedFilter = MapFilter(fieldName: fieldName, fieldValue: fieldValue)
        if !Session.shared.containsFilter(selectedFilter) {
            filterAction?(self, selectedFilter)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension MapTrackingViewController {
    
    struct NibName {
        static let mapTrackControlView = "MapTrackControlView"
    }
    
    struct CellIdentifier {
        static let trackingPathListCell = "TrackingPathListCell"
    }
}

//MARK: TrackingPathListCell

class TrackingPathListCell: UITableViewCell {
    
    var mapPath: MapPath? {
        didSet {
            setupCell()
        }
    }
    
    @IBOutlet weak var colorCircleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK:
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.style(CurrentTheme.caption2TextStyle())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorCircleView.style(.roundCorner(colorCircleView.frame.width/2, 0.0, .clear))
    }
    
    private func setupCell() {
        titleLabel.text = mapPath?.userIdentifier
        colorCircleView.backgroundColor = mapPath?.color

    }
}

class MapTrackingPolyline: MKPolyline {
    var color: UIColor = CurrentTheme.darkBackgroundColor
    var userPathColor: UIColor = CurrentTheme.darkBackgroundColor
    var isUserPath: Bool = false
}

class MapTrackingCircle: MKCircle {
    var isFirstCircle: Bool = false
    var isLastCircle: Bool = false
    var color: UIColor = CurrentTheme.darkBackgroundColor

    //MARK: Read Only Properties
    var fillColor: UIColor {
        if isFirstCircle { return color }
        else if isLastCircle { return UIColor.white }
        else { return CurrentTheme.darkBackgroundColor }
    }
    
    var strokeColor: UIColor? {
        if isFirstCircle { return UIColor.white }
        else if isLastCircle { return color }
        else { return nil }
    }
    
    var fillAlpha: CGFloat {
        return (isFirstCircle || isLastCircle) ? 1.0 : 0.8
    }

    var strokeLineWidth: CGFloat {
        return (isFirstCircle || isLastCircle) ? 3.0 : 0.0
    }
}
