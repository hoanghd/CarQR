import Foundation
import AVFoundation
import UIKit
import Vision

class TextViewController: BaseViewController {
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    lazy var videoOutputView: UIImageView = {
        let videoOutputView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight - 60 ))
        return videoOutputView
    }()
    
    lazy var outline: CALayer = {
        let outline = CALayer()
        
        var width: CGFloat = 600
        var height: CGFloat = 50
        
        outline.frame = CGRect(x: (self.screenWidth - width)/2, y: (self.screenHeight - height)/2, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.white.cgColor
        return outline
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 40, y: self.screenHeight - 55, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("OK", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview( videoOutputView )
        self.view.addSubview( button )
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        startCamera()
//        startTextDetection()
    }
    
    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
    }
    
//    func startCamera() {
//        if !self.session.inputs.isEmpty {
//            self.toggleSession()
//            return
//        }
//
//        // Enable live stream video
//        self.session.sessionPreset = AVCaptureSession.Preset.photo
//        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
//
//        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
//        let deviceOutput = AVCaptureVideoDataOutput()
//        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
//
//        // Set the quality of the video
//        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
//
//        // What the camera is seeing
//        self.session.addInput(deviceInput)
//
//        // What we will display on the screen
//        self.session.addOutput(deviceOutput)
//
//        // Show the video as it's being captured
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
//
//        // Orientation is reversed
//        switch (deviceOrientation) {
//            case .landscapeLeft:
//                previewLayer.connection?.videoOrientation = .landscapeRight
//            case .landscapeRight:
//                previewLayer.connection?.videoOrientation = .landscapeLeft
//            default:
//                previewLayer.connection?.videoOrientation = .landscapeRight
//        }
//
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = self.videoOutputView.bounds
//        previewLayer.addSublayer(outline)
//
//        self.videoOutputView.layer.addSublayer(previewLayer)
//
//        self.session.startRunning()
//    }
//
//    func toggleSession() {
//        if session.isRunning {
//            session.stopRunning()
//        } else {
//            session.startRunning()
//        }
//    }
//
//    func startTextDetection(){
//        let textRequest = VNRecognizeTextRequest(completionHandler: self.detectTextHandler)
//        textRequest.recognitionLanguages = ["ja-JP"]
//        textRequest.recognitionLevel = .accurate
//
//        self.requests = [textRequest]
//    }
//
//    func detectTextHandler(request: VNRequest, error: Error?) {
//        if error != nil {
//            print(error!)
//        }
//
//        guard let results = request.results else {
//            return
//        }
//
//        // Perform UI updates on the main thread
//        DispatchQueue.main.async {
//            if self.session.isRunning {
//                self.videoOutputView.layer.sublayers?.removeSubrange(1...)
//
//                for result in results {
//                    if let observation = result as? VNRecognizedTextObservation {
//                        for text in observation.topCandidates(1) {
//                            print(text.string)
//                            print(text.confidence)
//                            print(observation.boundingBox)
//                            print("\n")
//                        }
//                    }
//                }
//            }
//        }
//    }
}

//extension TextViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    // Run Vision code with live stream
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        var requestOptions: [VNImageOption : Any] = [:]
//        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
//            requestOptions = [.cameraIntrinsics : camData]
//        }
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
//
//        do {
//            try imageRequestHandler.perform(self.requests)
//        } catch {
//            print(error)
//        }
//    }
//}
