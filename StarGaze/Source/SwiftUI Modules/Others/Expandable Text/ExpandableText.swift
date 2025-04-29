//
//  ExpandableText.swift
//  ExpandableText
//
//  Created by Suraj Shetty on 20/08/22.
//

import SwiftUI
import ActiveLabel
/*
 Ref:-
 https://github.com/NuPlay/ExpandableText/blob/main/Sources/ExpandableText/ExpandableText.swift
 */

struct ActiveLabelView: UIViewRepresentable {
    typealias UIViewType = ActiveLabel
    
    var text: String
    var textColor: Color = .black
    
    var elementColor: Color = .yellow
    var numberOfLines: Int = 4
    var font: UIFont = .systemFont(ofSize: 13)
    var lineSpacing: CGFloat = 0
    
    let elementTapHandler:((ActiveElement)->())
    
    init(text: String, clickHandler: @escaping ((ActiveElement)->())) {
        self.text = text
        self.elementTapHandler = clickHandler
    }
    
    func makeUIView(context: Context) -> ActiveLabel {
        let activeLabel = ActiveLabel()
        activeLabel.customize { label in
            label.text = text
            label.textColor = UIColor(textColor)
            label.enabledTypes = [.hashtag, .mention, .url]
            label.hashtagColor = UIColor(elementColor)
            label.mentionColor = UIColor(elementColor)
            label.URLColor = UIColor(elementColor)
            label.font = font
            label.lineSpacing = lineSpacing
            label.textColor = UIColor(textColor)
            label.numberOfLines = numberOfLines
            label.lineBreakMode = .byWordWrapping
        }
            
        activeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        activeLabel.handleURLTap { url in
            self.elementTapHandler(.url(original: url.absoluteString,
                                         trimmed: ""))
        }
        
        activeLabel.handleHashtagTap { hashtag in
            self.elementTapHandler(.hashtag(hashtag))
        }
        
        activeLabel.handleMentionTap { mention in
            self.elementTapHandler(.mention(mention))
        }
        
        return activeLabel
    }
    
    func updateUIView(_ uiView: ActiveLabel, context: Context) {
        uiView.customize { label in
            label.hashtagColor = UIColor(elementColor)
            label.mentionColor = UIColor(elementColor)
            label.URLColor = UIColor(elementColor)
            
            label.font = font
            label.text = text
            label.textColor = UIColor(textColor)
            
            label.numberOfLines = numberOfLines
            label.lineSpacing = lineSpacing
        }
    }
}

extension ActiveLabelView {
    func lineLimit(_ limit: Int?) -> ActiveLabelView {
        var label = self
        label.numberOfLines = (limit != nil) ? limit! : 0
        return label
    }
    
    func font(_ font: UIFont) -> ActiveLabelView {
        var label = self
        label.font = font
        return label
    }
    
    func foregroundColor(_ color: Color) -> ActiveLabelView {
        var label = self
        label.textColor = color
        return label
    }
    
    func elementColor(_ color: Color) -> ActiveLabelView {
        var label = self
        label.elementColor = color
        return label
    }
    
    func lineSpacing(_ spacing: CGFloat) -> ActiveLabelView {
        var label = self
        label.lineSpacing = spacing
        return label
    }
}


public struct ExpandableText: View {
    var text: String
    
    var font: Font = .largeTitle
    var lineLimit: Int = 3
    var foregroundColor: Color = Color(UIColor.black)
    var highlightColor: Color = Color(UIColor.yellow)
    var animation: Animation? = .none
    var lineSpacing: CGFloat = 0
    
    var expandButton: TextSet = .init(text: "more", font: .body, color: .red)
    
    @Binding var expand: Bool
    @State private var shouldTruncate : Bool = false
    @State private var fullHeight: CGFloat = 0
    
    @State private var labelHeight: CGFloat = .zero
    
    var elementTapHandler: ((ActiveElement)->())
    
    public init(text: String,
                expand: Binding<Bool>,
                clickHandle: @escaping ((ActiveElement)->())) {
        self.text = text
        self.elementTapHandler = clickHandle
        _expand = expand
    }
        
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                ActiveLabelView(text: text,
                                clickHandler: elementTapHandler)
                    .font(font.toUIFont())
                    .foregroundColor(foregroundColor)
                    .elementColor(highlightColor)
                    .lineLimit(0)
                    .lineSpacing(lineSpacing)
                    .frame(height: fullHeight) //Setting to full height, to avoid label jumping while expansion
            }
            .clipped()
            .frame(height: expand ? fullHeight : labelHeight, alignment: .topLeading)
            .mask({ //Add the expand/collape button
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.black)
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.black)
                        
                        if shouldTruncate { //Create a gradient view, which will be below the expand button
                            if !expand {
                                HStack(alignment: .bottom,
                                       spacing: 0) {
                                    LinearGradient(gradient: Gradient(stops: [
                                        Gradient.Stop(color: .black, location: 0),
                                        Gradient.Stop(color: .clear, location: 0.8)]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                    .frame(width: 40,
                                           height: expandButton.text.height(usingFont: expandButton.font.toUIFont()))
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: expandButton.text.width(usingFont: expandButton.font.toUIFont()),
                                               alignment: .center)
                                }
                            }
                            else { //Add collapse button here
                                
                            }
                        }
                    }
                    .frame(height: expandButton.text.height(usingFont: expandButton.font.toUIFont()))
                }
            }) //End of mask
            
            .animation(animation, value: expand)
            
            //Add the expand/collapse button if required
            if shouldTruncate {
                if !expand {
                    Button {
                        self.expand = true
                    } label: {
                        Text(expandButton.text)
                            .foregroundColor(expandButton.color)
                            .font(expandButton.font)
                    }
                }
            }
        }
        .background(
            ZStack { //This Zstack would be used to identify the full content height & whether trucation is necessary
                if !shouldTruncate, fullHeight != 0 {
                    Text(text) //This Text will determine whether truncation is necessary
                        .font(font)
                        .lineLimit(lineLimit)
                        .lineSpacing(lineSpacing)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear(perform: {
                                        if fullHeight > proxy.size.height {
                                            self.shouldTruncate = true
                                            self.labelHeight = proxy.size.height + 16
                                        }
                                        else {
                                            self.labelHeight = fullHeight
                                        }
                                    })
                            }
                        )
                }
                
                Text(text)  // This Text will calculate the full text content height
                    .font(font)
                    .lineSpacing(lineSpacing)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.fullHeight = proxy.size.height
                                }
                        }
                    )
            }
                .hidden()
        )
    }
}

struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ExpandableText(text: "Sed #hashtag ut perspiciatis, unde omnis iste natus error https://google.com sit voluptatem accusantium doloremque",
                           expand: .constant(false),
                           clickHandle: { _ in
                
            })
                .foregroundColor(Color.black)
                .font(.body)
                .lineLimit(3)
                .lineSpacing(6)
                .expandButton(TextSet(text: "see more", font: .body, color: .yellow))
                .expandAnimation(.easeInOut)
                .padding()
    //            .expandButton(TextSet(text: "more", font: .body, color: .blue))
            
            Spacer()
        }
    }
}
