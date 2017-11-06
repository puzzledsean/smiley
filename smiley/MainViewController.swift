//
//  MainViewController.swift
//  smiley
//
//  Created by Sean on 10/22/17.
//  Copyright © 2017 Sean. All rights reserved.
//

import UIKit
import AVKit
import Vision

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    private var faceLayers = [CAShapeLayer]()

    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var videoPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginSession()
        
        // facebook video data
        // hard coded for now
        let array = ["https://video.xx.fbcdn.net/v/t43.1792-2/22745288_553245285034216_3669178629553651712_n.mp4?efg=eyJybHIiOjI3MTYsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=2716&vabr=1811&oh=40853a739802916d8f3498bf99959741&oe=5A010824",
                     "https://video.xx.fbcdn.net/v/t43.1792-2/23129143_230031627531804_8521591771010957312_n.mp4?efg=eyJybHIiOjI4NDQsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=2844&vabr=1896&oh=db81d1864544d80c769bce83878e0095&oe=5A01E133"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        let facebookVideoURL = array[randomIndex]
        
        let videoURL = URL(string: facebookVideoURL)
        let player = AVPlayer(url: videoURL!)
        
        // stream facebook video videoPreview UIView
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPreview.bounds
        videoPreview.layer.addSublayer(playerLayer)
        player.play()
    }
    
    func beginSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        
        captureDevice = availableDevices.first
        
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
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        /*
         Callback function that will be called for every frame of the video
         */
        
        // get the frame from video
        guard let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // create CoremL request
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        let myRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try! myRequestHandler.perform([faceDetectionRequest])
        
        // detect face/draw rectangle around face
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
                self.faceLayers.append(layer)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func processBufferCaptured(buffer: CMSampleBuffer!, faceDetectionRequest:VNDetectFaceRectanglesRequest){
        // to be overrided in child
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

extension CGRect {
    func denormalized(newRect: CGRect) -> CGRect
    {
        let viewWidth = newRect.size.width
        let viewHeight = newRect.size.height
        let standardRect = self.standardized
        let width = standardRect.size.width * viewWidth
        let height = standardRect.size.height * viewHeight
        let x = standardRect.origin.x * viewWidth
        let y = viewHeight - (standardRect.origin.y * viewHeight) - height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
