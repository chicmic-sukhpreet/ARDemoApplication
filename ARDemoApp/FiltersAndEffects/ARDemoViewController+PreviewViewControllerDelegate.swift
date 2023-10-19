//
//  ARDemoViewController+PreviewViewControllerDelegate.swift
//  ARDemoApp
//
//  Created by Chicmic on 13/10/23.
//

import Foundation
import UIKit

extension ARDemoViewController: PreviewViewControllerDelegate {
    func previewViewControllerDidSaveImage(_ viewController: PreviewViewController) {
        if let image = viewController.previewImage.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        viewController.showSaveAlert()
        self.navigationController?.popViewController(animated: true)
    }

    func previewViewControllerDidDiscardImage(_ viewController: PreviewViewController) {
        viewController.showActionSheet()
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}
