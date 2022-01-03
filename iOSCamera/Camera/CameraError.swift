//
//  CameraError.swift
//  iOSCamera
//
//  Created by Jiwon_Hae on 2022/01/04.
//

import Foundation

enum CameraError : Error{
    case CameraUnavailable
    case CannotAddInput
    case CannotAddOutput
    case CreateCaptureInput(Error)
    case DeniedAuthorization
    case RestrictedAuthorization
    case UnknownAuthorization
}

extension CameraError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .CameraUnavailable:
      return "Camera unavailable"
    case .CannotAddInput:
      return "Cannot add capture input to session"
    case .CannotAddOutput:
      return "Cannot add video output to session"
    case .CreateCaptureInput(let error):
      return "Creating capture input for camera: \(error.localizedDescription)"
    case .DeniedAuthorization:
      return "Camera access denied"
    case .RestrictedAuthorization:
      return "Attempting to access a restricted capture device"
    case .UnknownAuthorization:
      return "Unknown authorization status for capture device"
    }
  }
}
