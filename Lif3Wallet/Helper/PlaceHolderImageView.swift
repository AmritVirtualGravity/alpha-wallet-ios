//
//  PlaceHolderImageView.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/22/22.
//

import SwiftUI

struct PlaceHolderImageView: View {
    var body: some View {
//        Text("Loading...")
//            .font(Font(regularFont12))
//            .foregroundColor(Color(darkerGreyColor))
        Image("logo")
            .resizable()
    }
}

struct PlaceHolderImage_Previews: PreviewProvider {
    static var previews: some View {
        PlaceHolderImageView()
    }
}
