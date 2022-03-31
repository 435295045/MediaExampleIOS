import Foundation
import SwiftUI

struct TextFieldAlert: UIViewControllerRepresentable {
    @Binding var text: String
    let placeholder: String
    let isSecureTextEntry: Bool
    let title: String
    let message: String

    let leftButtonTitle: String?
    let rightButtonTitle: String?

    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlert>) -> some UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<TextFieldAlert>) {

        guard context.coordinator.alert == nil else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        context.coordinator.alert = alert

        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = isSecureTextEntry
        }

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
                if let textField = alert.textFields?.first, let text = textField.text {
                    self.text = text
                }
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

    func makeCoordinator() -> TextFieldAlert.Coordinator {
        Coordinator(self)
    }


    class Coordinator: NSObject, UITextFieldDelegate {

        var alert: UIAlertController?
        var view: TextFieldAlert

        init(_ view: TextFieldAlert) {
            self.view = view
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                view.text = text.replacingCharacters(in: range, with: string)
            } else {
                view.text = ""
            }
            return true
        }
    }
}