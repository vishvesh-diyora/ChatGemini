//
//  GeminiMultimodalChatApp.swift
//  GeminiMultimodalChat
//
//  Created by Anup D'Souza
//

import SwiftUI

@main
struct GeminiMultimodalChatApp: App {
    var body: some Scene {
        WindowGroup {
//            SplashView()
            MultimodalChatView()
        }
    }
}

struct SplashView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SplashVideoViewController
    
    func makeUIViewController(context: Context) -> SplashVideoViewController {
        let vc = SplashVideoViewController()
        // Do some configurations here if needed.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SplashVideoViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

class SplashVideoViewController: UIViewController {

    var splashimageview = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        splashimageview.frame = self.view.frame
        splashimageview.contentMode = .scaleAspectFit
        self.view.backgroundColor = .white
        self.view.addSubview(splashimageview)
        self.splashimageview.image = UIImage(named: "app-logo")
    }
}
