//
//  MapBaseViewController.swift
//  KibanaGo
//
//  Created by Rameez on 4/11/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import DTMHeatmap
import WMSKit

class MapBaseViewController: PanelBaseViewController {

    
    var wmsLayerPanel: WMSLayerProtocol? {
        return (panel as? WMSLayerProtocol)
    }
    
    var visState: MapVisState? {
        return (panel?.visState as? MapVisState)
    }
    
    @IBOutlet weak var mapView: KibanaGoMapView!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var layerSwitchHolder: LayerSwitchHolderView?
    
    /// Tile overlay view
    var overlay: WMSTileOverlay?
    
    var currentSelectedLayerName: String?
    
    /// Heat Map
    var heatMap: DTMHeatmap?

    var currentElement = ""
    var passName = false
    var layer = false
    var layers:[String] = []
    var activeLayers: [String: MKOverlay] = [:]

    //MARK:
    
    required init?(coder aDecoder: NSCoder) {
        self.overlay = WMSTileOverlay(urlArg: "", useMercator: true, wmsVersion: MapVisState.HeatMapServiceConstant.version)
        self.heatMap = DTMHeatmap()
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        displayContainerView.style(.shadow())
        mapView.style(.roundCorner(5.0, 0.0, .clear))

    }
    
    override func setupPanel() {
        super.setupPanel()
        
        headerview?.backgroundColor = CurrentTheme.cellBackgroundColor.withAlphaComponent(0.6)
        zoomInButton.backgroundColor = CurrentTheme.cellBackgroundColor
        zoomOutButton.backgroundColor = CurrentTheme.cellBackgroundColor
        layerSwitchHolder?.backgroundColor = .clear

        zoomInButton.style(.shadow())
        zoomOutButton.style(.shadow())

        zoomInButton.style(.roundCorner(5.0, 0.0, .clear))
        zoomOutButton.style(.roundCorner(5.0, 0.0, .clear))
        headerview?.style(.roundCorner(5.0, 0.0, .clear))
        layerSwitchHolder?.style(.roundCorner(5.0, 0.0, .clear))

    }
    
    override func loadChartData() {
        
        if let heatMap = heatMap {
            mapView.removeOverlay(heatMap)
        }
        
        super.loadChartData()
        loadLayers()
    }
    
    fileprivate func loadLayers() {
        
        let mapUrl = visState?.mapUrl
        wmsLayerPanel?.loadLayersWith(mapUrl: mapUrl, { [weak self] (result, error) in
            guard error == nil else {
                // Show the Error here
                DLog(error?.localizedDescription)
                self?.updatePanelContent()
                return
            }
            
            guard let data = result as? Data else { return }
            
            self?.handleResponse(data)
        })
    }

    private func handleResponse(_ data: Data) {
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            DLog("Failed to load layers")
            return
        }
        updatePanelContent()
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        if currentSelectedLayerName == nil {
            currentSelectedLayerName = (panel?.visState as? MapVisState)?.defaultLayerName
        }
        addWMSLayer(currentSelectedLayerName)
        
        layerSwitchHolder?.layers = (panel?.visState as? MapVisState)?.mapLayers ?? []
        layerSwitchHolder?.layerSwitchActionBlock = { [weak self] (sender, selectedLayer) in
            self?.currentSelectedLayerName = selectedLayer.layerName
            if let tileOverlay = self?.overlay, self?.layers.count ?? 0 > 0 {
                // Remove/Add overlay
                self?.mapView.removeOverlay(tileOverlay)
                self?.addWMSLayer(self?.currentSelectedLayerName)
            }
        }
        
        layerSwitchHolder?.loadDefaultBlock = { [weak self] (sender) in
            self?.loadDefaultLayer()
        }

    }
    
    private func loadDefaultLayer() {
        if let tileOverlay = overlay, layers.count > 0, let heatMapVisState = (panel?.visState as? MapVisState) {
            // Remove/Add overlay
            mapView.removeOverlay(tileOverlay)
            addWMSLayer(heatMapVisState.defaultLayerName)
        }
    }
    
    fileprivate func addWMSLayer(_ selectedLayer: String?) {
        
        guard let heatMapVisState = (panel?.visState as? MapVisState), let layerName = selectedLayer else { return }
        
        let referenceSystem = heatMapVisState.version == "1.1.1" ? "srs" : "crs"
        
        let urlLayers = "layers=\(layerName)&"

        let urlVersion = "version=\(heatMapVisState.version)&"
        let urlReferenceSystem = "\(referenceSystem)=EPSG:\(MapVisState.HeatMapServiceConstant.epsg)&"
        let urlWidthAndHeight = "width=\(MapVisState.HeatMapServiceConstant.tileSize)&height=\(MapVisState.HeatMapServiceConstant.tileSize)&"
        let urlFormat = "format=\(heatMapVisState.format)&"
        let urlTransparent = "transparent=\(heatMapVisState.transparent)"
        
        let urlString = heatMapVisState.mapUrl + "?&styles=&service=WMS&request=GetMap&" + urlLayers + urlVersion + urlReferenceSystem + urlWidthAndHeight + urlFormat + urlTransparent
        let useMercator = true
        
        //NOTE: wmsVersion is hardcoded since layers are placed properly with 1.1.1
        let overlay = WMSTileOverlay(urlArg: urlString, useMercator: useMercator, wmsVersion: "1.1.1")
        
        overlay.canReplaceMapContent = false
        
        if let heatLayer = heatMap {
            mapView.insertOverlay(overlay, below: heatLayer)
        } else {
            self.mapView.addOverlay(overlay)
            
        }
    }

    //MARK:
    @IBAction func zoomInAction(_ sender: UIButton) {
        
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta * 0.5 , longitudeDelta: mapView.region.span.longitudeDelta * 0.5)
        guard span.latitudeDelta >= 0.0 , span.longitudeDelta >= 0.0 else { return }
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOutAction(_ sender: UIButton) {
        
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta / 0.5 , longitudeDelta: mapView.region.span.longitudeDelta / 0.5)
        guard span.latitudeDelta <= 180.0 , span.longitudeDelta <= 180.0 else { return }
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }

}


extension MapBaseViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
        if elementName.lowercased() == "layer" || layer  {
            layer=true
            if elementName.lowercased() == "name" {
                passName=true;
                layer=false
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = ""
        if elementName.lowercased() == "layer" {
            layer = false
        }
        passName = false
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if passName {
            DLog(string)
            layers.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        DLog("failure error: \(parseError)")
    }
}
