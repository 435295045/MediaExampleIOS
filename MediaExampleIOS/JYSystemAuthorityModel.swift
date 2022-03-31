//
// Created by tyang on 2022/1/8.
//

import Foundation
import AVFoundation

class JYSystemAuthorityModel: NSObject {

    static func checkCamerAuthority(result: @escaping (_ granted: Bool) -> Void) {
        let videAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch videAuthStatus {
        case .authorized:
            result(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (res) in
                result(res)
            }
        default:
            result(false)
        }
    }

    static func checkMicrophoneAuthority(result: @escaping (_ granted: Bool) -> Void) {
        /// 获取麦克风权限
        let videAuthStatus =  AVCaptureDevice.authorizationStatus(for: .audio);
        switch videAuthStatus {
        case .authorized:
            result(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (res) in
                result(res)
            }
        default:
            result(false)
        }
    }
}