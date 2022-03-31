import Foundation
import SwiftUI
import MediaRTC

struct P2PViewList: View {
    @State var client: String = "";
    @State var clients: [String]

    init() {
        clients = NSUserDefaultsUtils.stringArray(key: "clients") ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            Button(action: {
                let alertHC = UIHostingController(rootView: TextFieldAlert(
                        text: $client,
                        placeholder: "",
                        isSecureTextEntry: false,
                        title: "输入账号",
                        message: "请输入一个账号注册",
                        leftButtonTitle: "取消",
                        rightButtonTitle: "确定",
                        leftButtonAction: nil,
                        rightButtonAction: {
                            if client != "" {
                                for c in clients {
                                    if (c == client) {
                                        return;
                                    }
                                }
                                clients.append(client);
                                NSUserDefaultsUtils.addStringArray(key: "clients", value: clients)
                            }
                        }
                ))
                alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
            }) {
                Text("添加对方账号")
            }
                    .padding(.all, 8)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .padding(.all, 2)
                    .shadow(color: Color.green, radius: 2)
            List {
                ForEach(clients, id: \.self) { client in
                    ClientsView(client: client)
                }
            }.onTapGesture {
            }
        }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
    }
}

struct ClientsView: View {
    var client: String

    var body: some View {
        HStack {
            Text(client)
                    .foregroundColor(.primary)
                    .font(.headline)

            Button(action: {
                let alertHC = UIHostingController(rootView: P2PViewRepresentation(initiator: true, clientId: client))
                alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
            }) {
                Text("呼叫")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(BorderlessButtonStyle())
        }
    }
}