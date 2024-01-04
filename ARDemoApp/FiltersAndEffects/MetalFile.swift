//
//  MetalFile.swift
//  ARDemoApp
//
//  Created by Chicmic on 02/01/24.
//

import Foundation
import MetalKit
import CoreImage

class MetalRenderView: MTKView {
    private lazy var commandQueue: MTLCommandQueue? = {
        return device?.makeCommandQueue()
    }()
    
    private lazy var ciContext: CIContext? = {
        guard let device = device else { return nil }
        return CIContext(mtlDevice: device)
    }()
    
    private var image: CIImage? {
        didSet {
            renderImage()
        }
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        if super.device == nil {
            fatalError("Metal is not supported by this device")
        }
        framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func setImage(_ image: CIImage?) {
        guard let image = image else { return }
        self.image = image
    }
    
    private func renderImage() {
        guard let image = image,
              let currentDrawable = currentDrawable,
              let ciContext = ciContext else { return }
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let destination = CIRenderDestination(width: Int(drawableSize.width),
                                              height: Int(drawableSize.height),
                                              pixelFormat: .rgba8Unorm,
                                              commandBuffer: commandBuffer) { () -> MTLTexture in
            return currentDrawable.texture
        }
        
        do {
            try ciContext.startTask(toRender: image.transformToOrigin(withSize: drawableSize), to: destination)
        } catch {
            // Error handling
        }
        
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
        draw()
    }
}

extension CIImage {
  func transformToOrigin(withSize size: CGSize) -> CIImage {
    let originX = extent.origin.x
    let originY = extent.origin.y
    let scaleX = size.width / extent.width
    let scaleY = size.height / extent.height
    let scale = max(scaleX, scaleY)
    return transformed(by: CGAffineTransform(translationX: -originX, y: -originY)).transformed(by: CGAffineTransform(scaleX: scale, y: scale))
  }
}
