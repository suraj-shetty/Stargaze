//
//  SGCommentList.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import ToastUI
import Kingfisher

struct SGCommentListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel:SGCommentListViewModel
//    @ObservedObject var keyboardManager = KeyboardManager()
    
    @State private var didFirstAppear: Bool = false
    @State private var commentToReply:SGCommentViewModel?
    @State var commentText:String = ""
    @FocusState private var isFocussed:Bool
        
    @State private var addSubscription: Bool = false
    
    var body: some View {
        VStack {
            navView()
                        
            VStack(spacing: 0) {
                if viewModel.didEnd, viewModel.comments.isEmpty {
                    emptyListPlaceholder()
                        .onTapGesture {
                            isFocussed = false
                        }
                }
                else {
                    listView()
                }
                
                if !viewModel.allowCommenting {
                    subscribeView()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                    
                commentView()
                    .disabled(!viewModel.allowCommenting)
                    .opacity(viewModel.allowCommenting ? 1.0 : 0.1)
                    .padding(.horizontal, -20)
            }
            
            
            
//            if !viewModel.didEnd, viewModel.comments.isEmpty {
//
//                ZStack {
//                    emptyListPlaceholder()
//                        .onTapGesture {
//                            isFocussed = false
//                        }
//                    VStack {
//                        Spacer()
//                        commentView()
//                            .padding(.horizontal, -20)
////                            .padding(.bottom, keyboardManager.keyboardHeight)
////                            .edgesIgnoringSafeArea(keyboardManager.isVisible ? .bottom : [])
//                    }
//                }
//            }
//            else {
//                Group {
//                    listView()
//                    commentView()
//                }
//                .padding(.horizontal, -20)
//
////                    .padding(.bottom, keyboardManager.keyboardHeight)
////                    .edgesIgnoringSafeArea(keyboardManager.isVisible ? .bottom : [])
//            }
            
                
        }
        .padding(.horizontal, 20)
        .background(Color.brand1)
        
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
        .fullScreenCover(isPresented: $addSubscription) {
            SubscriptionListView(celeb: nil)
        }
    }
    
    private func emptyListPlaceholder() -> some View {
        VStack(alignment: .center, spacing: 30) {
            Spacer()
            
            Image("noComments")
//                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .center, spacing: 10) {
                Text("comment.list.empty.title".localizedKey)
                    .foregroundColor(.text1)
                    .font(.walsheimMedium(size: 22))
                
                Text("comment.list.empty.desc".localizedKey)
                    .foregroundColor(.text1.opacity(0.7))
                    .fontWithLineHeight(font: SGFont(.installed(.GTWalsheimProRegular),
                                                     size: .custom(16)).instance,
                                        lineHeight: 22)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 5)
    }
    
    
    private func navView() -> some View {
        VStack(spacing:9) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image("navBack")
                    
                }
                
                Spacer()
                
                HStack(spacing:10) {
                    Text("comment.list.title".localizedKey)
                        .font(Font.walsheimMedium(size: 18))
                        .foregroundColor(.text1)
                }
                Spacer()
            }
            .tint(.text1)
        }
        .frame(height:54)
        .background(Color.brand1)
    }
    
    private func listView() -> some View {
        
        ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.comments, id:\.commentID) { comment in
                        cell(for: comment)
                    } //End of comments for each loop
                    
                    if viewModel.didEnd == false, viewModel.comments.isEmpty == false {
                        Text("Fetching More…")
                            .foregroundColor(.text1)
                            .font(.walsheimRegular(size: 12))
                            .opacity(0.5)
                            .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .onAppear {
                                viewModel.getComments(refresh: false)
                            }
                    }
                }//End of List
                .listStyle(.plain)
//                .readFrame(space: .global,
//                           onChange: { rect in
//                    print("List size \(rect)")
//                })
//                .animation(.default, value: viewModel.comments)
                .onAppear {
                    UIScrollView.appearance().keyboardDismissMode = .onDrag
                }
//            .onReceive(viewModel.newCommentChange) { comment in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
//                    withAnimation {
//                        proxy.scrollTo(comment.commentID)
//                    }
//                })
//            }
        }//End of ScrollView Reader
        .frame(maxHeight:.infinity)
