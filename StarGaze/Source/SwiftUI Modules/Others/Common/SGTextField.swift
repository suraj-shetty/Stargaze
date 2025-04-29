//
//  SGTextField.swift
//  StarGaze
//
//  Created by Sourabh Kumar on 04/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI

enum SGTextFieldType {
    case textField
    case date
    case time
}

struct SGTextField: View {
    private var title: String
    private var placeholder: String
    private var fieldType: SGTextFieldType
    private var keyboardType: UIKeyboardType
    
    private var borderColor: Color
    private var borderWidth: CGFloat
    
    @Binding private var value: String
    @Binding private var date: Date?
    
    init(title: String,
         placeHolder: String = "Type here",
         value:Binding<String> = .constant(""),
         date:Binding<Date?> = .constant(Date()),
         fieldType: SGTextFieldType = .textField,
         keyboardType: UIKeyboardType = .default,
         borderColor: Color = .text1.opacity(0.43),
         borderWidth: CGFloat = 2) {
        self.title = title
        self.placeholder = placeHolder
        self.fieldType = fieldType
        self._value = value
        self._date = date
        self.keyboardType = keyboardType
        
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    var body: some View {
        ZStack {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(borderColor)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                .padding(20)
            
            ZStack(alignment: .leading) {
                if fieldType != .textField {
                    SGDatePickerField(date: $date, fieldType: fieldType)
                } else {
                    if value.isEmpty {
                        Text(placeholder).foregroundColor(borderColor)
                            .font(.system(size: 19,
                                          weight: .medium))
                            .padding(.leading, 6)
                    }
                    TextField("", text: $value)
                        .font(.system(size: 19,
                                      weight: .medium))
                        .foregroundColor(.text1)
                        .keyboardType(keyboardType)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .frame(height: 64)
            .background(Color.brand1)
            .cornerRadius(10 - borderWidth, corners: [.topLeft, .topRight])
            .cornerRadius(24 - borderWidth, corners: [.bottomLeft, .bottomRight])
            .padding(20 + borderWidth)
            
            HStack {
                VStack {
                    Text(title)
                        .font(.system(size: 14,
                                      weight: .medium))
                        .foregroundColor(.brand2)
                        .padding(.horizontal, 8)
                        .background(Color.brand1)
                        .padding(.horizontal)
                        .padding(.leading)
                        .padding(.top, 16)
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(height: 68)
    }
}

struct SGTextEditor: View {
    var title: String
    var placeholder: String
    @Binding var value: String

    var borderColor: Color
    var borderWidth: CGFloat
    
    init(title: String,
         placeHolder: String = "Type here",
         value:Binding<String>,
         borderColor: Color = .text1.opacity(0.43),
         borderWidth: CGFloat = 2) {
        self.title = title
        self.placeholder = placeHolder
        self._value = value
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    var body: some View {
        ZStack {
            Text("")
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
                .background(borderColor)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                .padding(20)
            
            ZStack(alignment: .leading) {
                if value.isEmpty {
                    VStack {
                        Text(placeholder).foregroundColor(borderColor)
                            .font(.system(size: 19,
                                          weight: .medium))
                            .padding(.top)
                        Spacer()
                    }
                    .padding(.leading, 6)
                }
                TextEditor(text: $value)
                    .font(.system(size: 19,
                                  weight: .medium))
                    .foregroundColor(.text1)
                    .padding(.top, 8)
                    .padding(.leading, 1)
                    .clearBackgroundStyle()
                    .tint(.text1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .frame(height: 156)
            .background(Color.brand1)
            .cornerRadius(10 - borderWidth, corners: [.topLeft, .topRight])
            .cornerRadius(24 - borderWidth, corners: [.bottomLeft, .bottomRight])
            .padding(20 + borderWidth)
            
            HStack {
                VStack {
                    Text(title)
                        .font(.system(size: 14,
                                      weight: .medium))
                        .foregroundColor(.brand2)
                        .padding(.horizontal, 8)
                        .background(Color.brand1)
                        .padding(.horizontal)
                        .padding(.leading)
                        .padding(.top, 16)
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(height: 160)
    }
}

struct SGTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SGTextField(title: "Title", value: .constant(""))
            
            SGTextEditor(title: "Title", placeHolder: "Type Here", value: .constant(""))
        }
    }
}
