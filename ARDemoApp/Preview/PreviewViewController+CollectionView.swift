//
//  PreviewViewController+CollectionView.swift
//  ARDemoApp
//
//  Created by Chicmic on 06/09/23.
//

import Foundation
import UIKit
// swiftlint:disable line_length
extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewForEditCell", for: indexPath) as? CollectionViewForEditCell
        if indexPath.item == 0 {
            cell?.effectImageForEdit.image = originalImageWithoutEffects
        } else if indexPath.item == 1 {
            let originalImage = CIImage(image: previewImage.image!)
            let filteredImage = sepiaFilter(originalImage!, intensity: 0.9)
            cell?.effectImageForEdit.image = UIImage(cgImage: filteredImage!)
        } else {
            let originalImage = CIImage(image: previewImage.image!)
            let filteredImage = monoFilter(originalImage!)
            cell?.effectImageForEdit.image = UIImage(cgImage: filteredImage!)
        }
        cell?.effectImageForEdit.contentMode = .scaleAspectFill
        cell?.effectImageForEdit.layer.cornerRadius = 10
        cell?.effectImageForEdit.layer.masksToBounds = true
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let original = CIImage(image: originalImage!) else { return }
        if indexPath.item == 0 {
            self.previewImage.image = originalImageWithoutEffects
            filterApplied = [false, false]
        } else if indexPath.item == 1 {
            guard filterApplied[0] == false else { return }
            guard let filteredImage = sepiaFilter(original, intensity: 0.7) else { return }
            self.previewImage.image = UIImage(cgImage: filteredImage)
            filterApplied[0] = true
            filterApplied[1] = false
        } else {
            guard filterApplied[1] == false else { return }
            guard let filteredImage = monoFilter(original) else { return }
            self.previewImage.image = UIImage(cgImage: filteredImage)
            filterApplied[1] = true
            filterApplied[0] = false
        }
        if let previousSelectedIndexPath = selectedEffectIndexPath {
            let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? CollectionViewForEditCell
            previousCell?.effectImageForEdit.layer.borderWidth = 0.0
        }
        let currentCell = collectionView.cellForItem(at: indexPath) as? CollectionViewForEditCell
        currentCell?.effectImageForEdit.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        currentCell?.effectImageForEdit.layer.borderWidth = 4.0
        selectedEffectIndexPath = indexPath
        revertButton.isEnabled = true
        revertButton.tintColor = UIColor.white
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.height
        return CGSize(width: size, height: size)
    }
}
// swiftlint:enable line_length
