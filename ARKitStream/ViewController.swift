//
//  ViewController.swift
//  ARKitStream
//
//  Created by LAP15651 on 03/11/2022.
//

import UIKit
import ARKit
import ARVideoKit
import GPUImage
import libksygpulive

class ViewController: UIViewController {

    @IBOutlet weak var previewView: ARSCNView!
    
    private var liveStreamManager: LiveStreamManager!
    
    private var arFilterManager: ARFilterManager!
    
    private var arRecorder: RecordAR!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARRecord()
        setupAR()
        setupLiveStream()
        observeStreamState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            //self?.liveStreamManager.startStream()
            ARFilterManager.shared.next()
            
            try? self?.previewView.startVideoRecording()
        }
    }
    
    private func setupARRecord() {
//        arRecorder = RecordAR(ARSceneKit: previewView)
//        arRecorder.renderAR = self
//        arRecorder.enableAudio = false
//        arRecorder.onlyRenderWhileRecording = false
        // scnrecoder setup
        previewView.prepareForRecording()
    }
    
    private func setupLiveStream() {
        liveStreamManager = LiveStreamManager()
        liveStreamManager.delegate = self
        liveStreamManager.useKsyLiveAudioCap = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        ARFilterManager.shared.startPreview(previewView)

        //liveStreamManager.startAudioCapture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewView.session.pause()
        liveStreamManager.stopAudioCapture()
    }
    
    private func setupAR() {
 
    }
    
    private func observeStreamState() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(notification:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    }
    
    @objc func onStreamStateChange(notification: Notification) {
        switch liveStreamManager.streamState {
        case .idle:
            print("state Idle")
        case .connecting:
            print("state Connecting")
        case .connected:
            print("state Connected")
        case .disconnecting:
            print("state Disconnecting")
        case .error:
            print("state Error:")
        default:
            break
        }
    }

}

// MARK: LiveStreamManagerDelegate
extension ViewController: LiveStreamManagerDelegate {
    func didStartStream() {
        print("didStart")
    }
    
    func didStopStream() {
        print("didStop")
    }
}

extension ViewController: RenderARDelegate {
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        liveStreamManager.processVideoPixelBuffer(buffer, timeInfor: time) // push live
    }
}
