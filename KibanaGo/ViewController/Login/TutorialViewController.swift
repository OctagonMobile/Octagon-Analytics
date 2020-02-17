//
//  TutorialViewController.swift
//  KibanaGo
//
//  Created by Rameez on 2/11/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import iCarousel

typealias TutorialButtonActionBlock = (_ sender: UIButton) -> Void

class TutorialViewController: BaseViewController {

    var showAutoFill: Bool  =   true
    var tutorialAutoFillActionBlock: TutorialButtonActionBlock?

    private var tutorials: [TutorialType]   =   [TutorialType.config,
                                                 TutorialType.settings,
                                                 TutorialType.login]
    

    @IBOutlet weak var tutorialPageControl: UIPageControl!
    @IBOutlet weak var tutorialCarouselView: iCarousel!

    public enum TutorialType {
        case config
        case settings
        case login
        
        var cellId: String {
            switch self {
            case .config: return NibNames.tutorialConfigCarouselView
            case .settings: return NibNames.tutorialSettingsCarouselView
            case .login: return NibNames.tutorialLoginCarouselView
            }
        }
    }
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        if Configuration.shared.baseUrl != "http://ec2-35-158-106-139.eu-central-1.compute.amazonaws.com:5601" {
            // Remove the Login Credentials Tutorial
            tutorials.removeLast()
        }

        tutorialCarouselView.delegate = self
        tutorialCarouselView.dataSource = self
        tutorialCarouselView.isPagingEnabled = true
        tutorialCarouselView.type = .linear
        tutorialCarouselView.decelerationRate = 0.25
        
        tutorialPageControl.numberOfPages   =   tutorials.count
        tutorialPageControl.currentPage     =   0
        tutorialPageControl.currentPageIndicatorTintColor = CurrentTheme.tutorialButtonColor
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.tutorialCarouselView.reloadData()
        }, completion: nil)
    }
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        if tutorialCarouselView.currentItemIndex >= tutorials.count - 1 {
            dismiss(animated: true, completion: nil)
        } else {
            tutorialCarouselView.scrollToItem(at: tutorialCarouselView.currentItemIndex + 1, animated: true)
        }
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        tutorialCarouselView.scrollToItem(at: sender.currentPage, animated: true)
    }
}

extension TutorialViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return tutorials.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let cellId = tutorials[index].cellId
        guard let carouselView = Bundle.main.loadNibNamed(cellId, owner: self, options: nil)?.first as? UIView else { return UIView() }
        carouselView.frame = tutorialCarouselView.frame
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_ :)))
        carouselView.addGestureRecognizer(tapGesture)

        switch tutorials[index] {
        case .login:
            (carouselView as? TutorialLoginCarouselView)?.showAutoFill = showAutoFill
            (carouselView as? TutorialLoginCarouselView)?.tutorialAutoFillActionBlock = {[weak self] sender in
                self?.dismiss(animated: true, completion: {
                    self?.tutorialAutoFillActionBlock?(sender)
                })
            }
        default: break
        }
        return carouselView
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return tutorialCarouselView.bounds.width
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        tutorialPageControl.currentPage = tutorialCarouselView.currentItemIndex
    }
}

extension TutorialViewController {
    struct NibNames {
        static let tutorialConfigCarouselView = "TutorialConfigCarouselView"
        static let tutorialSettingsCarouselView = "TutorialSettingsCarouselView"
        static let tutorialLoginCarouselView = "TutorialLoginCarouselView"
    }
}
