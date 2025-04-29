//
//  SGFeedPreviewView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 07/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import YPImagePicker

struct SGFeedPreviewView: View {
    @ObservedObject var viewModel:SGCreateFeedViewModel
    @Binding var showAspectPicker: Bool
    @Binding var isPresented: Bool
    
    @State private var selectedTabId: String = ""
    @State private var pickedAttachment: SGCreateFeedAttachment? = nil
    @State private var showDeleteSheet: Bool = false
    
    @State private var tileSize: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
        
            if !viewModel.items.isEmpty {
                
                TabView(selection: $selectedTabId) {
                    ForEach (viewModel.items) { attachment in
                        self.cardView(for: attachment)
                            .tag(attachment.uuid)
                            .overlay {
                                cardOverlay(for: attachment)
                            }
                            .onAppear {
                                attachment.canPlay = true
                            }
                            .onDisappear {
                                attachment.canPlay = false
                            }
                    }
                    
                    
//                    ForEach (Array(viewModel.items.enumerated()),
//                             id:\.1.uuid) { (index, attachment) in
//                        self.cardView(for: attachment)
//                            .tag(index)
//                            .overlay {
//                                cardOverlay(index)
//                            }
//                            .onAppear {
//                                attachment.canPlay = true
//                            }
//                            .onDisappear {
//                                attachment.canPlay = false
//                            }
//                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .aspectRatio(viewModel.aspectRatio.ratio, contentMode: .fill)
                .readSize { size in
                    self.tileSize = size
                }
                .id(viewModel.items.count)
                .onDisappear {
                    viewModel.items.forEach { attachment in
                        attachment.canPlay = false
                    }
                }                
            }
            
            textWithHashtags(viewModel.desc,
                             color: Color.brand2)
            .foregroundColor(.text1)
            .fontWithLineHeight(font: SGFont(.installed(.GTWalsheimProRegular),
                                             size: .custom(18)).instance,
                                lineHeight: 24)
            .padding(.horizontal, 20)
        }
        .background(Color.brand1)
        .onAppear(perform: {
            self.selectedTabId = viewModel.items.first?.uuid ?? ""
        })
        .alert(isPresented: $showDeleteSheet) {
            let noButton = Alert.Button.default(Text("No"))
            let deleteButton = Alert.Button.destructive(Text("Yes")) {
                if let attachment = pickedAttachment {
                    
                    if let index = viewModel.items.firstIndex(of: attachment),
                       index == viewModel.items.count - 1,
                       index > 0 { //Removing the last item
                        withAnimation {
                            self.selectedTabId = viewModel.items[index - 1].uuid
                        }
                    }
                                           
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        viewModel.deleteAttachment(attachment)
                        self.pickedAttachment = nil
                    }
                    
//                    if pickedIndex > 0,
//                       pickedIndex == self.index,
//                        pickedIndex == viewModel.items.count - 1 { // If last item was deleted
//                        self.index = viewModel.items.count - 2
//                    }
                    
                }
                
                if viewModel.items.isEmpty {
                    withAnimation {
                        self.isPresented = false
                    }
                }
            }
            
            return Alert(title: Text("Confirm Delete?"),
                         message: Text("This action is not reversible"),
                         primaryButton: noButton,
                         secondaryButton: deleteButton)
        }
    }
    
    func textWithHashtags(_ text: String, color: Color) -> Text {
        let words = text.split(separator: " ")
        var output: Text = Text("")

        for word in words {
            if word.hasPrefix("#") { // Pick out hash in words
                output = output + Text(" ") + Text(String(word))
                    .foregroundColor(color) // Add custom styling here
            } else {
                output = output + Text(" ") + Text(String(word))
            }
        }
        return output
    }
    
    private func cardView(for attachment: SGCreateFeedAttachment) -> some View {
        switch attachment.item {
        case .photo(let p):
            return AnyView(
                Image(uiImage: p.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: tileSize.width,
                           height: tileSize.height)
                    .clipped()
            )
            
        case .video(_):
            return AnyView(
                AttachmentPlayerView(attachment: attachment)
                    .frame(width: tileSize.width,
                           height: tileSize.height)
                    .clipped()
            )
            
        case .none:
            return AnyView(EmptyView())
        }
    }
    
    private func cardOverlay(for attachment: SGCreateFeedAttachment) -> some View {
        VStack {
            HStack(spacing: 6) {
                Button {
                    withAnimation {
                        self.showAspectPicker = true
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image("crop")
                        
                        Text("Edit")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                    }
                    .padding(.horizontal, 13)
                    .frame(height: 29)
                    .background(
                        Color.black.opacity(0.6)
                            .cornerRadius(6)
                    )
                }
                
                Spacer()
                
                Button {
                    self.pickedAttachment = attachment
                    self.showDeleteSheet = true
                } label: {
                    Image("eRemove")
                        .resizable()
                        .tint(.white)
                        .frame(width: 9, height: 9)
                        .padding(10)
                        .background(
                            Color.black.opacity(0.6)
                                .cornerRadius(6)
                        )
                }
            }
            
            Spacer()
        }
//        .frame(width: tileSize.width,
//               height: tileSize.height)
        .padding(20)
//        .frame(maxWidth: .infinity,
//               maxHeight: .infinity)
        
        .opacity(showAspectPicker ? 0 : 1)
        
    }
}

struct SGFeedPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        SGFeedPreviewView(viewModel: SGCreateFeedViewModel(),
                          showAspectPicker: .constant(false),
                          isPresented: .constant(false))
            .preferredColorScheme(.dark)
    }
}
