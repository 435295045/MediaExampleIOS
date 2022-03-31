//
// Created by tyang on 2022/3/24.
//

import Foundation
import SwiftUI
import UIKit
import WebRTC
import MediaRTC
import WebSocket

class RoomView: UIViewController, CameraSessionDelegate {
    let representation: RoomViewRepresentation!;
    var cameraSession: CameraSession?
    var useCustomCapturer: Bool = false
    var cameraFilter: CameraFilter?
    var rtcRenderViews: [RTCRenderView]! = []
    var videoViewContainter: UIView!
    var peer: Peer?;
    let roomId: String;

    init(representation: RoomViewRepresentation, roomId: String) {
        self.representation = representation;
        self.roomId = roomId;
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
        MediaSDK.room().addListener(listener: self)
        view.backgroundColor = UIColor.black
        videoViewContainter = UIView(frame: CGRect(x: 0, y: 0, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.7))
        view.addSubview(videoViewContainter)
        let viewRoomOperationController = ViewRoomOperationController(onClickListener: self, frame: CGRect(x: 0, y: view.bounds.height - ScreenSizeUtil.height() * 0.2, width: ScreenSizeUtil.width(), height: ScreenSizeUtil.height() * 0.2))
        viewRoomOperationController.answerHidden(isHidden: false)
        view.addSubview(viewRoomOperationController)

        do {
            print("-------------------------------roomId\(roomId)")
            try MediaSDK.room().join(roomId: roomId)
        } catch {
            print("-------------------------------catch\(error)")
        }
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
        MediaSDK.room().removeListener(listener: self)
        //释放呼叫（必须）
        MediaSDK.room().release();
        //摄像头停止采集
        cameraSession?.stop();
    }
}

extension RoomView {
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

extension RoomView: RoomListener {
    func onRoomListener(event: RoomState) {
        if case let RoomState.join(clientId: clientId, data: data) = event {
            print("clientId:\(clientId)  data:\(data)");
        } else if case let RoomState.joinAck(code: code, data: data) = event {
            if (code == 200){
                MediaSDK.room().producer(video: true)
                MediaSDK.room().consume(clientId: nil)
            }
        } else if case let RoomState.leave(clientId: clientId, code: code, data: data) = event {
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
        } else if case let RoomState.producer(clientId: clientId) = event {
            MediaSDK.room().consume(clientId: nil);
        } else if case let RoomState.producerAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let RoomState.consumeAck(code: code, data: data) = event {
            print("code:\(code)  data:\(data)");
        } else if case let RoomState.media(peer: peer, stream: stream) = event {
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

    func onJoin(clientId: String, data: String?) {

    }

    func onLeave(clientId: String, code: Int, data: String?) {
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
    }

    func onMedia(peer: Peer, stream: RTCMediaStream?) {
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

extension RoomView: OnClickListener {
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
        MediaSDK.room().leave();
        representation.dismiss();
    }

    func switchCameraListener() {
        peer?.switchCameraPosition()
    }

    func answerListener() {
        // MediaSDK.room().answer();
    }
}
