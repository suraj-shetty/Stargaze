//
//  ReportRowView.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 29/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

struct ReportRowView: View {
    @ObservedObject var viewModel: ReportRowViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(viewModel.type.title.localizedKey)
                    .foregroundColor(.text1)
                    .font(.system(size: 16,
                                  weight: .regular))
                
                Spacer()
                
                CheckBoxView(checked: $viewModel.checked)
            }
        }
        .onTapGesture {
            withAnimation {
                viewModel.checked.toggle()
            }
        }
        .frame(height: 74)
    }
}

struct ReportRowView_Previews: PreviewProvider {
    static var previews: some View {
        ReportRowView(viewModel: .preview)
    }
}

extension ReportRowViewModel {
    static var preview: ReportRowViewModel {
        return ReportRowViewModel(type: .abusive)
    }
}
