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
        self.view.addSubviews(previewContainer, recordButton, resultLabelContainer, loadingView, resultLabelFiller, infoButton)
        
        previewContainer.fillSuperView()
        self.previewContainer.layer.addSublayer(previewLayer)
        
        recordButton.anchor(
            bottom: self.view.safeBottomAnchor,
            paddingBottom: 20
        )
        recordButton.centerX(inView: self.view)
        
        resultLabelContainer.anchor(
            top: self.view.safeTopAnchor,
            left: self.view.leftAnchor,
            right: self.view.rightAnchor
        )
        
        resultLabelContainer.addSubview(resultLabel)
        resultLabel.fillSuperView()
        
        loadingView.isHidden = true
        loadingView.fillSuperView()
        
        resultLabelFiller.anchor(
            top: self.view.topAnchor,
            left: self.view.leftAnchor,
            bottom: self.resultLabelContainer.topAnchor,
            right: self.view.rightAnchor
        )
        
        infoButton.anchor(
            top: resultLabel.bottomAnchor,
            right: self.view.rightAnchor,
            paddingTop: 15,
            paddingRight: 15
        )
        
        self.view.insertSubview(noLandMarksPopup, aboveSubview: self.previewContainer)
        noLandMarksPopup.fillSuperView()
        
        self.checkCameraPermission()
    }
    
    private lazy var previewContainer = UIView()
        
    private lazy var recordButton: UIButton = {
        let button = UIButton()
        button.tintColor = .red
        button.setDimensions(height: 80, width: 80)
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        button.backgroundColor = .black.withAlphaComponent(0.7)
        button.addSubview(recordButtonImage)
        recordButtonImage.center(inView: button)
        return button
    }()
    
    private lazy var recordButtonImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "record.circle")?.withTintColor(.red)
        view.contentMode = .scaleAspectFit
        view.setDimensions(height: 80, width: 80)
        view.layer.cornerRadius = 40
        return view
    }()
    
    private lazy var resultLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.setHeight(100)
        return view
    }()
    
    private lazy var resultLabelFiller: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        return view
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var loadingView = LoadingView()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "questionmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.7)
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        button.setDimensions(height: 42, width: 42)
        button.layer.cornerRadius = 21
        return button
    }()
    
    private lazy var noLandMarksPopup: NoLandmarksPopupView = {
        let view = NoLandmarksPopupView()
        view.alpha = .zero
        view.delegate = self
        return view
    }()
    
    @objc func recordButtonTapped() {
        switch self.currentState {
        case .recording:
            self.videoOutput.stopRecording()
        case .preview:
            switchState()
            self.recordButtonImage.image = UIImage.init(systemName: "stop")?.withTintColor(.red)
            self.videoOutput.startRecording(to: createTempFileURL(), recordingDelegate: self)
        }
    }
    
    @objc func infoButtonTapped() {
        DispatchQueue.main.async {
            self.present(UserInfoViewController(), animated: true)
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
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    try device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                }
                session.sessionPreset = .hd1280x720
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(videoOutput) {
                    videoOutput.maxRecordedDuration = CMTime(seconds: 8, preferredTimescale: 20)
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
                self.presentAlert(AlertManager.showActionSheetMessage(message: "Sorry, there was an error during camera setup. Please try again."), animated: true, length: AlertLenght.error)
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
            return fileURL
        }
    
    private func showLoadingView() {
        self.loadingView.isHidden = false
        self.loadingView.spinner.startAnimating()
    }
    
    private func hideLoadingView() {
        self.loadingView.spinner.stopAnimating()
        self.loadingView.isHidden = true
    }
    
    private func showResultOnLabel(message: String) {
        self.resultLabel.text = self.viewModel.getTextToDisplay(currentText: self.resultLabel.text, newText: message)
    }
    
    func presentAlert(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil, length: AlertLenght) {
        self.present(viewControllerToPresent, animated: true)
        Task.init {
            try await Task.sleep(nanoseconds: length.lenght)
            viewControllerToPresent.dismiss(animated: true)
        }
    }
}

extension MainViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil, let nserror = error as? NSError, nserror.code != -11810 {
            self.presentAlert(AlertManager.showActionSheetMessage(message: "Sorry, an error occured during file processing. Please try again."), animated: true, length: AlertLenght.error)
        } else {
            self.recordButtonImage.image = UIImage.init(systemName: "record.circle")?.withTintColor(.red)
            self.switchState()
            self.viewModel.getPrediction(url: outputFileURL)
            self.loadingView.isHidden = false
            self.loadingView.spinner.startAnimating()
        }
    }
}

extension MainViewController: MainViewModelDelegate {
    func showNoLandmarksPopup() {
        DispatchQueue.main.async {
            self.recordButton.isEnabled = false
            self.noLandMarksPopup.animateUp()
        }
    }
    
    func showErrorAlert(error: String) {
        DispatchQueue.main.async {
            self.hideLoadingView()
            self.presentAlert(AlertManager.showActionSheetMessage(message: error), animated: true, length: AlertLenght.error)
        }
    }
    
    func hideLoadingScreen() {
        DispatchQueue.main.async {
            self.hideLoadingView()
        }
    }
    
    func showPrediction(model: PredictionModel) {
        guard let message = model.message else { return }
        DispatchQueue.main.async {
            (!message.isEmpty) ? (self.showResultOnLabel(message: message)) : (self.presentAlert(AlertManager.showActionSheetMessage(message: "Sorry, no word was detected."), animated: true, length: AlertLenght.output))
        }
    }
}

extension MainViewController: NoLandmarksPopupViewDelegate {
    func closePopup() {
        self.noLandMarksPopup.animateDown {
            self.recordButton.isEnabled = true
        }
    }
}

enum AlertLenght {
    case error
    case output
    
    var lenght: UInt64 {
        switch self {
        case .error:
            return 4_000_000_000
        case .output:
            return 2_500_000_000
        }
    }
}

