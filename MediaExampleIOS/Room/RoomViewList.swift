//
// Created by tyang on 2022/3/24.
//

import Foundation
import SwiftUI
import MediaRTC

struct RoomViewList: View {
    @State var roomId: String = "";
    @State var roomIds: [String]

    init() {
        roomIds = NSUserDefaultsUtils.stringArray(key: "roomIds") ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            Button(action: {
                let alertHC = UIHostingController(rootView: TextFieldAlert(
                        text: $roomId,
                        placeholder: "",
                        isSecureTextEntry: false,
                        title: "输入房间id",
                        message: "请输入一个房间id",
                        leftButtonTitle: "取消",
                        rightButtonTitle: "确定",
                        leftButtonAction: nil,
                        rightButtonAction: {
                            if roomId != "" {
                                for r in roomIds {
                                    if (r == roomId) {
                                        return;
                                    }
                                }
                                roomIds.append(roomId);
                                NSUserDefaultsUtils.addStringArray(key: "roomIds", value: roomIds)
                            }
                        }
                ))
                alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
            }) {
                Text("添加房间ID")
            }
                    .padding(.all, 8)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .padding(.all, 2)
                    .shadow(color: Color.green, radius: 2)
            List {
                ForEach(roomIds, id: \.self) { roomId in
                    RoomIdsView(roomId: roomId)
                }
            }.onTapGesture {
            }
        }).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
    }
}

struct RoomIdsView: View {
    var roomId: String

    var body: some View {
        HStack {
            Text(roomId)
                    .foregroundColor(.primary)
                    .font(.headline)

            Button(action: {
                let alertHC = UIHostingController(rootView: RoomViewRepresentation(roomId: roomId))
                alertHC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
            }) {
                Text("加入")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(BorderlessButtonStyle())
        }
    }
}