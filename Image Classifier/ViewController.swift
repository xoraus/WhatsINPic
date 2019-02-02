//
//  ViewController.swift
//  Image Classifier
//
//  Created by xoraus.github.io on 2019-02-02.
//  Copyright © 2019 Owl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    let model = GoogLeNetPlaces()
    
    let imageArray = [#imageLiteral(resourceName: "desert"), #imageLiteral(resourceName: "forest"), #imageLiteral(resourceName: "grassland"), #imageLiteral(resourceName: "mountains"), #imageLiteral(resourceName: "ocean")]
    var index = 4
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadImageAction(_ sender: UIButton) {
        self.index = (self.index >= imageArray.count - 1) ? 0 : self.index + 1
        let image = self.imageArray[self.index]
        self.resizeImage(image: image)
    }
    
    func resizeImage(image: UIImage) {
        let newSize = CGSize(width: 224.0, height: 224.0)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        self.selectedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.imageView.image = self.selectedImage
    }
    
    @IBAction func predictAction(_ sender: UIButton) {
        if let pixelBuffer = self.convertImageToPixelBuffer() {
            do {
                let sceneLabel = try model.prediction(sceneImage: pixelBuffer)
                resultsLabel.text = sceneLabel.sceneLabel
            } catch {
                resultsLabel.text = "Could not predict image"
            }
        } else {
            resultsLabel.text = "Could not convert image to pixel buffer"
        }
    }
    
    func convertImageToPixelBuffer() -> CVPixelBuffer? {
        guard let image = self.selectedImage else { return nil }
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}

