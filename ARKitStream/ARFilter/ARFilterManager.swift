//
//  ARFilterManager.swift
//  ARKitStream
//
//  Created by LAP15651 on 04/11/2022.
//

import Foundation
import ARKit
import ARVideoKit
import GPUImage
import VideoToolbox

class ARFilterManager {
    private var configuration: ARFaceTrackingConfiguration!
    
    
    public static let shared = ARFilterManager()
    
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private var rgbBuffer: CVPixelBuffer?
    
    private var input: GPUImageMovie = GPUImageMovie(asset: nil)
    private var pipeline: GPUImageFilterPipeline!
    
    init() {
        configure()
    }
    func configure() {
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("not support face tracking")
        }
        configuration = ARFaceTrackingConfiguration()
        
        let outputFilter = GPUImageFilter()
        
        pipeline = GPUImageFilterPipeline(orderedFilters: [], input: input, output: outputFilter)
        
        
        outputFilter.frameProcessingCompletionBlock = { [weak self] (filterOut: GPUImageOutput?, time: CMTime) -> Void in
            
            let frameBuffer = filterOut?.framebufferForOutput()
            
            guard let buffer = frameBuffer else {
                return;
            }
            
            glFinish()
            
            self?.rgbBuffer = buffer.renderTarget() // phat ra view
//            if let buffer = self?.rgbBuffer {
//                let image = UIImage(pixelBuffer: buffer)
//                print("")
//            }
            
            
            self?.semaphore.signal()
        }
    }
    
    public func process(pixelBuffer: CVPixelBuffer) -> Void {
//        guard pipeline.filters.count > 0 || filterChange else {
//            return
//        }
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let final_y_buffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)?.assumingMemoryBound(to: uint8.self);
        let final_uv_buffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)?.assumingMemoryBound(to: uint8.self);
        input.processMovieFrame(createSampleBufferFrom(pixelBuffer: pixelBuffer))
        //input.processMovieFrame(pixelBuffer, withSampleTime: .zero) // pass to gpuimage process
        _ = semaphore.wait(timeout: .distantFuture) // wait cho toi khi rgbBuffer update after filter
        CVPixelBufferLockBaseAddress(rgbBuffer!, [])
        let width = CVPixelBufferGetWidth(rgbBuffer!)
        let height = CVPixelBufferGetHeight(rgbBuffer!)
        let rgbAddress = CVPixelBufferGetBaseAddress(rgbBuffer!)?.assumingMemoryBound(to: uint8.self)
        // update processed buffer
        ARGBToNV12(rgbAddress, Int32(width*4), final_y_buffer, Int32(width), final_uv_buffer, Int32(width), Int32(width), Int32(height))
        CVPixelBufferUnlockBaseAddress(rgbBuffer!, [])
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
//        if filterChange {
//            switchFilter()
//        }
    }
    
    func startPreview(_ previewView: ARSCNView) {
        previewView.session = ZARSession()
        previewView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopPreview() {
        
    }
    
    // convert pixel to sample
    func createSampleBufferFrom(pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        var timimgInfo  = CMSampleTimingInfo()
        var formatDescription: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
        
        let osStatus = CMSampleBufferCreateReadyWithImageBuffer(
          allocator: kCFAllocatorDefault,
          imageBuffer: pixelBuffer,
          formatDescription: formatDescription!,
          sampleTiming: &timimgInfo,
          sampleBufferOut: &sampleBuffer
        )
        
        // Print out errors
        if osStatus == kCMSampleBufferError_AllocationFailed {
          print("osStatus == kCMSampleBufferError_AllocationFailed")
        }
        if osStatus == kCMSampleBufferError_RequiredParameterMissing {
          print("osStatus == kCMSampleBufferError_RequiredParameterMissing")
        }
        if osStatus == kCMSampleBufferError_AlreadyHasDataBuffer {
          print("osStatus == kCMSampleBufferError_AlreadyHasDataBuffer")
        }
        if osStatus == kCMSampleBufferError_BufferNotReady {
          print("osStatus == kCMSampleBufferError_BufferNotReady")
        }
        if osStatus == kCMSampleBufferError_SampleIndexOutOfRange {
          print("osStatus == kCMSampleBufferError_SampleIndexOutOfRange")
        }
        if osStatus == kCMSampleBufferError_BufferHasNoSampleSizes {
          print("osStatus == kCMSampleBufferError_BufferHasNoSampleSizes")
        }
        if osStatus == kCMSampleBufferError_BufferHasNoSampleTimingInfo {
          print("osStatus == kCMSampleBufferError_BufferHasNoSampleTimingInfo")
        }
        if osStatus == kCMSampleBufferError_ArrayTooSmall {
          print("osStatus == kCMSampleBufferError_ArrayTooSmall")
        }
        if osStatus == kCMSampleBufferError_InvalidEntryCount {
          print("osStatus == kCMSampleBufferError_InvalidEntryCount")
        }
        if osStatus == kCMSampleBufferError_CannotSubdivide {
          print("osStatus == kCMSampleBufferError_CannotSubdivide")
        }
        if osStatus == kCMSampleBufferError_SampleTimingInfoInvalid {
          print("osStatus == kCMSampleBufferError_SampleTimingInfoInvalid")
        }
        if osStatus == kCMSampleBufferError_InvalidMediaTypeForOperation {
          print("osStatus == kCMSampleBufferError_InvalidMediaTypeForOperation")
        }
        if osStatus == kCMSampleBufferError_InvalidSampleData {
          print("osStatus == kCMSampleBufferError_InvalidSampleData")
        }
        if osStatus == kCMSampleBufferError_InvalidMediaFormat {
          print("osStatus == kCMSampleBufferError_InvalidMediaFormat")
        }
        if osStatus == kCMSampleBufferError_Invalidated {
          print("osStatus == kCMSampleBufferError_Invalidated")
        }
        if osStatus == kCMSampleBufferError_DataFailed {
          print("osStatus == kCMSampleBufferError_DataFailed")
        }
        if osStatus == kCMSampleBufferError_DataCanceled {
          print("osStatus == kCMSampleBufferError_DataCanceled")
        }
        
        guard let buffer = sampleBuffer else {
          print("Cannot create sample buffer")
          return nil
        }
        
        return buffer
      }
}


extension GPUImageFramebuffer {
    func renderTarget() -> CVPixelBuffer {
        return self.value(forKey: "renderTarget") as! CVPixelBuffer
    }
}
extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }

        self.init(cgImage: cgImage)
    }
}


class ZARSession: ARSession {
    override var currentFrame: ARFrame? {
        let frame = super.currentFrame
        if let buffer = frame?.capturedImage {
            ARFilterManager.shared.process(pixelBuffer: buffer)
        }
        return frame
    }
}
