import UIKit
import AVFoundation
import Vision
import CoreData

class CameraViewController: BaseViewController {
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var totalNumberOfTextBoxes: Int = 0
    
    lazy var videoOutputView: UIImageView = {
        let videoOutputView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
        return videoOutputView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview( videoOutputView )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startLiveVideo()
        startQRCodeDetection()
    }
    
    func startLiveVideo() {
        // Enable live stream video
        self.session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        // Set the quality of the video
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        // What the camera is seeing
        self.session.addInput(deviceInput)
        
        // What we will display on the screen
        self.session.addOutput(deviceOutput)

        // Show the video as it's being captured
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        
        // Orientation is reversed
        switch (deviceOrientation) {
            case .landscapeLeft:
                previewLayer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight:
                previewLayer.connection?.videoOrientation = .landscapeLeft
            default:
                previewLayer.connection?.videoOrientation = .landscapeRight
        }
        
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.videoOutputView.bounds
        self.videoOutputView.layer.addSublayer(previewLayer)
        
        self.session.startRunning()
    }
    
    func toggleSession() {
        if session.isRunning {
            session.stopRunning()
        } else {
            session.startRunning()
        }
    }
    
    func startQRCodeDetection() {
        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.detectBarcodeHandler)
        self.requests = [barcodeRequest]
    }
    
    // Handle barcode detection requests
    func detectBarcodeHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print(error!)
        }
        guard let barcodes = request.results else {
            return
        }

        // Perform UI updates on the main thread
        DispatchQueue.main.async {
            if self.session.isRunning {
                self.videoOutputView.layer.sublayers?.removeSubrange(1...)
                self.totalNumberOfTextBoxes = 0
                
                // This will be used to eliminate duplicate findings
                var barcodeObservations: [String : VNBarcodeObservation] = [:]
                for barcode in barcodes {
                    if let potentialQRCode = barcode as? VNBarcodeObservation {
                        if potentialQRCode.payloadStringValue != nil && potentialQRCode.symbology == .QR {
                            barcodeObservations[potentialQRCode.payloadStringValue!] = potentialQRCode
                        }
                    }
                }

                for (_, barcodeObservation) in barcodeObservations {
                    self.highlightQRCode(barcode: barcodeObservation)
                }
                
                print("=======================================")
                for (barcodeContent, _) in barcodeObservations {
                    print(barcodeContent)
                }
            }
        }
    }
    
    func highlightQRCode(barcode: VNBarcodeObservation) {
        let barcodeBounds = self.adjustBoundsToScreen(barcode: barcode)

        let outline = CALayer()
        outline.frame = barcodeBounds
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.white.cgColor

        // We are inserting the highlights at the beginning of the sublayer queue
        // To avoid overlapping with the textboxes
        self.videoOutputView.layer.insertSublayer(outline, at: 1)
    }
    
    func adjustBoundsToScreen(barcode: VNBarcodeObservation) -> CGRect {
        // Current origin is on the bottom-left corner
        let xCord = barcode.boundingBox.origin.x * self.videoOutputView.frame.size.width
        var yCord = (1 - barcode.boundingBox.origin.y) * self.videoOutputView.frame.size.height
        let width = barcode.boundingBox.size.width * self.videoOutputView.frame.size.width
        var height = -1.5 * barcode.boundingBox.size.height * self.videoOutputView.frame.size.height
        
        // Re-adjust origin to be on the top-left corner, so that calculations can be standardized
        yCord += height
        height *= -1

        return CGRect(x: xCord, y: yCord, width: width, height: height)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // Run Vision code with live stream
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions: [VNImageOption : Any] = [:]
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics : camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
