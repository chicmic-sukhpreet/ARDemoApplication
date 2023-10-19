//
//  ARDemoViewController+CoachingOverlayView.swift
//  ARDemoApp
//
//  Created by Chicmic on 10/10/23.
//

import Foundation
import ARKit
import UIKit

extension ARDemoViewController: ARCoachingOverlayViewDelegate {
    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlayView.session = arView.session
        coachingOverlayView.delegate = self
        coachingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coachingOverlayView)
        NSLayoutConstraint.activate([
            coachingOverlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlayView.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlayView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
