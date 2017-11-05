//
//  FaceDetection.swift
//  smiley
//
//  Created by Sean on 11/5/17.
//  Copyright © 2017 Sean. All rights reserved.
//

import UIKit
import CoreMedia
import Vision

class FaceDetection: MainViewController{
    private var faceLayers = [CAShapeLayer]()
    
    override func processBufferCaptured(buffer: CMSampleBuffer!, faceDetectionRequest:VNDetectFaceRectanglesRequest){
        print("frame", Date())

        DispatchQueue.main.async { [unowned self] in
            self.faceLayers.forEach{ $0.removeFromSuperlayer() }
            
            self.faceLayers.removeAll()
            guard let results = faceDetectionRequest.results, results.count > 0 else {
                return
            }
            
            for observation in faceDetectionRequest.results as! [VNFaceObservation] {
                let boundingRect = observation.boundingBox.denormalized(newRect: self.previewLayer.frame)
                print("found face", boundingRect)
                let layer = CAShapeLayer()
                let path = UIBezierPath(rect: boundingRect)
                
                layer.path = path.cgPath
                layer.fillColor = UIColor.clear.cgColor
                layer.strokeColor = UIColor.yellow.cgColor
                layer.lineWidth = 4
                self.previewLayer.addSublayer(layer)
            }
        }
    }
}
