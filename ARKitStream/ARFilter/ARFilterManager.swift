//
//  ARFilterManager.swift
//  ARKitStream
//
//  Created by LAP15651 on 04/11/2022.
//

import Foundation
import ARKit
import ARVideoKit

class ARFilterManager {
    private var configuration: ARFaceTrackingConfiguration!
    
    init() {
        configure()
    }
    func configure() {
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("not support face tracking")
        }
        configuration = ARFaceTrackingConfiguration()
    }
    
    func startPreview(_ previewView: ARSCNView) {
        previewView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopPreview() {
        
    }
}
