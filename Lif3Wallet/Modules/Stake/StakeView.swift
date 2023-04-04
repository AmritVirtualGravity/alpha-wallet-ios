//
//  StakeView.swift
//  Pools
//
//  Created by Amrit Duwal on 3/29/23.
//

import SwiftUI

struct StakeView: View {
    var body: some View {
        Color(darkerBlack)
            .ignoresSafeArea()
            .overlay(
                ScrollView {
                    VStack(spacing: 16) {
                        Image("stake")
                            .resizable()
                            .frame(height: 151)
                            .cornerRadius(10, corners: .allCorners)
                        CustomText(name: "About", padding: 0, font: mediumFont14)
                        StakeCell(title: "Lif3 Trade")
                        VStack(spacing: 16) {
                            StakeViewTitleDescription(title: "Staking Page:", description: "https://trade.lif3.com/earn")
                            StakeViewTitleDescription(title: "About Protocol:", description: "Lif3.com is a complete multi-chain DeFi Ecosystem.")
                            StakeViewTitleDescription(title: "About Staking Pool:", description: "By depositing LIF3 into this pool, you are earning  protocol fees from the Lif3 Trade platform and additional Lif3 rewards.")
                        }
                        PrimaryButton(text: "Begin Staking", clicked: {})
                            .frame(height: 44)
                    }
                    .padding(.horizontal, 16)
                }
                
                //
            )
    }
}




struct StakeCell: View {
    let title: String
    var body: some View {
        HStack (alignment: .center, spacing: 8) {
            Image(getRandomImageName())
                .resizable()
                .frame(width: 30, height: 30)
            VStack(spacing: 0) {
                CustomText(name: title, padding: 0, font: mediumFont14)
                CustomText(name: "https://lif3.com/", textColor: lightDarkColor, alignment: .leading, padding: 0, font: regularFont12, maxWidth: true)
            }
        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 10)
        //        .background(.black)
        
    }
    
}

struct StakeView_Previews: PreviewProvider {
    static var previews: some View {
        StakeView()
    }
}

struct StakeViewTitleDescription: View {
    let title: String
    let description: String
    var body: some View {
        VStack(spacing: 4) {
            CustomText(name: title, textColor: lighterDarkColor, padding: 0,font: mediumFont12)
            CustomText(name: description, textColor: lightDarkColor, alignment: .leading, padding: 0, font: regularFont12, maxWidth: true)
        }
    }
}
