//
//  ARDemoViewController+VideoCapture.swift
//  ARDemoApp
//
//  Created by Chicmic on 10/10/23.
//

import Foundation
import ReplayKit
import UIKit
import Photos

extension ARDemoViewController: RPPreviewViewControllerDelegate {
    func captureVideoRecording() {
        if recorder.isAvailable {
            if !recorder.isRecording {
                recorder.isMicrophoneEnabled = true
                collectionViewForFilters.isHidden = true
                collectionViewForEffects.isHidden = true
                label.isHidden = true
                segmentedControl.isHidden = true
                // start recording
                recorder.startRecording { err in
                    guard err == nil else { print(err.debugDescription); return }
                }
            } else {
                // Stop recording
                recorder.stopRecording { preview, _ in
                    guard let preview = preview else { print("no preview window"); return }
                    // update recording controls
                    preview.modalPresentationStyle = .overFullScreen
                    preview.previewControllerDelegate = self
                    DispatchQueue.main.async {
                        self.present(preview, animated: true)
                    }
                }
            }
        } else {
            print("Screen recording is not available.")
        }
    }
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true) { [weak self] in
            DispatchQueue.main.async {
                if self?.option == .filters {
                    self?.collectionViewForFilters.isHidden = false
                } else {
                    self?.collectionViewForEffects.isHidden = false
                }
                self?.label.isHidden = false
                self?.segmentedControl.isHidden = false
            }
        }
    }
}
