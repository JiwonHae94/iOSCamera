//
//  CameraManager.swift
//  iOSCamera
//
//  Created by Jiwon_Hae on 2022/01/04.
//

import Foundation
import AVFoundation

class CameraManager : ObservableObject{
    @Published var error : CameraError?
    
    private var currentPosition = AVCaptureDevice.Position.front
    
    enum Status{
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "iOSCameraApp.CameraSesssionQueue")
    private var cameraInput : AVCaptureInput? = nil
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var status = Status.unconfigured
    
    static let shared = CameraManager()
    
    private init(){
        configure()
    }
    

    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue){
    
        // set delegate to handle incoming frames
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
    private func configure(){

        // check camera permission
        checkCameraPermission()
        
        // if camera permission is granted
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    func switchCamera(){
        if(currentPosition == .front || currentPosition == .unspecified){
            currentPosition = .back
        }else{
            currentPosition = .front
        }
        
        if cameraInput != nil{
            session.removeInput(cameraInput!)
        }
        session.removeOutput(videoOutput)
        status = .unconfigured
        configure()
    }
    
    private func stop(){
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    private func configureCaptureSession(){
        guard status == .unconfigured else{
            return
        }
        
        // begin configuretation
        session.beginConfiguration()
        
        defer{
            // commit configuration
            session.commitConfiguration()
        }
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition)
        
        guard let camera = device else{
            // check whether camera is avaialble
            set(error: .CameraUnavailable)
            status = .failed
            return
        }
        
        
        do{
            // create camera input
            cameraInput = try AVCaptureDeviceInput(device: camera)
            
            // add camera input to the session
            if session.canAddInput(cameraInput!){
                session.addInput(cameraInput!)
                
            } else{
                set(error: .CannotAddInput)
                status = .failed
                return
            }
            
            // add camera output to the session
            if session.canAddOutput(videoOutput){
                session.addOutput(videoOutput)
                
                // set format of the video output
                videoOutput.videoSettings =  [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                
                let videoConnection = videoOutput.connection(with: .video)
                videoConnection?.videoOrientation = .portrait
            }else{
                set(error: .CannotAddOutput)
                print(error)
                status = .failed
                return
            }
            
            // configuration made
            status = .configured
            
        }catch{
            // set error if camera catpure session fails
            set(error: .CreateCaptureInput(error))
            status = .failed
            return
        }
        
    }
    
    private func set(error : CameraError?){
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    private func checkCameraPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            // if not determined, suspend queue
            sessionQueue.suspend()
            
            // request permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { authorized in
                if !authorized{
                    self.status = .unauthorized
                    self.set(error: .DeniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .RestrictedAuthorization)
            
        case .denied:
            status = .unauthorized
            set(error: .DeniedAuthorization)
            
        case .authorized:
            break
            
        @unknown default:
            // set default authorization to authorization unknown
            status = .unauthorized
            set(error:  .UnknownAuthorization)
        }
    
    
    }
}
