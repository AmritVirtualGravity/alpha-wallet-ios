//
//  CustomText.swift
//  Schedule
//
//  Created by Amrit Duwal on 11/29/22.
//

import SwiftUI

struct CustomText: View {
    var name: String = ""
    var textColor: UIColor? = .white
    var darkMode: Bool = false
    var alignment: Alignment = .leading
    var padding: CGFloat = 4
    var font: UIFont = UIFont.systemFont(ofSize: CGFloat(16))
    var maxWidth = true
    var body: some View {
        Text(name)
            .font(Font(font))
            .foregroundColor(getTextColor())
            .frame(alignment: alignment)
            .padding(padding)
            .if(maxWidth) { content in
                content.frame(maxWidth: .infinity, alignment: alignment)
            }
            
        //            .padding(.horizontal, 6)
        //            .padding(.vertical, 8)
        //            .background(Color(darkestGreyColor))
        //            .cornerRadius(4)
        //            .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
    }
    
    func getTextColor() -> Color {
        switch(darkMode, textColor == nil ) {
        case (false, true), (true, false) : return Color(darkestGreyColor)
        case (true, true) : return Color(lightGreyColor)
        case (false, false) : return Color(textColor ?? darkestGreyColor)
        }
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        CustomText()
    }
}

