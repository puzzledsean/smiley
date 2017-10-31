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

    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var videoPreview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        beginSession()
        
        // facebook video data
        let array = ["https://video.xx.fbcdn.net/v/t43.1792-2/17608273_435416326811385_2238057795238756352_n.mp4?efg=eyJybHIiOjE1MDAsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=1500&vabr=691&oh=fa3b30ec8145f13cb64e3139e2b3e6de&oe=59F05442",
                     "https://video.xx.fbcdn.net/v/t43.1792-2/22736705_848024615357448_6312478834121768960_n.mp4?efg=eyJybHIiOjQ1MTUsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=4515&vabr=3010&oh=bd163a276b0aa490ef7789be16c53e49&oe=59F03BE6",
                     "https://video.xx.fbcdn.net/v/t42.1790-2/22722574_883948555114444_4372938574673215488_n.mp4?efg=eyJybHIiOjc5NSwicmxhIjo1MTIsInZlbmNvZGVfdGFnIjoic3ZlX3NkIn0%3D&rl=795&vabr=442&oh=110127afee3603c7afe0e990d18c81b7&oe=59EF4E51",
                     "https://video.xx.fbcdn.net/v/t43.1792-2/22740699_1922574394735896_4908542509975601152_n.mp4?efg=eyJybHIiOjM1OTIsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=3592&vabr=2395&oh=55ed4ce520e675591b2042515f2ec01b&oe=59EF5BE0"]
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
        
//        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
//
//        dataOutput.alwaysDiscardsLateVideoFrames = true
//
//        if captureSession.canAddOutput(dataOutput){
//            captureSession.addOutput(dataOutput)
//        }
//
//        captureSession.commitConfiguration()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let faceDetectionRequest = VNDetectFaceRectanglesRequest()
        let myRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try! myRequestHandler.perform([faceDetectionRequest])

        DispatchQueue.main.async { [unowned self] in
            guard let results = faceDetectionRequest.results, results.count > 0 else {
                return
            }
            
            for observation in faceDetectionRequest.results as! [VNFaceObservation] {
                let boundingRect = observation.boundingBox
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
