//
//  CalloutDetailView.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

protocol CalloutDetailViewDelegate {
    func didTouchUpInsideViewMoreWithLocation(_ location: Location)
}

class CalloutDetailView: UIView {
    // MARK: Properties
    var location: Location!
    var delegate: CalloutDetailViewDelegate?
    
    // MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var nextZmanLabel: UILabel!
    @IBOutlet weak var noMoreLabel: UILabel!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewMoreButton: UIButton!
    
    // MARK: Methods
    func setupView() {
        if location.imageURL == nil { noImageLabel.isHidden = false }
        imageView.setup(with: location, animated: true, activityIndicator: activityIndicator, completionHandler: {
            self.hideLabels()
        }) {
            self.errorLabel.isHidden = false
        }
        if location.zmanim.isEmpty {
            viewMoreButton.isHidden = true
        } else {
            viewMoreButton.isHidden = false
        }
    }
    
    func showNoMoreLabel() {
        nextLabel.isHidden = true
        nextZmanLabel.isHidden = true
        noMoreLabel.isHidden = false
    }
    
    func hideNoMoreLabel() {
        nextLabel.isHidden = false
        nextZmanLabel.isHidden = false
        noMoreLabel.isHidden = true
    }
    
    func hideLabels() {
        noImageLabel.isHidden = true
        errorLabel.isHidden = true
    }
    
    // MARK: IBActions
    @IBAction func viewMore(_ sender: UIButton) {
        //delegate?.didTouchUpInsideViewMoreWithLocation?(location)
    }
}
