//
//  CustomNavigationView.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/24/22.
//

import SwiftUI

struct CustomNavigationView: ToolbarContent {
    var NavigationTitle: String
    var clicked: (() -> Void)
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                HStack(spacing: 0) {
                    Image("back")
                        .renderingMode(.template)
                          .foregroundColor(Color(darkestGreyColor))
                        .onTapGesture(perform: clicked)
                    Spacer()
                    HStack(spacing: 14) {
                        //            TextField("",searchText)
                        Text(NavigationTitle)
                            .font(Font(mediumFont16))
                            .foregroundColor(Color(darkestGreyColor))
                        Spacer()
    //                    Image("search")
    //                        .frame(width: 14, height: 14, alignment: .center)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                Divider()
            }
       
        }
        
    }
}