//        .background(content: {
//            Color.brand1
//        })
        .onAppear {
            
            if !didFirstAppear {
                didFirstAppear = true
                viewModel.getComments(refresh: true)
            }
        }
    }
    
    private func commentView() -> some View {
        ZStack {
            HStack(alignment: .center, spacing: 10, content: {
                
                KFImage(URL(string: SGAppSession.shared.user.value?.picture ?? ""))
                    .resizable()
                    .frame(width: 41, height: 41)
                    .aspectRatio(contentMode: .fill)
                    .background(Color(UIColor.placeholder))
                    .cornerRadius(20.5)
                
                Text(commentText)
                    .font(.walsheimRegular(size: 15)).opacity(0)
                    .frame(maxWidth: .infinity)
                    .lineLimit(4)
                    .overlay(
                        ZStack(alignment: .topLeading) {
                            Text("field.placeholder".localizedKey)
                                .foregroundColor(.text1.opacity(0.25))
                                .font(.walsheimRegular(size: 15))
                                .offset(x: -3, y: 0)
                                .padding(8)
                                .opacity(commentText.isEmpty ? 1 : 0)
                            
                            TextEditor(text: $commentText)
                                .font(.walsheimRegular(size: 15))
                                .foregroundColor(.text1)
                                .tint(.text1)
                                .focused($isFocussed)
                                .textFieldStyle(.plain)
                                .clearBackgroundStyle()
                                
                        }
                        
                    )
                 
                Button {
                    isFocussed = false
                    viewModel.postComment(comment: commentText,
                                          parentComment: commentToReply)
                } label: {
                    if viewModel.commentPosting {
                        ProgressView()
                            .tint(.brand2)                            
                    }
                    else {
                        Image("commentSend")
                            .frame(width: 15, height: 15)
                    }
                }
                .frame(width: 40, height: 40)
                .disabled(commentText.isEmpty)
            })
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(
                RoundedRectangle(cornerRadius: 28.5)
                    .stroke(Color.commentFieldBorder,
                            lineWidth: 1)
                    .background(Color.clear)
            )
        }
        .padding(20)
        .background(
            Color.brand1.opacity(0.8)
                .blur(radius: 10)
        )
        .overlay(
            RoundedCorner(radius: 10.0, corners: [.topLeft, .topRight])
            .stroke(Color.text1.opacity(0.1),
                    lineWidth: 1)
            .opacity(viewModel.allowCommenting ? 1 : 0)
        )
        .disabled(viewModel.commentPosting)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
            UITextView.appearance().tintColor = .text1
            UITextView.appearance().contentInset = .zero
            UITextView.appearance().scrollIndicatorInsets = .zero
        }
        .onReceive(viewModel.$didPost) { _ in
            self.commentText = ""
            self.commentToReply = nil
        }
        
    }
    
    private func subscribeView() -> some View {
        VStack(spacing: 20) {
            Divider()
                .foregroundColor(.tableSeparator)
                .frame(maxWidth: .infinity, maxHeight: 1)
                
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("comment.subscribe.title")
                        .foregroundColor(.text1)
                        .font(.system(size: 16,
                                      weight: .regular))
                        .frame(height: 21)
                    
                    Text("comment.subscribe.message")
                        .foregroundColor(.text1)
                        .font(.system(size: 16,
                                      weight: .regular))
                        .lineSpacing(5)
                        .opacity(0.6)
                        .frame(width: 248)
                        .multilineTextAlignment(.center)
                    
                    Button("comment.subscribe.button.title") {
                        withoutAnimation {
                            self.addSubscription = true
                        }
                    }
                    .buttonStyle(SGBorderedButtonStyle(inset: EdgeInsets(top: 9,
                                                                         leading: 20,
                                                                         bottom: 9,
                                                                         trailing: 20)))
                }
                
                Spacer()
            }
            
            
        }
    }
    
    private func cell(for viewModel:SGCommentViewModel) -> some View {
        SGCommentCellView(viewModel: viewModel) {
            self.commentToReply = viewModel
            self.isFocussed = true
        }
        .id(viewModel.commentID)
    }
    
//    private func commentSection(for viewModel:SGCommentViewModel) -> some View {
//        Group {
//            cell(for: viewModel)
//                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
//
//            if viewModel.replies.isEmpty == false, viewModel.viewReplies {
//
//                ForEach(viewModel.replies, id:\.commentID) { reply in
//                    cell(for: reply)
//                        .padding(EdgeInsets(top: 5, leading: 60, bottom: 5, trailing: 0))
//                }
//
//                Button {
//                    debugPrint("Before Toggle \(viewModel.viewReplies)")
//                    viewModel.toggleReplies()
//                    debugPrint("After Toggle \(viewModel.viewReplies)")
//                } label: {
//                    let formatText = viewModel.viewReplies
//                    ? NSLocalizedString("comment.replies.count.hide", comment: "")
//                    : NSLocalizedString("comment.replies.count.show", comment: "")
//
//                    let title = String.localizedStringWithFormat(formatText, viewModel.replies.count)
//
//                    Text(title)
//                        .font(.walsheimRegular(size: 15))
//                        .foregroundColor(.text1)
//                        .opacity(0.5)
//                }
//                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
//                .background(Color.brand1)
//                .listRowSeparator(.hidden)
//                .listRowBackground(Color.brand1)
//            }
//
//
////            if viewModel.replies.isEmpty == false {
////                if viewModel.viewReplies {
////
////                }
////
////
////            }
//        }
//    }
}

//struct SGCommentList_Previews: PreviewProvider {
//    static var previews: some View {
//        SGCommentListView(viewModel: SGCommentListViewModel(viewModel: SGFeedViewModel.preview))
//            .preferredColorScheme(.dark)
//    }
//}
