//
// Created by tyang on 2022/3/28.
//

import Foundation
import SwiftUI
import UIKit
import Combine

struct DoorViewRepresentation: UIViewControllerRepresentable {
    typealias UIViewControllerType = DoorView
    @Environment(\.presentationMode) var presentationMode
    let initiator: Bool;
    let clientId: String;

    init(initiator: Bool, clientId: String) {
        self.initiator = initiator;
        self.clientId = clientId;
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DoorViewRepresentation>) -> DoorViewRepresentation.UIViewControllerType {
        DoorView(representation: self, initiator: initiator, clientId: clientId)
    }

    func updateUIViewController(_ uiViewController: DoorViewRepresentation.UIViewControllerType, context: UIViewControllerRepresentableContext<DoorViewRepresentation>) {
        //
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss();
    }
}