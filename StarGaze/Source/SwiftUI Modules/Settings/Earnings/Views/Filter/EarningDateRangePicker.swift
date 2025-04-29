//
//  EarningDateRangePicker.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 17/01/23.
//  Copyright © 2023 Day1Tech. All rights reserved.
//

import SwiftUI

struct EarningDateRangePicker: View {
    @State var option: EarningDateRangeType
    var onPicked: (EarningDateRangeType) -> ()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            List(EarningDateRangeType.allOptions, id: \.rawValue) { option in
                row(for: option)
            }
            .listStyle(.plain)
            
            SGRoundRectButton(title: "UPDATE") {
                onPicked(option)
            }
        }
        .background {
            Color.brand1.ignoresSafeArea()
        }
        //CheckBoxView
    }
    
    private func row(for option: EarningDateRangeType) -> some View {
        HStack {
            Text(option.title)
                .foregroundColor(.text1)
                .font(.system(size: 16, weight: .regular))
                
            Spacer()
            
            CheckBoxView(checked: .init(get: {
                self.option == option
            }, set: { isPicked in
                if isPicked {
                    self.option = option
                }
            }))
        }
        .frame(height: 24)
        .padding(.vertical, 25)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowBackground(Color.brand1)
        .listRowSeparator(.hidden,
                          edges: (option == EarningDateRangeType.allOptions.last) ? .all : .top)
        .listRowSeparatorTint(.profileSeperator)
        .onTapGesture {
            self.option = option
        }
    }
}

struct EarningDateRangePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            EarningDateRangePicker(option: .month) { _ in
                
            }
            Spacer()
        }
    }
}
