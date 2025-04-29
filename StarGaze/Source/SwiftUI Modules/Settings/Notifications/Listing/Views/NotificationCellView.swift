//
//  NotificationCellView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 21/12/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import SwiftDate
//import Kingfisher

struct NotificationCellView: View {
    @ObservedObject var viewModel: NotificationViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Image("profilePlaceholder")
                    .frame(width: 62,
                           height: 62)
                    .clipShape(Capsule())
                
                Circle()
                    .fill(viewModel.isRead ? Color.veryLightPink : Color.gold)
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)
                    .padding(.trailing, 5)
            }
            .padding(.leading, 5)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.notification.message)
                    .font(.system(size: 16,
                                  weight: .regular))
                    .foregroundColor(.text1)
                    .opacity(viewModel.isRead ? 0.5 : 1.0)
                    .lineSpacing(6)
                
                Text(viewModel.notification
                    .createdDate
                    .toRelative(since: nil,
                                dateTimeStyle: .numeric,
                                unitsStyle: .abbreviated))
                .font(.system(size: 14,
                              weight: .medium))
                .foregroundColor(.text1)
                .opacity(0.5)
            }
        }
        .onTapGesture {
            if !viewModel.isRead {
                Task {
                    _ = await viewModel.markAsRead()
                }
            }
            
            viewModel.open()
        }
    }
}

struct NotificationCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            
            NotificationCellView(viewModel: .init(notification: AppNotification(id: 0, type: .feed, typeID: 12,
                                                                                title: "Hello",
                                                                                message: "Yeah, i won’t lose. Just wait and see dude, why only me?",
                                                                                createdDate: Date().addingTimeInterval(-60),
                                                                                didRead: true)))
            
            Spacer()
        }
    }
}
