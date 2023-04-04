//
//  Button.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/23/22.
//

import SwiftUI

struct PrimaryButton: View {
    var text: String
    var cornerRadius = CGFloat(10)
    var font: UIFont = mediumFont16
    var foregroundColor: UIColor = lightestDarkColor
    var backgroundColor: UIColor = blueColor
    var borderWidth: CGFloat?
    var maxHeight: CGFloat = 44
    var clicked: (() -> Void) /// use closure for callback
    
    var body: some View {
        Button(action: clicked) {
            Button(text, action: clicked)
                .frame(maxWidth: .infinity, maxHeight: maxHeight)
                .background(Color(backgroundColor)).cornerRadius(cornerRadius)
                .foregroundColor(Color(foregroundColor))
                .font(Font(font))
                .if(borderWidth != nil ) { content in
                    content.overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(darkestGreyColor), lineWidth: borderWidth!)
                    )
                }
        }
        
    }
}

struct SecondaryButton: View {
    var text: String
    var cornerRadius = CGFloat(20)
    var font: UIFont = mediumFont16
    var foregroundColor: UIColor = darkestGreyColor
    var backgroundColor: UIColor = .white
    var borderColor: UIColor = darkestGreyColor
    var clicked: (() -> Void) /// use closure for callback
    
    var body: some View {
        Button(text, action: clicked)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color(backgroundColor)).cornerRadius(cornerRadius)
            .foregroundColor(Color(foregroundColor))
            .font(Font(font))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(borderColor), lineWidth: 1)
            )
        
    }
}

struct PrimaryImageButton: View {
    let imageName: String
    var buttonName: String?        = nil
    var font                       = mediumFont18
    var imageWidth: CGFloat? = nil        //= 40
    var imageHeight: CGFloat? = nil      // = 20
    var wholeButtonHeight: CGFloat = 50
    var templateMode: Bool         = false
    var imageDirection: Alignment  = .leading
    var clicked: (() -> Void)? /// use closure for callback
    var dynamicHeight = true
    var noAlignment = false
    var body: some View {
        Button(action: clicked ?? {}) {
            HStack{
                if imageDirection == .trailing && noAlignment == false {
                    Spacer()
                }
                Image(imageName)
                    .renderingMode(templateMode ? .template : .original)
                    .resizable()
                    .foregroundColor(.white)
                //                .aspectRatio(contentMode: .fit)
                    .if(imageWidth != nil) { content in
                        content.frame(width: imageWidth, height: imageHeight)
                    }
                if let buttonName = buttonName {
                    Text(buttonName)  .font(Font(font))
                        .foregroundColor(Color(lightGreyColor))
                        .multilineTextAlignment(.leading)
                }
                if imageDirection == .leading && noAlignment == false {
                    Spacer()
                }
            }
            .padding()
            .cornerRadius(16)
            .frame(height: wholeButtonHeight)
        }
    }
}

struct PrimaryImageButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(text: "Test", clicked: {})
    }
}

