import Foundation
import SwiftUI
import UIKit
import WebRTC
import MediaRTC

class P2PView: UIViewController, CameraSessionDelegate {
    let representation: P2PViewRepresentation!;
    var cameraSession: CameraSession?
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    var rtcRenderViews: [RTCRenderView]! = []
    var videoViewContainter: UIView!
    var peer: Peer?;
    let initiator: Bool;
    let clientId: String;

    init(representation: P2PViewRepresentation, initiator: Bool, clientId: String) {
        self.representation = representation;
        self.initiator = initiator;
        self.clientId = clientId;
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)
        useCustomCapturer = false
        #endif

        if useCustomCapturer {
            cameraSession = CameraSession()
            cameraSession?.delegate = self
            cameraSession?.start()
            cameraFilter = CameraFilter()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        MediaSDK.p2p().addListener(listener: self)
        view.backgroundColor = UIColor.black
        videoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.7))
        view.addSubview(videoViewContainter)
        let viewRoomOperationController = ViewRoomOperationController(onClickListener: self, frame: CGRect(x: 0, y: view.bounds.height - ScreenSizeUtil.height() * 0.2, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.2))
        if (!initiator) {
            viewRoomOperationController.answerHidden(isHidden: false)
        } else {
            if !MediaSDK.p2p().call(clientId: clientId) {
                UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true)
            }
        }
        view.addSubview(viewRoomOperationController)
    }

    func refreshUI() {
        for (index, value) in rtcRenderViews.enumerated() {
            value.calculationCGRect(size: rtcRenderViews.count, index: index)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("-------------------------------viewDidDisappear")
        //移除监听（必须）
        MediaSDK.p2p().removeListener(listener: self)
        //释放呼叫（必须）
        MediaSDK.p2p().release();
        //摄像头停止采集
        cameraSession?.stop();
    }
}

extension P2PView {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
        if useCustomCapturer {
            if let cvpixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                if let buffer = cameraFilter?.apply(cvpixelBuffer) {
                    peer?.captureCurrentFrame(sampleBuffer: buffer)
                } else {
                    print("no applied image")
                }
            } else {
                print("no pixelbuffer")
            }
        }
    }
}

extension P2PView: P2PListener {
    func onP2PListener(event: P2PState) {
        if case let P2PState.offerAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let P2PState.answer = event {

        } else if case let P2PState.answerAck(code: code, data: data) = event {

        } else if case let P2PState.hangUp(code: code, data: data) = event {
            UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true)
        } else if case let P2PState.media(peer: peer, stream: stream) = event {
            if (stream == nil) {
                self.peer = peer;
                let rtcRenderView = RTCRenderView()
                videoViewContainter.addSubview(rtcRenderView.renderView)
                rtcRenderViews.append(rtcRenderView)
                rtcRenderView.renderView?.renderFrame(nil)
                peer.localVidew(renderView: rtcRenderView.renderView)
                refreshUI();
            } else {
                let remoteVideoTrack = stream!.videoTracks.first
                let rtcRenderView = RTCRenderView()
                rtcRenderView.streamId = peer.id
                videoViewContainter.addSubview(rtcRenderView.renderView)
                rtcRenderViews.append(rtcRenderView)
                rtcRenderView.renderView?.renderFrame(nil)
                rtcRenderView.setRemoteVideoTrack(remoteVideoTrack: remoteVideoTrack)
                refreshUI();
            }
        }
    }
}

extension P2PView: OnClickListener {
    func muteListener() {

    }

    func handFreeListener() {

    }

    func openCameraListener() {

    }

    func hangUpListener() {
        MediaSDK.p2p().hangUp();
        representation.dismiss();
    }

    func switchCameraListener() {

    }

    func answerListener() {
        MediaSDK.p2p().answer();
    }
}
