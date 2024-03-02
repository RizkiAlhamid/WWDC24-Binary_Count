import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer? 
    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraFeedSession == nil {
            self.previewLayer?.videoGravity = .resizeAspectFill
            setupCamera()
            self.previewLayer?.session = cameraFeedSession
        }
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .landscapeLeft:
            self.previewLayer?.connection?.videoRotationAngle = 180
        case .landscapeRight:
             self.previewLayer?.connection?.videoRotationAngle = 180           
        default:
            self.previewLayer?.connection?.videoRotationAngle = 0
        }
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func setupCamera() {
        do {
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                return
            }
            
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            let session = AVCaptureSession()
            session.beginConfiguration()
            session.sessionPreset = AVCaptureSession.Preset.high
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.layer.bounds
            previewLayer.connection?.videoRotationAngle = 180
            view.layer.addSublayer(previewLayer)
            
            let dataOutput = AVCaptureVideoDataOutput()
            if session.canAddOutput(dataOutput) {
                session.addOutput(dataOutput)
                dataOutput.alwaysDiscardsLateVideoFrames = true
                dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            }
            
            session.commitConfiguration()
            self.cameraFeedSession = session
            self.previewLayer = previewLayer
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    func startSession() {
        cameraFeedSession?.startRunning()
    }
    
    func stopSession() {
        cameraFeedSession?.stopRunning()
    }
    
    func processPoints(_ fingers: [Finger]) {
        var convertedPoints: [CGPoint] = []
        for finger in fingers {
            let convertedTip = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: finger.tip)
            let convertedDip = self.previewLayer!.layerPointConverted(fromCaptureDevicePoint: finger.dip)
            convertedPoints.append(convertedTip)
            convertedPoints.append(convertedDip)
        }
        viewModel?.overlayPoints = convertedPoints
        if viewModel?.gameState == .instructionAndTracking {
            viewModel?.proceedWithPracticalInstruction(fingers)
        } else if viewModel?.gameState == .playing {
            viewModel?.processFingers(fingers)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard viewModel?.gameState == .playing || viewModel?.gameState == .instructionAndTracking else { return }
        
        var fingers: [Finger] = []
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(fingers)
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .upMirrored, options: [:])
        do {
            // Perform VNDtectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            guard let detectedHandPoses = handPoseRequest.results?.prefix(2), !detectedHandPoses.isEmpty else {
                return
            }
            let accuracyThreshold: Float = 0.8
            for hand in detectedHandPoses {
                let allPoints = try hand.recognizedPoints(.all)
                
                if let thumbTipPoint = allPoints[.thumbTip], let thumbMPPoint = allPoints[.thumbMP] {
                    if thumbTipPoint.confidence > accuracyThreshold && thumbMPPoint.confidence > accuracyThreshold {
                        fingers.append(Finger(name: .thumb,
                                              tip: convertCoordinate(thumbTipPoint),
                                              dip: convertCoordinate(thumbMPPoint),
                                              hand: hand.chirality == .right ? .right : .left))
                    }
                }
                
                if let indexTipPoint = allPoints[.indexTip], let indexDIPPoint = allPoints[.indexDIP] {
                    if indexTipPoint.confidence > accuracyThreshold && indexDIPPoint.confidence > accuracyThreshold {
                        fingers.append(Finger(name: .index,
                                              tip: convertCoordinate(indexTipPoint),
                                              dip: convertCoordinate(indexDIPPoint),
                                              hand: hand.chirality == .right ? .right : .left))
                    }
                }
                
                if let middleTipPoint = allPoints[.middleTip], let middleDIPPoint = allPoints[.middleDIP] {
                    if middleTipPoint.confidence > accuracyThreshold && middleDIPPoint.confidence > accuracyThreshold {
                        fingers.append(Finger(name: .middle,
                                              tip: convertCoordinate(middleTipPoint),
                                              dip: convertCoordinate(middleDIPPoint),
                                              hand: hand.chirality == .right ? .right : .left))
                    }
                }
                if let ringTipPoint = allPoints[.ringTip], let ringDIPPoint = allPoints[.ringDIP] {
                    if ringTipPoint.confidence > accuracyThreshold && ringDIPPoint.confidence > accuracyThreshold {
                        fingers.append(Finger(name: .ring,
                                              tip: convertCoordinate(ringTipPoint),
                                              dip: convertCoordinate(ringDIPPoint),
                                              hand: hand.chirality == .right ? .right : .left))
                    }
                }
                
                if let littleTipPoint = allPoints[.littleTip], let littleDIPPoint = allPoints[.littleDIP] {
                    if littleTipPoint.confidence > accuracyThreshold && littleDIPPoint.confidence > accuracyThreshold {
                        fingers.append(Finger(name: .little,
                                              tip: convertCoordinate(littleTipPoint),
                                              dip: convertCoordinate(littleDIPPoint),
                                              hand: hand.chirality == .right ? .right : .left))
                    }
                }
                
            }
        } catch {
            cameraFeedSession?.stopRunning()
        }
        
    }
    func convertCoordinate(_ point: VNRecognizedPoint) -> CGPoint {
        return CGPoint(x: 1 - point.location.x, y: 1 - point.location.y)
    }
}




