//
//  FrameManager.swift
//  iOSCamera
//
//  Created by Jiwon_Hae on 2022/01/04.
//

import Foundation
import AVFoundation

class FrameManager: NSObject, ObservableObject{
    static var shared = FrameManager()
    
    @Published var current : CVPixelBuffer?
    
    let videoOutputQueue = DispatchQueue(
        label: "iOSCameraApp.VideoOutputQ",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    private override init(){
        super.init()
        
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
}

extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(
        _ output : AVCaptureOutput,
        didOutput sampleBuffer : CMSampleBuffer,
        from connection : AVCaptureConnection
    ){
        if let buffer = sampleBuffer.imageBuffer{
            DispatchQueue.main.async {
                self.current = buffer
            }
        }
    }
}
