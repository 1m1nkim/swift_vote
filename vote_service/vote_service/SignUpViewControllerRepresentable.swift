import SwiftUI

struct SignUpViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SignUpView {
        return SignUpView()
    }

    func updateUIViewController(_ uiViewController: SignUpView, context: Context) {
        // Update the view controller if needed
    }
}
