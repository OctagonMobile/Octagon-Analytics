//
//  BarChartRaceViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/15/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import BarChartRace
import SwiftDate
import TGPControls
import ReplayKit

class BarChartRaceViewController: BaseViewController {
    
    private let recorder = RPScreenRecorder.shared()

    var barData: [VideoContent] = []
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var controlsHolder: UIView!
    @IBOutlet weak var speedSlider: TGPDiscreteSlider!
    @IBOutlet weak var camelLabels: TGPCamelLabels!
    
    //MARK: Outlets
    @IBOutlet weak var barChartView: BasicBarChart!
    
    private var currentIndex: Int = 0
    private var timer: Timer?

    private var sliderValuesString: [String]  =   ["0.1x", "0.5x", "1x", "2x", "3x", "4x"]
    private var sliderValues: [Float]  =   [1.2, 0.9, 0.4, 0.3, 0.2, 0.1]
    private var speed: Float    =   0.4 {
        didSet {
            barChartView.timeInterval = TimeInterval(speed)
            if barChartView.playerState == .playing {
                barChartView.pause()
                barChartView.play()
            }
        }
    }
    //MARK: Funnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Bar Chart Video".localiz()
        navigationItem.rightBarButtonItems = rightBarButtons()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barChartView?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barChartView?.stop()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        guard !recorder.isRecording else {
            return []
        }
        return [UIBarButtonItem(image: UIImage(named: "export"), style: .plain, target: self, action: #selector(rightBarButtonAction(_ :)))]
    }

    override func leftBarButtons() -> [UIBarButtonItem] {
        if recorder.isRecording {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
            button.setTitle("0:00", for: .normal)
            button.addTarget(self, action: #selector(BarChartRaceViewController.stopRecordingButtonAction(_:)), for: .touchUpInside)
            button.layer.backgroundColor = UIColor.red.cgColor
            button.layer.cornerRadius = 5.0
            return [UIBarButtonItem(customView: button)]
        } else {
            return super.leftBarButtons()
        }
    }

    //MARK: Private Functions
    private func initialSetup() {
        view.backgroundColor = CurrentTheme.cellBackgroundColor
        controlsHolder.backgroundColor = CurrentTheme.lightBackgroundColor
        dateLabel.style(CurrentTheme.textStyleWith(dateLabel.font.pointSize, weight: .semibold))

        //setup speed slider
        speedSlider.thumbStyle = ComponentStyle.rounded.rawValue
        speedSlider.thumbSize  = CGSize(width: 20, height: 20)
        speedSlider.minimumTrackTintColor = CurrentTheme.standardColor
        speedSlider.maximumTrackTintColor = CurrentTheme.sliderTrackColor
        speedSlider.thumbTintColor = CurrentTheme.standardColor
        speedSlider.minimumValue = 0.0
        speedSlider.tickCount = sliderValuesString.count
        camelLabels.names = sliderValuesString
        camelLabels.upFontColor = CurrentTheme.standardColor
        camelLabels.downFontColor = CurrentTheme.sliderTrackColor
        camelLabels.upFontSize = 15
        camelLabels.downFontSize = 15
        speedSlider.ticksListener = camelLabels
        speedSlider.value = CGFloat(sliderValues.firstIndex(of: speed) ?? 0)
        camelLabels.value = UInt(speedSlider.value)
        speedSlider.addTarget(self, action: #selector(BarChartRaceViewController.speedSliderDragEnded(_:)), for: .touchUpInside)

        
        //setup bar chart race
        barChartView.delegate = self
        barChartView.backgroundColor = CurrentTheme.cellBackgroundColor
        barChartView.timeInterval = TimeInterval(speed)
        barChartView.titleColor = CurrentTheme.titleColor
        barChartView.valueColor = CurrentTheme.titleColor
        let dataSetList = barData.compactMap({ $0.barChartDataSet() })
        barChartView.setupBarChartRace(dataSetList, animated: true)
    }
    
    @objc override func rightBarButtonAction(_ sender: UIBarButtonItem) {
        guard !recorder.isRecording else { return }
        barChartView.pause()
        showOkCancelAlert("Export Video", "If you start to record the Video, please make sure to not interrupt it untill it finishes", okTitle: "Record", okActionBlock: {
            self.barChartView.stop()
            self.recording(true)
        }, cancelTitle: "Not Now") {
            self.barChartView.play()
        }
    }

    @objc func stopRecordingButtonAction(_ button: UIButton) {
        recording(false)
    }
    
    private func recording(_ state: Bool) {
        if state {
            guard recorder.isAvailable else { return }
            recorder.startRecording{ (error) in
                guard error == nil else { return }
                self.barChartView.play()
                self.updateNavigationBarItems()
            }
        } else {
            recorder.stopRecording { (preview, error) in
                guard let preview = preview else { return }
                self.updateNavigationBarItems()
                preview.modalPresentationStyle = .automatic
                preview.previewControllerDelegate = self

                self.present(preview, animated: true, completion: nil)
            }
        }
    }
    
    private func updateNavigationBarItems() {
        navigationItem.leftBarButtonItems = leftBarButtons()
        navigationItem.rightBarButtonItems = rightBarButtons()
    }

    //MARK: Button Actions
    @IBAction func playButtonAction(_ sender: UIButton) {
        if barChartView.playerState == .playing {
            barChartView.pause()
        } else {
            barChartView.play()
        }
    }
    
    @objc private func speedSliderDragEnded(_ sender: TGPDiscreteSlider) {
        guard Int(sender.value) <= sliderValues.count - 1 else { return }
        speed = sliderValues[Int(sender.value)]
    }
}

extension BarChartRaceViewController: BarChartRaceDelegate {
    
    func playerStateUpdated(_ state: BasicBarChart.PlayerState) {
        var playButtonTitle = (state == .playing) ? "videoPause" : "videoPlay"
        playButtonTitle += CurrentTheme.isDarkTheme ? "-Dark" : "-Light"
        playButton.setImage(UIImage(named: playButtonTitle), for: .normal)
        
        if state == .stopped, recorder.isRecording {
            recording(false)
        }
    }
    
    func currentDataSet(_ dataSet: DataSet, index: Int) {
        dateLabel.text = dataSet.date.toString(.custom("dd MMM yyyy"))
    }
}

extension BarChartRaceViewController : RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
