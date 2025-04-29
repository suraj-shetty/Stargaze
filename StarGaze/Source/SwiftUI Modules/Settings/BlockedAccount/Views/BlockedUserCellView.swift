//
//  BlockedUserCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 08/11/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
struct BlockedUserCellView: View {
    @ObservedObject var user: BlockedUserViewModel
    var body: some View {
        HStack(alignment: .center,
               spacing: 12) {
            KFImage(user.picture)
                .resizable()
                .frame(width: 56, height: 56)
                .aspectRatio(contentMode: .fill)
                .clipShape(Capsule())
            
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(user.name)
                    .foregroundColor(.text1)
                    .font(.system(size: 18,
                                  weight: .regular))
                    
                if user.followersCount > 0 {
                    Text("followers.count".formattedString(value: Int(user.followersCount)))
                        .foregroundColor(.text2)
                        .font(.system(size: 15,
                                      weight: .regular))
                        .opacity(0.5)
                }
            }
                   .fixedSize(horizontal: false, vertical: false)
            
            Spacer()
            
            Button {
                user.confirmBlock.toggle()
            } label: {
                ZStack {
                    Color.brand2
                    
                    if user.loading {
                        ProgressView()
                            .tint(.darkText)
                    }
                    else {
                        Text("blocked-list.cta.title")
                            .foregroundColor(.darkText)
                            .font(.system(size: 13,
                                          weight: .medium))
                            .kerning(-0.08)
                    }
                }
                .frame(width: 83, height: 29)
                .cornerRadius(14.5)
            }
            .disabled(user.loading)
        }
               .alert("blocked-list.confirm.title",
                      isPresented: $user.confirmBlock) {
                   Button("alert.button.no.title", role: .cancel) {
                   }
                   
                   Button("alert.button.yes.title") {
                       self.user.block()
                   }
               }
    }
}

//struct BlockedUserCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockedUserCellView()
//    }
//}
