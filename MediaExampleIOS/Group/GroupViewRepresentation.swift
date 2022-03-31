import Foundation
import SwiftUI
import UIKit
import Combine

struct GroupViewRepresentation: UIViewControllerRepresentable {
    typealias UIViewControllerType = GroupView
    @Environment(\.presentationMode) var presentationMode
    let initiator: Bool;
    let clientId: String;

    init(initiator: Bool, clientId: String) {
        self.initiator = initiator;
        self.clientId = clientId;
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<GroupViewRepresentation>) -> GroupViewRepresentation.UIViewControllerType {
        GroupView(representation: self, initiator: initiator, clientId: clientId)
    }

    func updateUIViewController(_ uiViewController: GroupViewRepresentation.UIViewControllerType, context: UIViewControllerRepresentableContext<GroupViewRepresentation>) {
        //
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss();
    }
}