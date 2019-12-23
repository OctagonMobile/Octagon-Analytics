//
//  MapTrackControlView.swift
//  KibanaGo
//
//  Created by Rameez on 4/4/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import TGPControls

class MapTrackControlView: UIView {

    public typealias TimestampSelectionUpdateBlock = (_ sender: MapTrackControlView, _ timestamp: Date) -> Void
    public typealias ListButtonActionBlock = (_ sender: MapTrackControlView, _ isSelected: Bool) -> Void

    enum TackingMode {
        case readyToTrack
        case tracking
        case paused
        case stopped
        
        var imageName: String {
            switch self {
            case .readyToTrack, .paused:
                return "TrackingPlayIcon"
            case .tracking:
                return "TrackingPauseIcon"
            case .stopped:
                return "Replay"
            }
        }
    }
    
    //MARK:
    var mapTrackPanel: MapTrackingPanel? {
        didSet {
            configureMapTrackView()
        }
    }
    
    /// Timestamp selection block
    var timestampSelectionUpdateBlock : TimestampSelectionUpdateBlock?
    
    /// List buttn action
    var listButtonActionBlock: ListButtonActionBlock?
    
    //MARK:
    fileprivate var selectedTrackValue: Int = 0

    /// Play/Track timer
    fileprivate var playTimer: Timer?
    
    /// Interval speed
    fileprivate var fpsInterval: Float = 1.0
    
    /// Tracking mode state
    fileprivate var trackingMode: TackingMode = .readyToTrack
    
    fileprivate var filteredTracks: [MapTrackPoint] = []
    //MARK:
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: TGPDiscreteSlider!
    
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var fpsSlider: TGPDiscreteSlider!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let theme = CurrentTheme
        timeLabel.style(theme.caption1TextStyle())
        fpsLabel.style(theme.caption1TextStyle())

        fromTimeLabel.style(theme.caption2TextStyle())
        toTimeLabel.style(theme.caption2TextStyle())

