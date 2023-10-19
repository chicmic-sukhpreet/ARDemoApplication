//
//  BodyAnchorViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 31/08/23.
//

import UIKit
import RealityKit
import ARKit

private var bodySkeleton: BodySkeleton?
private let bodySkeletonAnchor = AnchorEntity()

class BodyAnchorViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var bodyAnchorView: ARView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bodyAnchorView.session.delegate = self
        bodyAnchorView.scene.addAnchor(bodySkeletonAnchor)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARBodyTrackingConfiguration()
        bodyAnchorView.session.run(config)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bodyAnchorView.session.pause()
    }
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                if let skeleton = bodySkeleton {
                    skeleton.update(with: bodyAnchor)
                } else {
                    bodySkeleton = BodySkeleton(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(bodySkeleton!)
                }
            }
        }
    }
}
