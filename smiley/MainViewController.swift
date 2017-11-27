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
import FBSDKLoginKit

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    private var faceLayers = [CAShapeLayer]()
    var facebookVideoURL:String = ""
    let group = DispatchGroup()
    
    var facebookPageID = "10487409466"; // default to dogspotting

    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var videoPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        group.enter()
        // get facebook video URL
        self.getFacebookVideoURL { (result) in
            self.facebookVideoURL = result["source"] as! NSString as String;
            print("got facebookVideoURL from callback", self.facebookVideoURL)
            self.group.leave()
            
            let videoURL = URL(string: self.facebookVideoURL)
            let player = AVPlayer(url: videoURL!)
            
            // stream facebook video videoPreview UIView
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.videoPreview.bounds
            self.videoPreview.layer.addSublayer(playerLayer)
            player.play()
        }
        beginSession()
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
    
    func getFacebookVideoURL(completion: ((_ result:NSDictionary)->Void)?){
        group.enter()
        FBSDKGraphRequest(graphPath: "/\(facebookPageID)/videos", parameters: [:]).start {
            (connection, result, err) -> Void in
            
            if err != nil{
                print("Failed to grab user data:", err as Any)
                return
            }
            
            // get videos from Dogspotting
            let jsonResult = result as! NSDictionary
            let result:NSArray = jsonResult["data"] as! NSArray
            let randomIndex = Int(arc4random_uniform(UInt32(result.count)))
            
            // choose random video to watch
            let facebookVideo:NSDictionary = result[randomIndex] as! NSDictionary
            let facebookVideoID:NSString = facebookVideo["id"] as! NSString
            let access_token = FBSDKAccessToken.current().tokenString
            
            self.group.leave()
            
            self.group.enter()
            // request for video URL
            FBSDKGraphRequest(graphPath: facebookVideoID as String, parameters: ["fields":"source,description,length", "access_token":access_token!]).start {
                (connection, query_result, query_err) -> Void in

                if query_err != nil{
                    print("Failed to grab user data:", err as Any)
                    return
                }

                let queryResult:NSDictionary = query_result as! NSDictionary
                print(queryResult)
                
                completion?(queryResult)
                self.group.leave()
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
