//
//  DarkModeOptionsView.swift
//  gyre_rider
//
//  Created by Amrit Duwal on 7/11/22.
//

import SwiftUI

enum DarkMode: String, CaseIterable {
    case on, off, system
    
    var string: String {
        return String(describing: self).lif3CapitalizeFirstLetter
    }
    var description: String? {
        switch self {
        case .system: return "We'll adjust your appearance based on your device's system settings."
        default: return nil
        }
    }
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .on:      return UIUserInterfaceStyle.dark
        case .off:     return UIUserInterfaceStyle.light
        case .system:  return UIUserInterfaceStyle.unspecified
        }
    }
    
    var selectedImage: Image {
        return Image("dottedCircle")
    }
    
    var unselectedImage: Image {
        return Image("emptyCircle")
    }
}

struct DarkModeOptionsView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    //    var previousMode: DarkMode?
    @State var currentMode: UIUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
    
    var osTheme: UIUserInterfaceStyle {
        return UIScreen.main.traitCollection.userInterfaceStyle
    }
    @State var refresh = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(DarkMode.allCases , id: \.self) { mode in
                    VStack(alignment: .leading, spacing: 4) {
                        if (refresh == true) || (refresh == false) {
                            Button {
                                UIApplication.shared.customKeyWindow?.overrideUserInterfaceStyle = mode.userInterfaceStyle
                                currentMode = mode.userInterfaceStyle
                                GlobalConstants.KeyValues.darkMode = mode
                                refresh.toggle()
                            } label: {
                                HStack {
                                    VStack {
                                        Text(mode.string)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(Color(UIColor.appTextHighContrastColor))
                                        if let description = mode.description  {
                                            Text(description)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(Color(UIColor.appTextHighContrastColor))
                                                .font(Font(regularFont14))
                                        }
                                    }
                                    Spacer()
                                    returnIndicatorView(mode: mode)
                                }
                            }
                        }
                    }
                    Divider()
                }
            }
            .padding()
        }
        .background(Color(UIColor.lighterWhiteAndDarkerBlack))
        .navigationBarTitle("Dark Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
    
   private func returnIndicatorView(mode: DarkMode) -> Image {
        switch (GlobalConstants.KeyValues.darkMode, mode) {
        case (.on, .on):         return Image(systemName: "circle.circle.fill")
        case (.off, .off):       return Image(systemName: "circle.circle.fill")
        case (.system, .system): return Image(systemName: "circle.circle.fill")
        default:                 return Image(systemName: "circle")
            
        }
    }
}

struct DarkModeOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            DarkModeOptionsView()
        }
    }
}
