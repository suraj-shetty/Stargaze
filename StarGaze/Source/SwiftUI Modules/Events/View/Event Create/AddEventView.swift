//
//  AddEventView.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import YPImagePicker

struct AddEventView: View {
    @StateObject var viewModel: AddEventViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FocusState private var isFocused:Bool
    @StateObject private var viewState = ViewState()
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                HStack {
                    Spacer()
                    
                    Text(viewModel.title)
                        .foregroundColor(.text1)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        self.viewState.isVisible = false
                        self.presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(.leading, 20)
                            .tint(.text1)
                    }
                    Spacer()
                }
            }
            .frame(height: 40)
            .background {
                Color.brand1.ignoresSafeArea(.all, edges: .top)
            }
                        
            ScrollView {
                VStack(spacing: 20) {
                    SGTextField(title: "Name", value: $viewModel.name)
                        .focused($isFocused)
                        .padding(.top, 16)
                    SGTextEditor(title: "Description", value: $viewModel.description)
                        .focused($isFocused)
                    HStack {
                        SGTextField(title: "Date", date: $viewModel.date, fieldType: .date)
                            .padding(.trailing, -16)
                            .focused($isFocused)
                        SGTextField(title: "Time", date: $viewModel.time, fieldType: .time)
                            .padding(.leading, -16)
                            .focused($isFocused)
                    }
                    
                    if viewModel.showWinnerFields {
                        HStack {
                            SGTextField(title: "#Winners", placeHolder: "-1-", value: $viewModel.winners, keyboardType: .numberPad)
                                .focused($isFocused)
                                .padding(.trailing, -16)
                            SGTextField(title: "#mins per Winner ", placeHolder: "-1-", value: $viewModel.minPerWinners, keyboardType: .numberPad)
                                .focused($isFocused)
                                .padding(.leading, -16)
                        }
                    }
                    
                    SGTextField(title: "#of Coins Required to Join ", value: $viewModel.coinsNumber, keyboardType: .numberPad)
                        .focused($isFocused)
                    
                    UploadButton(action: {
                        // Upload Image/Video Action
                        viewState.isVisible = false
                        viewModel.showImagePicker = true
                    }, viewModel: viewModel)
                    .environmentObject(viewState)
                    .clipped()
                    
                    
                    //                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Toggle("Turn off commenting", isOn: $viewModel.commentingOn)
                        .foregroundColor(.text1)
                        .font(.walsheimMedium(size: 16))
                        .padding(.horizontal, 20)
                        .tint(Color.brand2)
                    
                    Spacer()
                }
            }
            .background(Color.brand1)
            .cornerRadius(40, corners: [.bottomRight, .bottomLeft])
            
            Button {
                viewModel.uploadMediaAndCreateEvent()
            } label: {
                Text(viewModel.title.uppercased())
                    .font(.walsheimMedium(size: 15))
                    .foregroundColor(.brand1)
                    .padding(.vertical, 20)
            }
        }
        .background(Color.brand2)
        .navigationBarHidden(true)
        .onChange(of: viewModel.eventCreated) { newValue in
            if newValue {
                viewState.isVisible = false
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showImagePicker, onDismiss: {
            viewState.isVisible = true
        }) {
            SGImagePicker(pickedItem: viewModel.initialMediaItem, maxItems: 1) { items in
                if let item = items.first {
                    viewModel.mediaItem = SGCreateFeedAttachment(item: item, completion: {
                    })
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
        .onAppear {
            viewState.isVisible = true
        }
        .onDisappear {
            viewState.isVisible = false
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(viewModel: AddEventViewModel(.videoCall))
    }
}

fileprivate struct UploadButton: View {
    let action: () -> Void
    @ObservedObject var viewModel: AddEventViewModel
    
    var body: some View {
        ZStack {
            if let attachment = viewModel.mediaItem {
                ZStack {
                    cardView(for: attachment)
                        .frame(height: 180)
                        .cornerRadius(8)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(true)
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button {
                                viewModel.mediaItem = nil
                            } label: {
                                Image("navClose")
                                    .tint(.text1)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                    }
                    .zIndex(1)
//                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    HStack {
                        Text("Upload Picture/Video")
                            .font(.walsheimRegular(size: 20))
                            .foregroundColor(.text1)
                        
                        Image("upload_event", bundle: nil)
                            .tint(.text1)
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    action()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.borderGray,
                        style: StrokeStyle(lineWidth:2,
                                           lineCap: .round,
                                           dash:[5, 5]))
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func cardView(for attachment: SGCreateFeedAttachment) -> some View {
        switch attachment.item {
        case .photo(let p):
            Image(uiImage: p.image)
                .resizable()
                .scaledToFit()
            
        case .video(_):
            PlayerView(url: attachment.fileURL!, contentMode: .scaleAspectFit)
            //                .scaledToFit()
            
        case .none:
            EmptyView()
        }
    }
}
