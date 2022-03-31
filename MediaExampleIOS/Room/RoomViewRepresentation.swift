//
// Created by tyang on 2022/3/24.
//

import Foundation
import SwiftUI
import UIKit
import Combine


struct RoomViewRepresentation: UIViewControllerRepresentable {
    typealias UIViewControllerType = RoomView
    @Environment(\.presentationMode) var presentationMode
    let roomId: String;

    init(roomId: String) {
        self.roomId = roomId;
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<RoomViewRepresentation>) -> RoomViewRepresentation.UIViewControllerType {
        RoomView(representation: self, roomId: roomId)
    }

    func updateUIViewController(_ uiViewController: RoomViewRepresentation.UIViewControllerType, context: UIViewControllerRepresentableContext<RoomViewRepresentation>) {
        //
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss();
    }
}