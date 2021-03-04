import TesseractOCR
import AVFoundation
import GPUImage
import UIKit

class OcrViewController: BaseViewController {
    var session = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer!
    var capturePhotoOutput = AVCapturePhotoOutput()
    
    lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(frame: CGRect(x: 60, y:(self.screenHeight - 130) , width: 80, height: 80))
        cameraButton.setImage(UIImage(named: "CameraIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cameraButton.tintColor = .white
        cameraButton.addTarget(self, action: #selector(self.takePicture(_:)), for: .touchUpInside)
        return cameraButton
    }()
    
    lazy var videoOutputView: UIView = {
        let videoOutputView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview( videoOutputView )
        self.view.addSubview( cameraButton )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCamera()
    }
    
    func startCamera() {
        if !self.session.inputs.isEmpty {
            self.toggleSession()
            return
        }
        
        // Enable live stream video
        self.session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        
//        let deviceOutput = AVCaptureVideoDataOutput()
//        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        // Set the quality of the video
        //deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        // What the camera is seeing
        self.session.addInput(deviceInput)
        
        // What we will display on the screen
        self.session.addOutput(capturePhotoOutput)

        // Show the video as it's being captured
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
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
        previewLayer.addSublayer(outline)
        
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
    
    func scanImage(_ image: UIImage) {
        if let tesseract = G8Tesseract(language: StringConstants.lang),
           let scaledImage = image.scaledImage( Defaults.maxDimension ),
           let preprocessedImage = scaledImage.preprocessedImage()
        {
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .sparseText
            
            tesseract.image = preprocessedImage
            tesseract.recognize()
            if let txt = tesseract.recognizedText, !txt.isEmpty {
                print( txt )
            }
        }
    }
    
    @IBAction func takePicture(_ sender: UIButton?) {
        guard let captureConnection = previewLayer.connection else { return }
        
        if let photoOutputConnection = capturePhotoOutput.connection(with: AVMediaType.video) {
          photoOutputConnection.videoOrientation = captureConnection.videoOrientation
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension OcrViewController : AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    print("Finished processing photo")
    
    guard let cgImageRef = photo.cgImageRepresentation() else {
      return print("Could not get image representation")
    }

    let cgImage = cgImageRef.takeUnretainedValue()
    
    print("Scanning image")
    scanImage(UIImage(cgImage: cgImage))
  }
}
