//
//  MainViewController.swift
//  smiley
//
//  Created by Sean on 10/22/17.
//  Copyright © 2017 Sean. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    @IBOutlet weak var cameraPreview: UIView!
    
    var captureDevice:AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCamera()
    }
    
    func prepareCamera(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        
        captureDevice = availableDevices.first
        beginSession()
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch{
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        
        self.previewLayer.frame = cameraPreview.bounds
        cameraPreview.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput){
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
