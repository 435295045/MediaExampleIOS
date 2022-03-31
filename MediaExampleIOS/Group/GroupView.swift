import Foundation
import SwiftUI
import UIKit
import WebRTC
import MediaRTC

class GroupView: UIViewController, CameraSessionDelegate {
    let representation: GroupViewRepresentation!;
    var cameraSession: CameraSession?
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    var rtcRenderViews: [RTCRenderView]! = []
    var videoViewContainter: UIView!
    var peer: Peer?;
    let initiator: Bool;
    let clientId: String;

    init(representation: GroupViewRepresentation, initiator: Bool, clientId: String) {
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
        MediaSDK.group().addListener(listener: self)
        view.backgroundColor = UIColor.black
        videoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.7))
        view.addSubview(videoViewContainter)
        let viewRoomOperationController = ViewRoomOperationController(onClickListener: self, frame: CGRect(x: 0, y: view.bounds.height - ScreenSizeUtil.height() * 0.2, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.2))
        if (!initiator) {
            viewRoomOperationController.answerHidden(isHidden: false)
        } else {
            /*if !MediaSDK.group().call(clientId: clientId) {
                UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true)
            }*/
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
        //移除监听（必须）
        MediaSDK.group().removeListener(listener: self)
        //释放呼叫（必须）
        MediaSDK.group().release();
        //摄像头停止采集
        cameraSession?.stop();
    }
}

extension GroupView {
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

extension GroupView: GroupListener {
    func onGroupListener(event: GroupState) {
        if case let GroupState.offerAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let GroupState.answer(clientId: clientId) = event {
            MediaSDK.group().producer(video: true);
        } else if case let GroupState.answerAck(code: code, data: data) = event {
            if code == 200 {
                MediaSDK.group().producer(video: true);
                MediaSDK.group().consume(clientId: nil);
            }
        } else if case let GroupState.hangUp(clientId: clientId, code: code, data: data) = event {
            let myClientId = NSUserDefaultsUtils.string(key: "client");
            //如果挂断的是自己
            if (myClientId == clientId) {
                UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true)
            } else {
                let index = rtcRenderViews.firstIndex(where: { (arr) -> Bool in
                    arr.streamId == clientId
                })
                if index != nil {
                    let rtcRenderView = rtcRenderViews[index!]
                    rtcRenderView.renderView.removeFromSuperview()
                    rtcRenderViews.remove(at: index!)
                }
                refreshUI();
            }
        } else if case let GroupState.producer(clientId: clientId) = event {
            MediaSDK.group().consume(clientId: nil);
        } else if case let GroupState.producerAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let GroupState.consumeAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let GroupState.media(peer: peer, stream: stream) = event {
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

extension GroupView: OnClickListener {
    func muteListener() {
        if peer != nil {
            peer!.microphone(enabled: !peer!.isMicrophone())
        }
    }

    func handFreeListener() {
        if peer != nil {
            peer!.speak(enabled: !peer!.isSpeak())
        }
    }

    func openCameraListener() {
        if peer != nil {
            peer!.videoEnabled(enabled: !peer!.isVideoEnabled())
        }
    }

    func hangUpListener() {
        MediaSDK.group().hangUp();
        representation.dismiss();
    }

    func switchCameraListener() {
        peer?.switchCameraPosition()
    }

    func answerListener() {
        MediaSDK.group().answer();
    }
}
