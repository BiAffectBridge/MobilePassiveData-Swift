//
//  AudioRecorderAuthorization.swift
//
//  Copyright © 2020-2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import AVFoundation
import MobilePassiveData

fileprivate let _userDefaultsKey = "rsd_AudioRecorderStatus"

/// `AudioRecorderAuthorization` is a wrapper for requestion permission to record audio.
///
/// Before using this adaptor, the calling application or framework will need to  register the
/// adaptor using `PermissionAuthorizationHandler.registerAdaptorIfNeeded()`.
///
/// You will need to add the privacy permission for using the microphone to the application `Info.plist`
/// file. As of this writing (syoung 09/02/2020), the required key is:
/// - `Privacy - Microphone Usage Description`
public final class AudioRecorderAuthorization : PermissionAuthorizationAdaptor {
    
    public static let shared = AudioRecorderAuthorization()
    
    /// This adaptor is intended for checking for audio recording permission.
    public let permissions: [PermissionType] = [StandardPermissionType.microphone]
    
    /// Returns the authorization status for recording audio.
    public func authorizationStatus(for permission: String) -> PermissionAuthorizationStatus {
        guard permission == StandardPermissionType.microphone.rawValue else { return .notDetermined }
        return AudioRecorderAuthorization.authorizationStatus()
    }
    
    static public func authorizationStatus() -> PermissionAuthorizationStatus {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .denied:
            return .denied
        case .granted:
            return .authorized
        default:
            return .notDetermined
        }
    }
    
    /// Requests permission to record.
    public func requestAuthorization(for permission: Permission, _ completion: @escaping ((PermissionAuthorizationStatus, Error?) -> Void)) {
        guard permission.identifier == StandardPermissionType.microphone.rawValue else {
            completion(.notDetermined, nil)
            return
        }
        return AudioRecorderAuthorization.requestAuthorization(completion)
    }

    /// Request authorization to record.
    static public func requestAuthorization(_ completion: @escaping ((PermissionAuthorizationStatus, Error?) -> Void)) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                completion(.authorized, nil)
            } else {
                completion(.denied, nil)
            }
        }
    }
}
