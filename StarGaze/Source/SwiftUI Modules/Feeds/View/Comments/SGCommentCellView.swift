//
//  SGFeedsCommentsListView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 08/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import SwiftDate
import RxCocoa
import Kingfisher

struct SGCommentCellView: View {
    @ObservedObject var viewModel:SGCommentViewModel
    
    let onReply: (() -> Void)?
    
    @State private var showLike:Bool = false
    
    var body: some View {
        
        VStack(alignment:.leading) {
            HStack(alignment: .top,
                   spacing: 10) {
                
                KFImage(URL(string: viewModel.user.profilePath ?? ""))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .background(Color(uiColor: UIColor.placeholder))
                    .cornerRadius(25)

                
                VStack(alignment: .leading,
                       spacing: 5) {
                    Text(viewModel.user.displayName())
                        .font(.walsheimMedium(size: 17))
                        .kerning(-0.38)
                        .foregroundColor(.text1)
                    
                    Text(viewModel.comment)
                        .kerning(-0.36)
                        .foregroundColor(.comment)
                        .fontWithLineHeight(font: SGFont(.installed(.GTWalsheimProRegular),
                                                         size: .custom(16)).instance,
                                            lineHeight: 20)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    HStack(alignment: .center,
                           spacing: 10) {
                                                
                        
                        
                        Text(viewModel.createdDate?.toRelative(since: nil,
                                                               dateTimeStyle: .numeric,
                                                               unitsStyle: .short)
                             ?? "")
                            .font(.walsheimRegular(size: 15))
                            .foregroundColor(.text1)
                            .opacity(0.5)
                        
                        
                        if viewModel.showLike {
                            Group {
                                let formatText = NSLocalizedString("comment.like.count", comment: "")
                                let title = String.localizedStringWithFormat(formatText, viewModel.likeCount)
                                
                                Capsule()
                                    .frame(width: 3, height: 3)
                                    .foregroundColor(.text1)
                                    .opacity(0.3)
                                
                                Text(title)
                                    .font(.walsheimRegular(size: 15))
                                    .foregroundColor(.text1)
                                    .opacity(0.5)
                            }
                            .animation(.default, value: viewModel.showLike)
                        }
                        
                                            
                        if viewModel.canReply {
                            Capsule()
                                .frame(width: 3, height: 3)
                                .foregroundColor(.text1)
                                .opacity(0.3)
                            
                            Button {
                                self.onReply?()
                            } label: {
                                Text("Reply")
                                    .font(.walsheimRegular(size: 15))
                                    .foregroundColor(.text1)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .frame(height: 26) //To increase the button height
                }
                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        viewModel.toggleLike()
                    }
                } label: {
                    Image(viewModel.didLike ? "heartFill" : "heartHollow")
                        .resizable()
                        .frame(width: 20, height: 21)
                        .tint(.text1)
                }
            }
            
            
            if !viewModel.replies.isEmpty {
                if viewModel.viewReplies == false {
                    Button {
                        viewModel.toggleReplies()
                    } label: {
                        let formatText = NSLocalizedString("comment.replies.count.show", comment: "")
                        let title = String.localizedStringWithFormat(formatText, viewModel.replies.count)
                        
                        Text(title)
                            .font(.walsheimRegular(size: 15))
                            .foregroundColor(.brand2)
                            .opacity(0.85)
                    }
                    .padding(.leading, 60)
                }
                else {
                    Group {
                        ForEach(viewModel.replies, id:\.commentID) { reply in
                            SGCommentCellView(viewModel: reply, onReply: nil)
                                .padding(EdgeInsets(top: 5, leading: 60, bottom: 5, trailing: 0))
                        }
                        
                        Button {
                            viewModel.toggleReplies()
                        } label: {
                            let formatText = NSLocalizedString("comment.replies.count.hide", comment: "")
                            let title = String.localizedStringWithFormat(formatText, viewModel.replies.count)

                            Text(title)
                                .font(.walsheimRegular(size: 15))
                                .foregroundColor(.brand2)
                                .opacity(0.85)
                        }
                        .padding(.leading, 60)
                    }
                }
            }
        }
        .background(Color.brand1)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.brand1)
        .buttonStyle(.borderless) //To stop extending tappable area to entire cell
        .padding(.vertical, 5)
//        .onReceive(viewModel.showLike) { like in
//            self.showLike = like
//        }
    }
}

//struct SGFeedsCommentsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SGCommentCellView(viewModel: .preview, onReply: nil)
//            .frame(width: .infinity, height: 142)
//    }
//}
