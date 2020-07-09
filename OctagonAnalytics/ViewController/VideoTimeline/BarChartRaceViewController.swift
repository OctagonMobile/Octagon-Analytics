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
    
    private var shouldHideControls: Bool     =   true
    private let recorder = RPScreenRecorder.shared()

    var videoConfig: VideoConfigContent?
    var barData: [VideoContent] = []
    @IBOutlet weak var recordIndicator: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var controlsHolder: UIView!
    @IBOutlet weak var speedSlider: TGPDiscreteSlider!
    @IBOutlet weak var camelLabels: TGPCamelLabels!
    @IBOutlet weak var controlsBottomConstraint: NSLayoutConstraint!
    
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
    
    private var colors: [UIColor] = CurrentTheme.barChartRaceColors
    private var colorsDict: [String: UIColor] = [:]
    private var currentColorIndex: Int = 0

    //MARK: Funnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Bar Chart Video".localiz()
        navigationController?.setNavigationBarHidden(shouldHideControls, animated: false)
        recordIndicator.isHidden = shouldHideControls
        controlsBottomConstraint.constant = -80
        controlsHolder.isHidden = shouldHideControls
        navigationItem.rightBarButtonItems = rightBarButtons()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barChartView?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordIndicator.layer.cornerRadius = recordIndicator.frame.width / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barChartView?.stop()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        guard !recorder.isRecording else {
            return []
        }
        return [UIBarButtonItem(image: UIImage(named: "Record"), style: .plain, target: self, action: #selector(rightBarButtonAction(_ :)))]
    }

    //MARK: Private Functions
    private func initialSetup() {
        view.backgroundColor = CurrentTheme.cellBackgroundColor
        controlsHolder.backgroundColor = CurrentTheme.lightBackgroundColor
        dateLabel.style(CurrentTheme.textStyleWith(dateLabel.font.pointSize, weight: .semibold))
        timeLabel.style(CurrentTheme.textStyleWith(timeLabel.font.pointSize, weight: .semibold))

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
        camelLabels.offCenter = 0.2
        speedSlider.addTarget(self, action: #selector(BarChartRaceViewController.speedSliderDragEnded(_:)), for: .touchUpInside)

        
        //setup bar chart race
        barChartView.delegate = self
        barChartView.backgroundColor = CurrentTheme.cellBackgroundColor
        barChartView.timeInterval = TimeInterval(speed)
        barChartView.titleColor = CurrentTheme.titleColor
        barChartView.valueColor = CurrentTheme.titleColor
        
        let dataSetList = barData.compactMap { (videoContent) -> DataSet? in
            let colorSet: [UIColor] =  videoContent.entries.compactMap { (entry) -> UIColor? in
                if colorsDict[entry.title] == nil {
                    colorsDict[entry.title] = colors[currentColorIndex % colors.count]
                    currentColorIndex += 1
                }
                return colorsDict[entry.title] ?? CurrentTheme.standardColor
            }
            return videoContent.barChartDataSet(colorSet)
        }
        
        barChartView.setupBarChartRace(dataSetList, animated: true)
    }
    
    @objc override func rightBarButtonAction(_ sender: UIBarButtonItem) {
        guard !recorder.isRecording else { return }
        barChartView.pause()
        showOkCancelAlert("Export Video".localiz(), "Video Record Don't interrupt message".localiz(), okTitle: "Record".localiz(), okActionBlock: {
            self.barChartView.stop()
            self.hideAllControls(true) { (completed) in
                self.startRecording()
            }
        }, cancelTitle: "Not Now".localiz()) {
            self.barChartView.play()
        }
    }
    
    
    private func startRecording() {
        guard recorder.isAvailable else { return }
        recorder.startRecording{ (error) in
            guard error == nil else { return }
            self.barChartView.play()
            /*
            self.recordIndicator.isHidden = false
            self.recordIndicator.blink()
             */
        }
    }
    
    private func stopRecording() {
        recorder.stopRecording { (preview, error) in
            guard let preview = preview else { return }
            
            self.barChartView.stop()
            self.recordIndicator.isHidden = true

            preview.modalPresentationStyle = .automatic
            preview.previewControllerDelegate = self
            self.present(preview, animated: true, completion: nil)
        }
        
    }
    
    private func hideAllControls(_ hide: Bool, completion: ((Bool) -> Void)?) {
        
        navigationController?.setNavigationBarHidden(hide, animated: true)
        controlsBottomConstraint.constant = hide ? -80 : 0
        if !hide {
            self.controlsHolder.isHidden = false
        }
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration), animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            if hide {
                self.controlsHolder.isHidden = hide
            }
            completion?(completed)
        }
    }
    
    //MARK: Button Actions
    @IBAction func playButtonAction(_ sender: UIButton) {
        if barChartView.playerState == .playing {
            barChartView.pause()
        } else {
            barChartView.play()
        }
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        shouldHideControls = !shouldHideControls
        hideAllControls(shouldHideControls) { (completed) in
            guard self.recorder.isRecording else { return }
            self.stopRecording()
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
            stopRecording()
        }
    }
    
    func currentDataSet(_ dataSet: DataSet, index: Int) {
        dateLabel.text = dataSet.date.toString(.custom("dd MMM yyyy"))
        guard videoConfig?.spanType == .seconds || videoConfig?.spanType == .minutes || videoConfig?.spanType == .hours else {
            timeLabel.text = ""
            return
        }
        timeLabel.text = dataSet.date.toString(.custom("HH:mm:ss"))
    }
}

extension BarChartRaceViewController : RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
