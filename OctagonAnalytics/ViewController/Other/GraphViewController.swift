//
//  GraphViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD

class GraphViewController: PanelBaseViewController {

    @IBOutlet weak var graphHolderView: UIView?
    
    fileprivate var presenter: WeightedGraphPresenter?

    fileprivate var graphPanel: GraphPanel? {
        return panel as? GraphPanel
    }
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        graphHolderView?.translatesAutoresizingMaskIntoConstraints = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.stop()
    }
    
    override func loadChartData() {
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.animationType = .zoomIn
        hud.contentColor = CurrentTheme.darkBackgroundColor

        graphPanel?.loadGraphData({ [weak self] (result, error) in
            hud.hide(animated: true)
            guard error == nil else {
                self?.updatePanelContent()
                if let errorDesc = error?.localizedDescription {
                    self?.showNoItemsAvailable(errorDesc)
                }
                return
            }
            
            guard let _ = result as? NeoGraph else { return }
            self?.hideNoItemsAvailable()
            self?.updatePanelContent()
        })
    }
    
    override func setupHeader() {
        super.setupHeader()
        flipButton?.setImage(UIImage(named: "TrackingPauseIcon"), for: .normal)
        flipButton?.setImage(UIImage(named: "TrackingPlayIcon"), for: .selected)
        self.flipButton?.isSelected = false
    }
    
    override func setupPanel() {
        super.setupPanel()
        
        presenter?.stop()
        setupGraphView([], edges: [])
    }
    
    override func updatePanelContent() {
        guard let graphObj = graphPanel?.graphData, let holderView = graphHolderView else { return }
        graphHolderView?.layoutIfNeeded()
        presenter?.radius = min(holderView.frame.width, holderView.frame.height) / 2

        let nodes = graphObj.nodesList.compactMap { (node) -> Int? in
            guard let id = node.id else { return nil }
            return Int(id)
        }
        let updatedNodesList = Set(nodes.map { $0 })
        
        let edges =  graphObj.edgesList.compactMap { (edge) -> Graph.Edge? in
            guard let start = edge.startNodeId, let end = edge.endNodeId,
                let sourceId = Int(start), let destId = Int(end)  else { return nil }
            
            let graphEdge = Graph.Edge(nodes: [sourceId,destId], weight: 0.5, sourceNode: sourceId, destNode: destId, edgeName: edge.type ?? "")
            return graphEdge
        }
        let updatedEdgesList = Set(edges.map { $0 })
        presenter?.stop()
        presenter?.graph = Graph(nodes: updatedNodesList, edges: updatedEdgesList)
        presenter?.start()
    }
    
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        presenter?.stop()
        setupGraphView([], edges: [])
        updatePanelContent()
    }
    
    override func flipButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            presenter?.stop()
        } else {
            presenter?.start()
        }
    }
    
    private func setupGraphView(_ nodes: Set<Int>, edges: Set<Graph.Edge>) {
        guard let holderView = graphHolderView else { return }
        
        holderView.subviews.forEach({ $0.removeFromSuperview() })
        let graph = Graph(nodes: nodes, edges: edges)
        presenter = WeightedGraphPresenter(graph: graph, view: holderView, delegate: self)
//        presenter?.showsHiddenNodeEdges = true
        presenter?.backgroundColor = .white
        presenter?.edgeColor = .lightGray
        presenter?.radius = min(holderView.frame.width, holderView.frame.height) / 2
        presenter?.centerAttraction = 5
        presenter?.start()
    }
}

extension GraphViewController: WeightedGraphPresenterDelegate {
    func view(for node: Int, presenter: WeightedGraphPresenter) -> UIView {
        guard let nodeView = Bundle.main.loadNibNamed(NibNames.graphNodeView, owner: self, options: nil)?.first as? GraphNodeView else { return UIView() }
        
        if let selectedNode = graphPanel?.graphData?.nodesList.filter({ $0.id == "\(node)"}).first {
            nodeView.imageBaseUrl = (graphPanel?.visState as? GraphVisState)?.nodeImageBaseUrl
            nodeView.setup(selectedNode)
        }
        return nodeView
    }
    
    func configure(view: UIView, for node: Int, presenter: WeightedGraphPresenter) {
    }
    
    func visibleRange(for node: Int, presenter: WeightedGraphPresenter) -> ClosedRange<Float>? {
        return (-Float.infinity ... Float.infinity)
    }
}

extension GraphViewController {
    struct NibNames {
        static let graphNodeView        = "GraphNodeView"
    }
}
