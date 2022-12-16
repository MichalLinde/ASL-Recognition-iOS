//
//  ViewController.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    enum CurrentState {
        case recording
        case preview
    }
    
    private var viewModel: MainViewModelProtocol
    private var currentState = CurrentState.preview
    //MARK: AVFoundation
    private var session: AVCaptureSession?
    private var videoOutput = AVCaptureMovieFileOutput()
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private var recordingInProgress = false

    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session?.startRunning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = self.previewContainer.bounds
    }
    
    private func setupLayout() {
        self.view.addSubviews(previewContainer, recordButton, resultLabelContainer)
        previewContainer.fillSuperView()
        self.previewContainer.layer.addSublayer(previewLayer)
        
        recordButton.anchor(bottom: self.view.safeBottomAnchor, paddingBottom: 20)
        recordButton.centerX(inView: self.view)
        
        resultLabelContainer.anchor(top: self.view.safeTopAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor)
        
        resultLabelContainer.addSubview(resultLabel)
        resultLabel.fillSuperView()
        
        self.checkCameraPermission()
    }
    
    private lazy var previewContainer = UIView()
        
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "record.circle")
        button.tintColor = .red
        button.setImage(buttonImage, for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        button.backgroundColor = .white
        return button
    }()
    
    private lazy var resultLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.setHeight(100)
        return view
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    @objc func recordButtonTapped() {
        switch self.currentState {
        case .recording:
            self.videoOutput.stopRecording()
        case .preview:
            switchState()
            self.recordButton.setImage(UIImage(systemName: "stop"), for: .normal)
            self.videoOutput.startRecording(to: createTempFileURL(), recordingDelegate: self)
        }
    }
    
    private func switchState() {
        (self.currentState == .preview) ? (self.currentState = .recording) : (self.currentState = .preview)
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) {
            do {
                session.sessionPreset = .vga640x480
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(videoOutput) {
                    videoOutput.maxRecordedDuration = CMTime(seconds: 5, preferredTimescale: 20)
                    session.addOutput(videoOutput)
                }
                previewLayer.frame = self.previewContainer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                session.commitConfiguration()
                session.startRunning()
                device.set(frameRate: 20)
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    private func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) != .denied {
            Task.init() {
                DispatchQueue.main.async {
                    self.setupCamera()
                }
            }
        }
    }
    
    private func createTempFileURL() -> URL {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                           FileManager.SearchPathDomainMask.userDomainMask, true).last
            let pathURL = NSURL.fileURL(withPath: path!)
            let fileURL = pathURL.appendingPathComponent("movie-\(NSDate.timeIntervalSinceReferenceDate).mov")
            print(" video url:  \(fileURL)")
            return fileURL
        }
}

extension MainViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil, let nserror = error as? NSError, nserror.code != -11810 {
            print("\n\n\n ERROR occured \n \(String(describing: error)) \n\n\n")
            print("\(nserror.code)")
        } else {
            print("\n\n\n Video saved! \n \(outputFileURL) \n\n\n")
//            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            self.recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
            self.switchState()
            self.viewModel.getPrediction(url: outputFileURL)
        }
    }
    
    
}

extension AVCaptureDevice {
    func set(frameRate: Double) {
    guard let range = activeFormat.videoSupportedFrameRateRanges.first,
        range.minFrameRate...range.maxFrameRate ~= frameRate
        else {
            print("Requested FPS is not supported by the device's activeFormat !")
            return
    }

    do { try lockForConfiguration()
        activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
        activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
        unlockForConfiguration()
    } catch {
        print("LockForConfiguration failed with error: \(error.localizedDescription)")
    }
  }
}

extension MainViewController: MainViewModelDelegate {
    func showPrediction(model: PredictionModel) {
        guard let message = model.message else { return }
        DispatchQueue.main.async {
            (!message.isEmpty) ? (self.resultLabel.text = message) : (self.resultLabel.text = "Nothing was detected")
        }
    }
}

