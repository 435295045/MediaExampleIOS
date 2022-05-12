//
// Created by tyang on 2021/7/15.
// Copyright (c) 2021 n0. All rights reserved.
//

import Foundation
import WebRTC

public class RTCRenderView: NSObject, RTCVideoViewDelegate {
    var streamId: String?
    var remoteVideoTrack: RTCVideoTrack?
    var renderView: RTCMTLVideoView!

    override init() {
        super.init()
        renderView = RTCMTLVideoView()
        renderView.contentMode = .center
        renderView.clipsToBounds = true
        renderView.backgroundColor = .gray
        renderView?.delegate = self
    }

    deinit {
        remoteVideoTrack = nil
    }

    func setRemoteVideoTrack(remoteVideoTrack: RTCVideoTrack?) {
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.add(renderView)
    }

    func calculationCGRect(size: Int, index: Int) {
        let x = getX(size: size, index: index)
        let y = getY(size: size, index: index)
        let width = getWidth(size: size)
        renderView.frame = CGRect(x: x, y: y, width: width, height: width)
        // calculationCGSize()
    }

    /*func calculationCGSize() {
        if videoCGSize != nil {
            let isLandScape = videoCGSize.width < videoCGSize.height
            var cgRect: CGRect!
            if (isLandScape) {
                let ratio = videoCGSize.height / videoCGSize.width
                let height = uiView.frame.width * ratio
                cgRect = CGRect(x: 0, y: 0, width: uiView.frame.width, height: height)
            } else {
                let ratio = videoCGSize.width / videoCGSize.height
                let width = uiView.frame.width * ratio
                cgRect = CGRect(x: 0, y: 0, width: width, height: uiView.frame.width)
            }
            renderView.frame = cgRect
        }
    }*/

    func getWidth(size: Int) -> CGFloat {
        if (size <= 4) {
            return ScreenSizeUtil.width() / 2;
        } else if (size <= 9) {
            return ScreenSizeUtil.width() / 3;
        }
        return ScreenSizeUtil.width() / 3;
    }

    func getX(size: Int, index: Int) -> CGFloat {
        if (size <= 4) {
            if (size == 3 && index == 2) {
                return ScreenSizeUtil.width() / 4;
            }
            return CGFloat(index % 2) * ScreenSizeUtil.width() / 2;
        } else if (size <= 9) {
            if (size == 5) {
                if (index == 3) {
                    return ScreenSizeUtil.width() / 6;
                }
                if (index == 4) {
                    return ScreenSizeUtil.width() / 2;
                }
            }

            if (size == 7 && index == 6) {
                return ScreenSizeUtil.width() / 3;
            }

            if (size == 8) {
                if (index == 6) {
                    return ScreenSizeUtil.width() / 6;
                }
                if (index == 7) {
                    return ScreenSizeUtil.width() / 2;
                }
            }
            return CGFloat(index % 3) * ScreenSizeUtil.width() / 3;
        }
        return 0;
    }

    func getY(size: Int, index: Int) -> CGFloat {
        if (size < 3) {
            return 0;
        } else if (size < 5) {
            if (index < 2) {
                return 0;
            } else {
                return ScreenSizeUtil.width() / 2;
            }
        } else if (size < 7) {
            if (index < 3) {
                return 0;
            } else {
                return ScreenSizeUtil.width() / 3;
            }
        } else if (size <= 9) {
            if (index < 3) {
                return 0;
            } else if (index < 6) {
                return ScreenSizeUtil.width() / 3;
            } else {
                return ScreenSizeUtil.width() / 3 * 2;
            }
        }
        return 0;
    }
}

extension RTCRenderView {
    public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
    }
}
