//
//  EventTimelineCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 24/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct EventTimelineCell: View {
    let viewModel: EventTimelineViewModel
    
    var body: some View {
        HStack(alignment: .top,
               spacing: 0) {
            ZStack(alignment: .top) {
                if !viewModel.hasPrevious {
                    VStack(alignment: .center, spacing: 0) {
                        Text(viewModel.day)
                            .foregroundColor(.text2)
                            .font(.system(size: 24,
                                          weight: .light))
                            .frame(height: 16)
                        
                        Text(viewModel.month)
                            .foregroundColor(.lightMustard2)
                            .font(.system(size: 14,
                                          weight: .regular))
                            .frame(height: 16)
                        
                        if !viewModel.year.isEmpty {
                            Text(viewModel.year)
                                .foregroundColor(.text2)
                                .font(.system(size: 10,
                                              weight: .regular))
                                .frame(height: 12)
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color.brand1)
                    .padding(.top, 15)
                    
                }
            }
            .frame(width: 60)
            
            ZStack {
                VStack(alignment: .leading,
                       spacing: 4) {
                    HStack(alignment: .center,
                           spacing: 6) {
                        Text(viewModel.time)
                            .font(.system(size: 14,
                                          weight: .medium))
                            .foregroundColor(.text2)
                        
                        Text(viewModel.celebName)
                            .font(.system(size: 14,
                                          weight: .medium))
                            .foregroundColor(.celebBrand)
                        
                        Spacer()
                    }
                           .opacity(0.5)
                    
                    Text(viewModel.title)
                        .font(.system(size: 16,
                                      weight: .regular))
                        .foregroundColor(.text1)
                        .lineLimit(nil)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                }
                       .padding(.init(top: 12, leading: 15, bottom: 12, trailing: 6))
            }
            .background(
                Color.profileInfoBackground
                    .cornerRadius(11)
            )
        }
               .padding(.trailing, 20)
               .padding(.top, viewModel.hasPrevious ? 10 : 44)
               .padding(.top, viewModel.isFirst ? -44 : 0) //To cancel the previous top padding, in case its first row
               .background {
                   HStack {
                       ZStack {
//                           Color.brand1

                           Line(direction: .vertical)
                               .stroke(Color.white.opacity(0.5),
                                       style: StrokeStyle(lineWidth: 1,
                                                          dash: [4]))
                               .frame(width: 1)
                               .padding(.top, viewModel.isFirst ? 25 : 0)
                       }
                       .frame(width: 60)

                       Spacer()
                   }
               }
               

        
    }
}

struct EventTimelineCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            Spacer()
            EventTimelineCell(viewModel: .preview)
                .background {
                    Color.blue
                }
            EventTimelineCell(viewModel: .preview2)
                .background {
                    Color.red
                }
//                .background(Color.red)
            Spacer()
        }
        .background(Color.brand1.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

extension EventTimelineViewModel {
    static var preview: EventTimelineViewModel {
        return EventTimelineViewModel(id: 0,
                                     title: "Lorem ipsum dolor sit amet, consect etuer elit aenean commodo..",
                                     celebName: "Brad Pitt",
                                     day: "15",
                                     month: "MAR",
                                     year: "",
                                     time: "7:30am",
                                     isFirst: true,
                                     hasPrevious: false)
    }
    
    static var preview2: EventTimelineViewModel {
        return EventTimelineViewModel(id: 0,
                                     title: "Lorem ipsum dolor sit amet, consect etuer elit aenean commodo..",
                                     celebName: "Brad Pitt",
                                     day: "15",
                                     month: "MAR",
                                     year: "",
                                     time: "7:30am",
                                     isFirst: false,
                                     hasPrevious: false)
    }
}
