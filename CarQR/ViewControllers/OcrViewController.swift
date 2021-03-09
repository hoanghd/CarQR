import AVFoundation
import Vision
import UIKit

class OcrViewController: BaseViewController {
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var previewLayer:AVCaptureVideoPreviewLayer!
    var capturePhotoOutput = AVCapturePhotoOutput()
    
    var widthBox: CGFloat = 300
    var heightBox: CGFloat = 50
    
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
        
        outline.frame = CGRect(x: (self.screenWidth - widthBox)/2, y: (self.screenHeight - heightBox)/2, width: widthBox, height: heightBox)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.white.cgColor
        return outline
    }()
    
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: (self.screenWidth - widthBox)/2, y: (self.screenHeight - 130), width: widthBox, height: heightBox))
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview( videoOutputView )
        self.view.addSubview( cameraButton )
        self.view.addSubview( imgView )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startCamera()
        startTextRecognition()
    }
    
    func startTextRecognition() {
        let textRequest = VNRecognizeTextRequest(completionHandler: self.detectTextHandler)
        textRequest.recognitionLanguages = ["en-US"]
        textRequest.recognitionLevel = .accurate
        
        self.requests = [textRequest]
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
        let imageInBox = image.cropBox( self.previewLayer, self.outline.frame )
        imgView.image = imageInBox
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: imageInBox.cgImage!, orientation: .up)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print("detectTextHandler:\(error!)")
        }
        
        guard let results = request.results else {
            return
        }

        // Perform UI updates on the main thread
        DispatchQueue.main.async {
            for result in results {
                if let observation = result as? VNRecognizedTextObservation {
                    for text in observation.topCandidates(1) {
                        print(text.string)
                    }
                }
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
    guard let cgImageRef = photo.cgImageRepresentation() else {
      return print("Could not get image representation")
    }

    let cgImage = cgImageRef.takeUnretainedValue()
    scanImage( UIImage(cgImage: cgImage, scale: 1.0, orientation: .up) )
  }
}
