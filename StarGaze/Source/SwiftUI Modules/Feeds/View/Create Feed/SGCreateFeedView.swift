//
//  SGCreateFeedView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 03/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Foundation
import ToastUI

struct SGCreateFeedView: View {
    @StateObject private var viewModel = SGCreateFeedViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPicker:Bool = false
    @State private var previewPost:Bool = false
    @State private var showAspectPicker: Bool = false
    @State private var lastAspectRatio: SGMediaAspectRatio = .square
    
    @FocusState private var isFocussed:Bool
    
    @StateObject var viewState = ViewState()
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        VStack {
            VStack(spacing:20) {
                navView()
                    .opacity(showAspectPicker ? 0 : 1)
               
                ZStack {
                    VStack {
                        if previewPost {
                            ScrollView {
                                SGFeedPreviewView(viewModel: viewModel,
                                                  showAspectPicker: $showAspectPicker,
                                                  isPresented: $previewPost)
                                .environmentObject(viewState)
                                .clipped()
                            }
                            .padding(.horizontal, -20)
                            
                            Spacer()
                            
                        }
                        else {
                            VStack {
                                textInputView()
                                toggleView(title: "create-feed.toggle.exclusive.title".localizedKey,
                                           value: $viewModel.isExclusive)
                                toggleView(title: "create-feed.toggle.comment.title".localizedKey,
                                           value: $viewModel.disableComment)
                            }
                            .frame(maxWidth:.infinity, maxHeight:.infinity)
                        }
                        
                        Spacer()
                        bottomControl()
                    }
                    .transition(.slide)
                    .animation(.easeOut, value: previewPost)
                    
                    VStack {
                        Spacer()
                        if showAspectPicker {
                            AspectRatioToolbar(options: [.square, .aspect3x2, .aspect2x3, .aspect4x3, .aspect4x5, .aspect16x9],
                                               current: $viewModel.aspectRatio) { shouldChange in
                                if shouldChange {
                                    self.lastAspectRatio = viewModel.aspectRatio
                                }
                                else { //Revert
                                    withAnimation {
                                        self.viewModel.aspectRatio = lastAspectRatio
                                    }
                                }
                                
                                withAnimation {
                                    self.showAspectPicker = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal, -20)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showAspectPicker)
                }
            }
            .padding(.horizontal, 20)
            .fullScreenCover(isPresented: $showPicker) {
                
                
//                let configuration = SGMediaPickerConfiguration()
//                configuration.allowEditing = false
//                configuration.selectionLimit = 10
//                configuration.types = [.images, .videos]
//                configuration.preselectedItems = viewModel.items.map({
//                    $0.item
//                })
//
//
//                SGMediaPicker(configuration: configuration,
//                                     isPresented: $showPicker) { pickedItems in
//
//                    let group = DispatchGroup()
//                    var attachments = [SGCreateFeedAttachment]()
//
//                    for item in pickedItems {
//                        group.enter()
//
//                        let attachment = SGCreateFeedAttachment(item: item) {
//                            group.leave()
//                        }
//                        attachments.append(attachment)
//                    }
//
//                    group.notify(queue: .main) {
//                        let filtered = attachments.filter({ $0.fileURL != nil })
//                        self.viewModel.items = filtered
//                    }
//
//                    if items.count == 1 {
//                        if let firstItem = items.first {
//                            switch firstItem {
//                            case .photo(let p):
//                                let size = p.image.size
//                                self.viewModel.aspectRatio = .ratio(Double(size.width/size.height))
//
//                            case .video(let video):
//                                let size = video.thumbnail.size
//                                self.viewModel.aspectRatio = .ratio(Double(size.width/size.height))
//                            }
//                        }
//                    }
//                    else {
//                        self.viewModel.aspectRatio = .square
//                    }
//                }
                
                
                SGImagePicker(pickedItem: viewModel.items.map({ $0.item })) { items in

                    let group = DispatchGroup()
                    var attachments = [SGCreateFeedAttachment]()

                    for item in items {
                        group.enter()
                        let attachment = SGCreateFeedAttachment(item: item) {
                            group.leave()
                        }
                        attachments.append(attachment)
                    }

                    group.notify(queue: .main) {
                        let filtered = attachments.filter({ $0.fileURL != nil })
                        self.viewModel.items = filtered
                    }

                    if items.count == 1 {
                        if let firstItem = items.first {
                            switch firstItem {
                            case .photo(let p):
                                let size = p.image.size
                                let aspectRatio: SGMediaAspectRatio = .ratio(Double(size.width/size.height))
                                
                                self.viewModel.aspectRatio = aspectRatio
                                self.lastAspectRatio = aspectRatio

                            case .video(let video):
                                let size = video.thumbnail.size
                                let aspectRatio: SGMediaAspectRatio = .ratio(Double(size.width/size.height))
                                
                                self.viewModel.aspectRatio = aspectRatio
                                self.lastAspectRatio = aspectRatio
                            }
                        }
                    }
                    else {
                        self.viewModel.aspectRatio = .aspect4x3
                        self.lastAspectRatio = .aspect4x3
                    }

                }
        }
            .onAppear(perform: {
                viewState.isVisible = true
                self.lastAspectRatio = viewModel.aspectRatio
            })
            .onDisappear(perform: {
                viewState.isVisible = false
            })
//        HUD
            .toast(isPresented: $viewModel.isLoading, content: {
                ToastView()
                    .toastViewStyle(.indeterminate)
            })
            .toastDimmedBackground(true)

            //Success message
            .toast(isPresented: $viewModel.didPost,
                   dismissAfter: 5.0,
                   onDismiss: {
                NotificationCenter.default.post(name: .feedPosted, object: nil) //
                self.viewState.isVisible = false
                self.dismiss()
            },
                   content: {
                VStack {
                    SGSuccessToastView(message: NSLocalizedString("create-feed.post.success.message", comment: ""))
                        .frame( maxHeight: 130)
                    Spacer()
                }
            })
            .toastDimmedBackground(false)
            
            //Error message
            .toast(isPresented: $viewModel.hasError,
                   dismissAfter: 5.0,
                   onDismiss: {
            },
                   content: {
                VStack {
                    SGErrorToastView(message: (self.viewModel.error ?? SGAPIError.invalidBody).localizedDescription)
                        .frame(maxHeight: 130)
                    Spacer()
                }
            })
            .toastDimmedBackground(false)
        }
        .background(Color.brand1)
        .disabled(viewModel.isLoading || viewModel.didPost)
    }
    
    private func navView() -> some View {
        VStack(spacing:9) {
            HStack {
                Button {
                    if self.previewPost {
                        previewPost = false
                    }
                    else {
                        viewState.isVisible = false
                        dismiss()
                    }
                } label: {
                    Image("navBack")
                }
                
                Spacer()
                
                HStack(spacing:10) {
                    Image("createPost")
                    Text("create-feed.title".localizedKey)
                    .font(Font.walsheimRegular(size: 18))
                    .foregroundColor(.text1)
                }
                Spacer()
            }
            
            Text("create-feed.sub".localizedKey)
                .opacity(0.7)
                .font(Font.walsheimRegular(size: 15))
                .foregroundColor(.text1)

        }
        .tint(.text1)
        .frame(height:54)
    }
    
    private func textInputView() -> some View {
        
        ZStack(alignment: .topLeading) {
            Text("field.placeholder".localizedKey)
                .foregroundColor(.text1.opacity(0.25))
                .fontWithLineHeight(font: SGFont(.installed(.GTWalsheimProRegular),
                                                  size: .custom(18)).instance,
                                    lineHeight: 24)
                .offset(x: 5, y: 8)
                .opacity(viewModel.desc.isEmpty ? 1 : 0)
            
            TextEditor(text: $viewModel.desc)
                .textFieldStyle(.plain)
                .focused($isFocussed)
                .foregroundColor(.text1)
                .keyboardType(.default)
                .tint(.text1)
                .fontWithLineHeight(font: SGFont(.installed(.GTWalsheimProRegular),
                                                 size: .custom(18)).instance,
                                    lineHeight: 24)
                .clearBackgroundStyle()
        }
        .frame(maxHeight:.infinity)
//        .onAppear {
//            UITextView.appearance().backgroundColor = .clear
//            UITextView.appearance().tintColor = .text1
//            UITextView.appearance().contentInset = .zero
//            UITextView.appearance().scrollIndicatorInsets = .zero
//        }
    }
    
    private func toggleView(title: LocalizedStringKey, value:Binding<Bool>) -> some View {
        VStack(spacing:20) {
            Toggle(isOn: value) {
                Text(title)
                    .foregroundColor(.text1)
                    .font(.walsheimMedium(size: 16))
            }
            .tint(Color.brand2)
            
            Divider()
                .background(Color.tableSeparator)
        }
    }
    
    private func bottomControl() -> some View {
        HStack(spacing:10) {
            
            if viewModel.items.isEmpty {
                attachmentButton()
                    .buttonStyle(SGBorderedButtonStyle(inset: .init(top: 12,
                                                                    leading: 13,
                                                                    bottom: 12,
                                                                    trailing: 12)))
            }
            else {
                attachmentButton()
                    .buttonStyle(SGAttachmentButtonStyle())
            }
            
            Button {
                self.isFocussed = false
            } label: {
                Image("link")
            }
            .hidden()

            Spacer()
            
            if previewPost || viewModel.items.isEmpty {
                Button("create-feed.button.post.title".localizedKey) {
                    self.isFocussed = false
                    self.viewModel.post()
                    self.viewState.isVisible = false
                    self.dismiss()
                }
                .buttonStyle(SGBorderedButtonStyle())
            }
            else {
                Button("create-feed.button.preview.title".localizedKey) {
                    self.isFocussed = false
                    
                    if viewModel.canPost() {
                        withAnimation {
                            self.previewPost = true
                        }
                    }
                }
                .buttonStyle(SGBorderedButtonStyle())
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .opacity(showAspectPicker ? 0 : 1)
    }
    
    private func attachmentButton() -> some View {
        Button {
            self.showPicker = true
            self.isFocussed = false
        } label: {
            HStack(alignment: .center, spacing: 11) {
                Image("attachment")
                    .renderingMode(.template)
                    .tint(.text1)
                    
                if !viewModel.items.isEmpty {
                    let formatText = NSLocalizedString("feed.attachments", comment: "")
                    let title = String.localizedStringWithFormat(formatText, viewModel.items.count)
                    Text(title)
                        .font(.walsheimRegular(size: 14))
                }
            }
        }
    }
}

private extension SGCreateFeedView {
    func sharePost() {
        let postDesc = viewModel.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if postDesc.isEmpty {
            
        }
        
        
    }
    
    private func pickerConfiguration() {
        
    }
}




struct SGCreateFeedView_Previews: PreviewProvider {
    static var previews: some View {
        SGCreateFeedView().preferredColorScheme(.dark)
    }
}
