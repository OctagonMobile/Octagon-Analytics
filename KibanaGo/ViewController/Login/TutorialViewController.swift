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

class TutorialViewController: UIViewController {

    var showAutoFill: Bool  =   true
    var tutorialAutoFillActionBlock: TutorialButtonActionBlock?

    private var kibanaGoPluginUrl: String   =   "https://github.com/OctagonMobile/Kibana-Go-Plugin"
    private var tutorials: [TutorialType]   =   [TutorialType.config,
                                                 TutorialType.login]
    

    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var tutorialCarouselView: iCarousel!

    public enum TutorialType {
        case config
        case login
        
        var cellId: String {
            switch self {
            case .config: return NibNames.tutorialConfigCarouselView
            case .login: return NibNames.tutorialLoginCarouselView
            }
        }
    }
    
    //MARK: Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        tutorialCarouselView.delegate = self
        tutorialCarouselView.dataSource = self
        tutorialCarouselView.isPagingEnabled = true
        
        pageNumberLabel.text = "\(tutorialCarouselView.currentItemIndex + 1)/\(tutorials.count)"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        tutorialCarouselView.reloadData()
    }
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        if tutorialCarouselView.currentItemIndex >= tutorials.count - 1 {
            dismiss(animated: true, completion: nil)
        } else {
            tutorialCarouselView.scrollToItem(at: tutorialCarouselView.currentItemIndex + 1, animated: true)
        }
    }
}

extension TutorialViewController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return tutorials.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let cellId = tutorials[index].cellId
        guard let carouselView = Bundle.main.loadNibNamed(cellId, owner: self, options: nil)?.first as? UIView else { return UIView() }
        carouselView.frame = tutorialCarouselView.bounds
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_ :)))
        carouselView.addGestureRecognizer(tapGesture)

        
        switch tutorials[index] {
        case .config:
            (carouselView as? TutorialConfigCarouselView)?.tutorialConfigActionBlock = { sender in
                // Redirect to Kibana Go Plugin Download Page
                guard let url = URL(string: self.kibanaGoPluginUrl) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        case .login:
            (carouselView as? TutorialLoginCarouselView)?.showAutoFill = showAutoFill
            (carouselView as? TutorialLoginCarouselView)?.tutorialAutoFillActionBlock = {[weak self] sender in
                self?.dismiss(animated: true, completion: {
                    self?.tutorialAutoFillActionBlock?(sender)
                })
            }
        }
        return carouselView
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        pageNumberLabel.text = "\(tutorialCarouselView.currentItemIndex + 1)/\(tutorials.count)"
    }
}

extension TutorialViewController {
    struct NibNames {
        static let tutorialConfigCarouselView = "TutorialConfigCarouselView"
        static let tutorialLoginCarouselView = "TutorialLoginCarouselView"
    }
}