        // configure sliders
        timeSlider.addTarget(self, action: #selector(timeSliderDragEnded(_:event:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(timeSliderDragEnded(_:event:)), for: .touchUpOutside)

        timeSlider.addTarget(self, action: #selector(timeSliderDidBeginDrag(_:event:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:event:)), for: .valueChanged)

        fpsSlider.addTarget(self, action: #selector(fpsSliderAction(_:event:)), for: .touchUpInside)
        fpsSlider.addTarget(self, action: #selector(fpsSliderAction(_:event:)), for: .touchUpOutside)

        let thumbImage = UIImage(named: "sliderHolder")
        fpsSlider.thumbImage = thumbImage
        fpsSlider.thumbStyle = ComponentStyle.image.rawValue
        fpsSlider.minimumTrackTintColor = theme.sliderTrackColor
        fpsSlider.maximumTrackTintColor = theme.sliderTrackColor

        fpsSlider.minimumValue = 1
        fpsSlider.tickCount = 5
        fpsSlider.value = CGFloat(fpsInterval)
        
        timeSlider.thumbStyle = ComponentStyle.image.rawValue
        timeSlider.thumbImage = thumbImage
        timeSlider.minimumTrackTintColor = theme.sliderTrackColor
        timeSlider.maximumTrackTintColor = theme.sliderTrackColor
        timeSlider.tickSize = CGSize.zero
        timeSlider.minimumValue = CGFloat(selectedTrackValue)

        // Configure play button
        playButton.setImage(UIImage(named: "TrackingPlayIcon"), for: .normal)
        playButton.setImage(UIImage(named: "TrackingPauseIcon"), for: .selected)

    }
    
    deinit {
        resetTimer()
    }
    
    func configureMapTrackView() {
        
        guard let panel = mapTrackPanel else { return }
        
        filteredTracks.removeAll()
        for mapTrack in panel.sortedTracks {
            if !filteredTracks.contains(where: { $0.timestamp == mapTrack.timestamp}) {
                filteredTracks.append(mapTrack)
            }
        }
        
        timeSlider.tickCount = filteredTracks.count
        
        if filteredTracks.count > selectedTrackValue {
            timeLabel.text = filteredTracks[selectedTrackValue].timestampString
        }
        
        fpsLabel.text = "x\(Int(fpsSlider.value))"

        fromTimeLabel.text = filteredTracks.first?.timestampString ?? ""
        toTimeLabel.text = filteredTracks.last?.timestampString ?? ""

    }
    
    @objc func playTimerFired() {
        
        if selectedTrackValue < filteredTracks.count - 1 {
            selectedTrackValue += 1
            timeStampUpdateCallBack()
        } else {
            resetTimer()
            trackingMode = .stopped
            updateTimeLabelStateAndPlayIcon()
        }
    }

    func reset() {
        selectedTrackValue = 0
        timeStampUpdateCallBack()
        
        resetTimer()
        trackingMode = .readyToTrack
        updateTimeLabelStateAndPlayIcon()
    }
    
    func isTrackingInProgress() -> Bool {
        return trackingMode == .tracking
    }
    
    fileprivate func startTracking() {
        trackingMode = .tracking
        resetTimer()
        let timeInterval = TimeInterval(1/fpsInterval)
        playTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(playTimerFired), userInfo: nil, repeats: true)
    }
    
    //MARK: Button Actions
    @IBAction func listButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        listButtonActionBlock?(self, sender.isSelected)
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        
        switch trackingMode {
        case .readyToTrack, .paused:
            startTracking()
        case .tracking:
            trackingMode = .paused
            resetTimer()
        case .stopped:
            trackingMode = .readyToTrack
            reset()
        }
        
        updateTimeLabelStateAndPlayIcon()
    }
    
    @IBAction func previousButtonAction(_ sender: UIButton) {
        
        guard selectedTrackValue > Int(timeSlider.minimumValue) else { return }
        selectedTrackValue -= 1
        timeStampUpdateCallBack()
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        
        guard selectedTrackValue < filteredTracks.count else { return }
        selectedTrackValue += 1
        timeStampUpdateCallBack()
    }
    
    private func timeStampUpdateCallBack() {
        
        timeSlider.value = CGFloat(selectedTrackValue)
        if selectedTrackValue < filteredTracks.count, let timestamp = filteredTracks[selectedTrackValue].timestamp {
            
            timeLabel.text = filteredTracks[selectedTrackValue].timestampString
            timestampSelectionUpdateBlock?(self, timestamp)
        }
    }
    
    private func updateTimeLabelStateAndPlayIcon() {
        
        let isTracking = trackingMode == .tracking
        fromTimeLabel.isHidden = isTracking
        toTimeLabel.isHidden = isTracking
        timeLabel.isHidden = !isTracking
        
        let image = UIImage(named: trackingMode.imageName)
        playButton.setImage(image, for: .normal)
    }
    
    private func resetTimer() {
    
        playTimer?.invalidate()
        playTimer = nil
    }
    
    //MARK: Slider Actions
    @objc func fpsSliderAction(_ sender: TGPDiscreteSlider, event:UIEvent) {
        fpsInterval = Float(fpsSlider.value * 2)
        fpsLabel.text = "x\(Int(fpsSlider.value))"
        
        if trackingMode == .tracking {
            startTracking()
        }
    }
    
    @objc func timeSliderDragEnded(_ sender: TGPDiscreteSlider, event:UIEvent) {
        
        trackingMode = .paused
        resetTimer()
        updateTimeLabelStateAndPlayIcon()

        let index = Int(sender.value)
        guard selectedTrackValue != index, index < filteredTracks.count else { return }
        
        selectedTrackValue = index
        timeLabel.text = filteredTracks[index].timestampString
        
        if let timestamp = filteredTracks[index].timestamp {
            timestampSelectionUpdateBlock?(self, timestamp)
        }

    }
    
    @objc func timeSliderDidBeginDrag(_ sender: TGPDiscreteSlider, event:UIEvent) {

        trackingMode = .tracking
        updateTimeLabelStateAndPlayIcon()
    }
    
    @objc func timeSliderValueChanged(_ sender: TGPDiscreteSlider, event:UIEvent) {
        
        // Used to update the time label only
        let index = Int(sender.value)
        guard selectedTrackValue != index, index < filteredTracks.count else { return }
        
        timeLabel.text = filteredTracks[index].timestampString
        
    }
}
