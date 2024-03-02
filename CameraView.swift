import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    var viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        cvc.viewModel = viewModel
        return cvc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
