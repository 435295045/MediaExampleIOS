import SwiftUI
import MediaRTC
import WebSocket

class ViewState: ObservableObject {
    @Published var showP2PViewList = false;
    @Published var showRoomViewList = false;
    @Published var stateCode = -1;
    @Published var client: String = "";
}

struct ContentView: View {
    @ObservedObject var viewState = ViewState();
    var client: String?;

    init() {
        JYSystemAuthorityModel.checkCamerAuthority(result: {
            granted in
        })

        JYSystemAuthorityModel.checkMicrophoneAuthority(result: {
            granted in
        })
        MediaSDK.addRegisterListener(registerListener: self)
        client = NSUserDefaultsUtils.string(key: "client");
        if client != nil {
            MediaSDK.register(client: client!)
        }
        MediaSDK.p2p().addListener(listener: self)
        MediaSDK.group().addListener(listener: self)
        MediaSDK.door().addListener(listener: self)
    }

    var body: some View {
        //需要NavigationView包裹
        NavigationView(content: {
            //页面设置为垂直布局
            VStack(alignment: .center, spacing: nil, content: {
                //P2P List View
                NavigationLink(destination: P2PViewList(), isActive: $viewState.showP2PViewList) {
                    EmptyView()
                }
                Text("\(viewState.stateCode)")
                Button("单呼（P2P）") {
                    viewState.showP2PViewList = true;
                }.padding()
                //房间模式
                NavigationLink(destination: RoomViewList(), isActive: $viewState.showRoomViewList) {
                    EmptyView()
                }
                Button("房间模式") {
                    viewState.showRoomViewList = true;
                }.padding()
            }).navigationBarTitle("MediaSDK", displayMode: .inline)
                    .onAppear {
                        if client == nil {
                            let alertHC = UIHostingController(rootView: TextFieldAlert(
                                    text: $viewState.client,
                                    placeholder: "",
                                    isSecureTextEntry: false,
                                    title: "输入账号",
                                    message: "请输入一个账号注册",
                                    leftButtonTitle: "取消",
                                    rightButtonTitle: "确定",
                                    leftButtonAction: nil,
                                    rightButtonAction: {
                                        NSUserDefaultsUtils.addString(key: "client", value: viewState.client)
                                        MediaSDK.register(client: viewState.client)
                                    }
                            ))
                            alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                        }
                    }
        })
    }
}

extension ContentView: RegisterListener, P2PListener, GroupListener, DoorListener {
    func onP2PListener(event: P2PState) {
        if case let P2PState.offer(clientId: clientId, data: data) = event {
            let alertHC = UIHostingController(rootView: P2PViewRepresentation(initiator: false, clientId: clientId))
            alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
        }
    }

    func onGroupListener(event: GroupState) {
        if case let GroupState.offer(clientId: clientId, data: data) = event {
            let alertHC = UIHostingController(rootView: GroupViewRepresentation(initiator: false, clientId: clientId))
            alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
        }
    }

    func onRegister(data: String) {
        let dict: [String: AnyObject]? = MessageUtils.jsonStringToAny(text: data);
        viewState.stateCode = dict!["code"] as! Int;
    }

    func onDoorListener(event: DoorState) {
        if case let DoorState.offer(clientId: clientId, data: data) = event {
            let alertHC = UIHostingController(rootView: DoorViewRepresentation(initiator: false, clientId: clientId))
            alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
