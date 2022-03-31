//
// Created by tyang on 2022/1/8.
//

import Foundation
import SwiftUI
import UIKit
import Combine

struct P2PViewRepresentation: UIViewControllerRepresentable {
    typealias UIViewControllerType = P2PView
    @Environment(\.presentationMode) var presentationMode
    let initiator: Bool;
    let clientId: String;

    init(initiator: Bool, clientId: String) {
        self.initiator = initiator;
        self.clientId = clientId;
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<P2PViewRepresentation>) -> P2PViewRepresentation.UIViewControllerType {
        P2PView(representation: self, initiator: initiator, clientId: clientId)
    }

    func updateUIViewController(_ uiViewController: P2PViewRepresentation.UIViewControllerType, context: UIViewControllerRepresentableContext<P2PViewRepresentation>) {
        //
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss();
    }
}