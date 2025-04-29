//
//  WebView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 22/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import WebKit
import SafariServices

struct WebView: View {
    var title: String
    var url: URL
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 9) {
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.text1)
                }
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("navClose")
                            .tint(.text1)
                            .frame(width: 49)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 44)
            .background(Color.brand1)
            
            WebContentView(url: url)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .background(Color.brand1
            .ignoresSafeArea())
    }
}


private struct WebContentView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

//private struct WebController: UIViewControllerRepresentable {
//    typealias UIViewControllerType = SFSafariViewController
//    
//    var url: URL
//    
//    func makeUIViewController(context: Context) -> SFSafariViewController {
//        let vc = SFSafariViewController(url: url)
//        return vc
////        vc.
//    }
//    
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
//        
//    }
//    
//}

struct WebViewPreview: PreviewProvider {
    static var previews: some View {
        WebView(title: "Sample link",
                url: URL(string: "https://www.apple.com")!)
    }
}
