//
//  CustomDivider.swift
//  Schedule
//
//  Created by Amrit Duwal on 11/29/22.
//

import SwiftUI

struct CustomDivider: View {
    var height: CGFloat = 1
    var color: UIColor = darkestGreyColor
    var darkMode: Bool = false
    var dotted: Bool = false
    var body: some View {
        Divider()
            .foregroundColor(.white)
            .overlay(Color.white)
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: dotted ? 1 : 0, dash: [2]))
            )
            .frame(height: height)
            .foregroundColor(getColor())
            .background(dotted ? .clear : getColor())
    }
    
    func getColor() -> Color {
        switch(darkMode) {
        case false : return Color(color)
        case true  : return Color(lightestGreyColor)
        }
    }
}

struct Divider_Previews: PreviewProvider {
    static var previews: some View {
        CustomDivider()
    }
}
 
