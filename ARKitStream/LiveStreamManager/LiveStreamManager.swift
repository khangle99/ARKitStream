//
//  LiveStreamManager.swift
//  ARKitStream
//
//  Created by LAP15651 on 04/11/2022.
//

import Foundation
import libksygpulive

protocol LiveStreamManagerDelegate: AnyObject {
    func didStartStream()
    func didStopStream()
}

class LiveStreamManager: NSObject {
    weak var delegate: LiveStreamManagerDelegate?
    private let streamerKit = KSYGPUStreamerKit(defaultCfg: ())
    
    override init() {
        super.init()
        
        streamerKit?.streamerBase.videoCodec = .VT264
        streamerKit?.streamerBase.audioCodec = .AAC
        streamerKit?.capturePixelFormat = kCVPixelFormatType_32BGRA
        streamerKit?.streamerBase.audiokBPS = 64
        streamerKit?.videoFPS = 24
        
        streamerKit?.streamerBase.bwEstimateMode = .estMode_Default
        
        streamerKit?.aCapDev.audioProcessingCallback = { [weak self] sampleBuffer in
            guard let self = self,
                  let sampleBuffer = sampleBuffer else { return }
            if self.useKsyLiveAudioCap {
                self.streamerKit?.streamerBase.processAudioSampleBuffer(sampleBuffer)
            }
        }
    }
    
    var isStreaming: Bool {
        return streamerKit?.streamerBase.isStreaming() ?? false
    }
    
    var streamWithAudio: Bool = true {
        didSet {
            streamerKit?.streamerBase.bWithAudio = streamWithAudio
        }
    }
    
    var useKsyLiveAudioCap: Bool = true
    
    var streamState: KSYStreamState? {
        let state = streamerKit?.streamerBase.streamState
        if state == .error,
           let errorCode = streamerKit?.streamerBase.streamErrorCode,
           let errorName = streamerKit?.streamerBase.getKSYStreamErrorCodeName(errorCode) {
            print("ErrorName: \(errorName)")
        }
        return  state
    }
    
    func startAudioCapture() {
        streamerKit?.aCapDev.start()
    }
    
    func stopAudioCapture() {
        streamerKit?.aCapDev.stop()
    }
    
    func processVideoPixelBuffer(_ buffer: CVPixelBuffer, timeInfor: CMTime) {
        streamerKit?.streamerBase.processVideoPixelBuffer(buffer, timeInfo: timeInfor)
    }
    
    func processAudioBuffer(_ sampleBuffer: CMSampleBuffer) {
        if useKsyLiveAudioCap {
            return
        }
        streamerKit?.streamerBase.processAudioSampleBuffer(sampleBuffer)
    }
    
    func startStream() {
        let url = URL(string: "rtmp://192.168.101.161/live/hello")! // force cast for demo
        streamerKit?.streamerBase.startStream(url)
        delegate?.didStartStream()
    }
    
    func stopStream() {
        streamerKit?.streamerBase.stopStream()
        delegate?.didStopStream()
    }
}
