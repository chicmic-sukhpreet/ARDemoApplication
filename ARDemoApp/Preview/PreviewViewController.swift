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
enum Effect {
    case saturation, brightness, contrast
}
class PreviewViewController: UIViewController {
    @IBOutlet var previewImage: UIImageView!
    @IBOutlet weak var revertButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var collectionViewForEdit: UICollectionView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var editingView: UIView!
    @IBOutlet weak var contrast: UIImageView!
    @IBOutlet weak var brightness: UIImageView!
    @IBOutlet weak var saturation: UIImageView!
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
    var effectType: Effect? = .saturation
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
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        editingView.layer.cornerRadius = editingView.bounds.width / 2
        editingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    @objc func sliderValueChanged(_ sender: UISlider) {
        switch effectType {
        case .saturation:
            previewImage.image = applySaturationEffect(to: capturedImage!, saturation: CGFloat(sender.value))
        case .brightness:
            previewImage.image = applyBrightnessEffect(to: capturedImage!, brightness: CGFloat(sender.value))
        case .contrast:
            previewImage.image = applyContrastEffect(to: capturedImage!, contrast: CGFloat(sender.value))
        default:
            return
        }
    }
    private func setupEditButtons() {
        let tapGestureForContrast = UITapGestureRecognizer(target: self, action: #selector(constrastTapped))
        contrast.addGestureRecognizer(tapGestureForContrast)
        let tapGestureForBrightness = UITapGestureRecognizer(target: self, action: #selector(brightnessTapped))
        brightness.addGestureRecognizer(tapGestureForBrightness)
        let tapGestureForSaturation = UITapGestureRecognizer(target: self, action: #selector(saturationTapped))
        saturation.addGestureRecognizer(tapGestureForSaturation)
    }
    @objc func constrastTapped() {
        contrast.tintColor = .systemYellow
        brightness.tintColor = .white
        saturation.tintColor = .white
    }
    @objc func brightnessTapped() {
        contrast.tintColor = .white
        brightness.tintColor = .systemYellow
        saturation.tintColor = .white
    }
    @objc func saturationTapped() {
        contrast.tintColor = .white
        brightness.tintColor = .white
        saturation.tintColor = .systemYellow
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
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        })
        present(alert, animated: true, completion: nil)
    }
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Do you want to discard the image?",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let discard = UIAlertAction(title: "Discard", style: .destructive) { _ in
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        actionSheet.addAction(discard)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
}
// swiftlint:enable line_length
