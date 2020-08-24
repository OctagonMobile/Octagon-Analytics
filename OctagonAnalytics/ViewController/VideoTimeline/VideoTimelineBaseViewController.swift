//
//  VideoTimelineBaseViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 7/26/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import SwiftDate
import TGPControls
import ReplayKit
 
class VideoTimelineBaseViewController: BaseViewController {
  
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var controlsHolder: UIView!
    @IBOutlet weak var speedSlider: TGPDiscreteSlider!
    @IBOutlet weak var camelLabels: TGPCamelLabels!
    @IBOutlet weak var controlsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordIndicator: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var videoConfig: VideoConfigContent?
    var timer: Timer?
    var shouldHideControls: Bool     =   true
    let recorder = RPScreenRecorder.shared()
    var colors: [UIColor] = []
    var currentIndex: Int = 0
    var sliderValuesString: [String]  =   ["0.1x", "0.5x", "1x", "2x", "3x", "4x"]
    var sliderValues: [Float]  =   [1.2, 0.9, 0.4, 0.3, 0.2, 0.1]
    var speed: Float    =   0.4 {
        didSet {
           speedUpdated()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(shouldHideControls, animated: false)
        controlsBottomConstraint.constant = -controlsHolder.frame.height
        controlsHolder.isHidden = shouldHideControls
        navigationItem.rightBarButtonItems = rightBarButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controlsBottomConstraint.constant = -controlsHolder.frame.height
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        shouldHideControls = !shouldHideControls
        hideAllControls(shouldHideControls) { (completed) in
            self.controlsToggled()
            guard self.recorder.isRecording else { return }
            self.stopRecording()
        }
    }
    
    func setupView() {
        view.backgroundColor = CurrentTheme.cellBackgroundColor
        controlsHolder.backgroundColor = CurrentTheme.lightBackgroundColor
        dateLabel.style(CurrentTheme.textStyleWith(dateLabel.font.pointSize, weight: .semibold))
        if timeLabel != nil {
            timeLabel.style(CurrentTheme.textStyleWith(timeLabel.font.pointSize, weight: .semibold))
        }
    }
    
    func setupSliders() {
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
        speedSlider.addTarget(self, action: #selector(VideoTimelineBaseViewController.speedSliderDragEnded(_:)), for: .touchUpInside)
    }
    
    @objc func speedSliderDragEnded(_ sender: TGPDiscreteSlider) {
        guard Int(sender.value) <= sliderValues.count - 1 else { return }
        speed = sliderValues[Int(sender.value)]
    }
    
    @objc override func rightBarButtonAction(_ sender: UIBarButtonItem) {
           guard !recorder.isRecording else { return }
           pauseVideo()
           showOkCancelAlert("Export Video".localiz(), "Video Record Don't interrupt message".localiz(), okTitle: "Record".localiz(), okActionBlock: {
            self.stopVideo()
            self.hideAllControls(true) { (completed) in
                   self.startRecording()
               }
           }, cancelTitle: "Not Now".localiz()) {
                self.playVideo()
           }
    }

    
    func startRecording() {
        guard recorder.isAvailable else { return }
        recorder.startRecording{ (error) in
            guard error == nil else { return }
            self.recordingStarted()
            /*
            self.recordIndicator.isHidden = false
            self.recordIndicator.blink()
             */
        }
    }
    
    
    func stopRecording() {
        recorder.stopRecording { (preview, error) in
            guard let preview = preview else { return }
            self.recordingStopped()
            if self.recordIndicator != nil {
                self.recordIndicator.isHidden = true
            }
            UIApplication.appKeyWindow?.tintColor = .systemBlue
            preview.modalPresentationStyle = .fullScreen
            preview.previewControllerDelegate = self
            self.present(preview, animated: true, completion: nil)
        }
        
    }

    func hideAllControls(_ hide: Bool, completion: ((Bool) -> Void)?) {
        
        navigationController?.setNavigationBarHidden(hide, animated: true)
        controlsBottomConstraint.constant = hide ? -controlsHolder.frame.height : 0
        if !hide {
            self.controlsHolder.isHidden = false
        }
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration), animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.view.isUserInteractionEnabled = true
            if hide {
                self.controlsHolder.isHidden = hide
            }
            completion?(completed)
        }
    }
    
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        guard !recorder.isRecording else {
            return []
        }
        return [UIBarButtonItem(image: UIImage(named: "Record"), style: .plain, target: self, action: #selector(rightBarButtonAction(_ :)))]
    }
    
    //Following methods Will be Overridden in SubClasses
    func recordingStarted() {
        
    }
    
    func recordingStopped() {
        
    }
    
    func pauseVideo() {
        
    }
    
    func playVideo() {
        
    }
    
    func stopVideo() {
        
    }
    
    func speedUpdated() {
        
    }
    
    func controlsToggled() {
        
    }
}

extension VideoTimelineBaseViewController : RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        UIApplication.appKeyWindow?.tintColor = CurrentTheme.secondaryTitleColor
        previewController.dismiss(animated: true, completion: nil)
    }
}
