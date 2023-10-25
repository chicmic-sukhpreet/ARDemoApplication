//
//  ARDemoViewController+ARSession.swift
//  ARDemoApp
//
//  Created by Chicmic on 28/08/23.
//

import Foundation
import ARKit
import RealityKit
import CoreImage
// swiftlint:disable line_length
extension ARDemoViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard option == .filters else { return }
        filterImageView.isHidden = true
        self.label.isHidden = false
        if selectedIndexForFilters < (models.count / maximumNumberOfFaceAnchors) {
            var index = 0
            self.label.text = ""
            for anchor in anchors {
                guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
                updateFilters(faceAnchor: faceAnchor, index: index)
                index += 1
            }
        } else if selectedIndexForFilters == (models.count / maximumNumberOfFaceAnchors) {
            updateTongueModel(anchors: anchors)
        } else if selectedIndexForFilters < 6 {
            updateSmileModel(anchors: anchors)
        } else if selectedIndexForFilters == 6 {
            anchors.compactMap { $0 as? ARFaceAnchor }.forEach { headPreview?.update(with: $0) }
        } else if selectedIndexForFilters == 7 {
            var faceAnchor: ARFaceAnchor?
            for anc in anchors {
                guard let anchor = anc as? ARFaceAnchor else { return }
                faceAnchor = anchor
                updateAnimoji(withAnchor: faceAnchor)
            }
        } else if selectedIndexForFilters == 8 {
            updateHeartModel(anchors: anchors)
        } else if selectedIndexForFilters == 9 {
            updateAntModel(anchors: anchors)
        } else if selectedIndexForFilters == 10 {
            updateBeardModel(anchors: anchors)
        }
    }
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if option == .filters && selectedIndexForFilters == 6 {
            if headPreview == nil {
                addHeadPreview()
            }
            headPreview?.isEnabled = !coachingOverlayView.isActive
            updateHeadPreviewAppearance(for: frame)
        } else {
            guard option == .effects, !isProcessingFrame else { return }
            isProcessingFrame = true
            self.label.isHidden = true
            filterImageView.isHidden = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.filterContext == nil {
                    self.filterContext = CIContext()
                }
                let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
                self.applyFilterToImageView(ciImage: ciImage, filterIndex: self.selectedIndexForEffects, imageViewForFilter: self.filterImageView)
                self.imageWithoutEffects = UIImage(ciImage: ciImage, scale: 1, orientation: .right)
                for index in self.effects.indices {
                    if let cell = self.collectionViewForEffects.cellForItem(at: IndexPath(item: index, section: 0)) as? CollectionViewForEffectsCell {
                        self.applyFilterToImageView(ciImage: CIImage(cvPixelBuffer: frame.capturedImage), filterIndex: index, imageViewForFilter: cell.effectImage)
                    }
                }
                self.isProcessingFrame = false
            }
        }
    }
}
// swiftlint:enable line_length
