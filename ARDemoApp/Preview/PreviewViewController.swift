//
//  PreviewViewController.swift
//  ARDemoApp
//
//  Created by Chicmic on 23/08/23.
//

import UIKit
import CoreImage
// swiftlint:disable line_length
protocol PreviewViewControllerDelegate: AnyObject {
    func previewViewControllerDidSaveImage(_ viewController: PreviewViewController)
    func previewViewControllerDidDiscardImage(_ viewController: PreviewViewController)
}

class PreviewViewController: UIViewController {

    @IBOutlet var previewImage: UIImageView!
    @IBOutlet weak var revertButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var collectionViewForEdit: UICollectionView!
    var filterApplied: [Bool] = [false, false]
    var originalImageWithoutEffects: UIImage?
    var originalImage: UIImage?
    var capturedImage: UIImage?
    weak var delegate: PreviewViewControllerDelegate?
    var effects: [CIFilter?] = [
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CIPhotoEffectMono")
    ]
    var selectedEffectIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = capturedImage {
            previewImage.image = image
            originalImage = image
        }
        revertButton.isEnabled = false
        revertButton.tintColor = UIColor.gray
        collectionViewForEdit.delegate = self
        collectionViewForEdit.dataSource = self
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
       delegate?.previewViewControllerDidSaveImage(self)
    }
    @IBAction func discardButtonTapped(_ sender: UIButton) {
       delegate?.previewViewControllerDidDiscardImage(self)
    }
    @IBAction func removeFilters(_ sender: UIButton) {
        self.previewImage.image = originalImage
        for index in filterApplied.indices {
            filterApplied[index] = false
        }
        revertButton.isEnabled = false
        revertButton.tintColor = UIColor.gray
        if let previousSelectedIndexPath = selectedEffectIndexPath {
            let previousCell = collectionViewForEdit.cellForItem(at: previousSelectedIndexPath) as? CollectionViewForEditCell
            previousCell?.effectImageForEdit.layer.borderWidth = 0.0
        }
    }
    func showSaveAlert() {
        let alert = UIAlertController(title: "Image Saved",
                                      message: "The image has been saved to your photo library.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true, completion: nil)
    }
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Do you want to discard the image?",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let discard = UIAlertAction(title: "Discard", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        actionSheet.addAction(discard)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
}
// swiftlint:enable line_length
