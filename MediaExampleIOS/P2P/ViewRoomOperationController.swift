import SwiftUI

protocol OnClickListener {
    func muteListener();

    func handFreeListener();

    func openCameraListener();

    func hangUpListener();

    func switchCameraListener();

    func answerListener();
}

class ViewRoomOperationController: UIView {
    var onClickListener: OnClickListener!
    var muteButton: UIButton!
    var handFreeButton: UIButton!
    var openCameraButton: UIButton!
    var hangUpButton: UIButton!
    var switchCameraButton: UIButton!
    var answerButton: UIButton!

    // 将需要添加的子控件在这里进行初始化
    init(onClickListener: OnClickListener, frame: CGRect) {
        self.onClickListener = onClickListener
        super.init(frame: frame)
        let buttonSize: CGFloat = bounds.height * 0.35

        muteButton = UIButton()
        muteButton.backgroundColor = UIColor.clear
        muteButton.setImage(UIImage(named: "webrtc_mute_default.png"), for: UIControl.State.normal)
        muteButton.setImage(UIImage(named: "webrtc_mute_default_click.png"), for: UIControl.State.highlighted)
        muteButton.setImage(UIImage(named: "webrtc_mute.png"), for: UIControl.State.selected)
        muteButton.addTarget(self, action: #selector(muteButtonTapped(_:)), for: .touchUpInside)
        muteButton.frame = CGRect(x: 10, y: 0, width: buttonSize, height: buttonSize)
        addSubview(muteButton)

        handFreeButton = UIButton()
        handFreeButton.backgroundColor = UIColor.clear
        handFreeButton.setImage(UIImage(named: "webrtc_hands_free_default.png"), for: UIControl.State.normal)
        handFreeButton.setImage(UIImage(named: "webrtc_hands_free_default_click.png"), for: UIControl.State.highlighted)
        handFreeButton.setImage(UIImage(named: "webrtc_hands_free.png"), for: UIControl.State.selected)
        handFreeButton.addTarget(self, action: #selector(handFreeTapped(_:)), for: .touchUpInside)
        handFreeButton.frame = CGRect(x: bounds.width / 2 - buttonSize / 2, y: 0, width: buttonSize, height: buttonSize)
        addSubview(handFreeButton)

        openCameraButton = UIButton()
        openCameraButton.backgroundColor = UIColor.clear
        openCameraButton.setImage(UIImage(named: "webrtc_open_camera_normal.png"), for: UIControl.State.normal)
        openCameraButton.setImage(UIImage(named: "webrtc_open_camera_press.png"), for: UIControl.State.highlighted)
        openCameraButton.setImage(UIImage(named: "webrtc_open_camera_press.png"), for: UIControl.State.selected)
        openCameraButton.addTarget(self, action: #selector(openCameraTapped(_:)), for: .touchUpInside)
        openCameraButton.frame = CGRect(x: bounds.width - buttonSize - 10, y: 0, width: buttonSize, height: buttonSize)
        addSubview(openCameraButton)

        switchCameraButton = UIButton()
        switchCameraButton.backgroundColor = UIColor.clear
        switchCameraButton.setImage(UIImage(named: "webrtc_switch_camera_normal.png"), for: UIControl.State.normal)
        switchCameraButton.setImage(UIImage(named: "webrtc_switch_camera_press.png"), for: UIControl.State.highlighted)
        switchCameraButton.addTarget(self, action: #selector(switchCameraTapped(_:)), for: .touchUpInside)
        switchCameraButton.frame = CGRect(x: bounds.width - buttonSize - 10, y: bounds.height - buttonSize - 10, width: buttonSize, height: buttonSize)
        addSubview(switchCameraButton)

        answerButton = UIButton()
        answerButton.isHidden = true;
        answerButton.backgroundColor = UIColor.clear
        answerButton.setImage(UIImage(named: "webrtc_answer.png"), for: UIControl.State.normal)
        answerButton.setImage(UIImage(named: "webrtc_answer_click.png"), for: UIControl.State.highlighted)
        answerButton.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
        answerButton.frame = CGRect(x: bounds.width / 2 - buttonSize * 1.5, y: bounds.height - buttonSize - 10, width: buttonSize, height: buttonSize)
        addSubview(answerButton)

        hangUpButton = UIButton()
        hangUpButton.backgroundColor = UIColor.clear
        hangUpButton.setImage(UIImage(named: "webrtc_cancel.png"), for: UIControl.State.normal)
        hangUpButton.setImage(UIImage(named: "webrtc_cancel_click.png"), for: UIControl.State.highlighted)
        hangUpButton.addTarget(self, action: #selector(hangUpTapped(_:)), for: .touchUpInside)
        hangUpButton.frame = CGRect(x: bounds.width / 2 - buttonSize / 2, y: bounds.height - buttonSize - 10, width: buttonSize, height: buttonSize)
        addSubview(hangUpButton)
    }

    func answerHidden(isHidden: Bool) {
        answerButton.isHidden = isHidden;
        let buttonSize: CGFloat = bounds.height * 0.35
        if (isHidden) {
            hangUpButton.frame = CGRect(x: bounds.width / 2 - buttonSize / 2, y: bounds.height - buttonSize - 10, width: buttonSize, height: buttonSize)
        } else {
            hangUpButton.frame = CGRect(x: bounds.width / 2 + buttonSize / 2, y: bounds.height - buttonSize - 10, width: buttonSize, height: buttonSize)
        }
    }

    @objc func muteButtonTapped(_ sender: UIButton) {
        onClickListener.muteListener()
    }

    @objc func handFreeTapped(_ sender: UIButton) {
        onClickListener.handFreeListener()
    }

    @objc func openCameraTapped(_ sender: UIButton) {
        onClickListener.openCameraListener()
    }

    @objc func hangUpTapped(_ sender: UIButton) {
        onClickListener.hangUpListener()
    }

    @objc func switchCameraTapped(_ sender: UIButton) {
        onClickListener.switchCameraListener()
    }

    @objc func answerTapped(_ sender: UIButton) {
        answerHidden(isHidden: true)
        onClickListener.answerListener()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
