import Foundation
import SwiftUI

struct TextTipsAlert: UIViewControllerRepresentable {
    let title: String
    let message: String

    let leftButtonTitle: String?
    let rightButtonTitle: String?

    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    func makeUIViewController(context: UIViewControllerRepresentableContext<TextTipsAlert>) -> some UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<TextTipsAlert>) {
        guard context.coordinator.alert == nil else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        context.coordinator.alert = alert

        if leftButtonTitle != nil {
            alert.addAction(UIAlertAction(title: leftButtonTitle, style: .default) { _ in
                alert.dismiss(animated: true) {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    leftButtonAction?()
                }
            })
        }

        if rightButtonTitle != nil {
            alert.addAction(UIAlertAction(title: rightButtonTitle, style: .default) { _ in
                alert.dismiss(animated: true) {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                    rightButtonAction?()
                }
            })
        }

        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }

    func makeCoordinator() -> TextTipsAlert.Coordinator {
        Coordinator(self)
    }


    class Coordinator: NSObject, UITextFieldDelegate {

        var alert: UIAlertController?
        var view: TextTipsAlert

        init(_ view: TextTipsAlert) {
            self.view = view
        }
    }
}