//
//  ContentView.swift
//  Pools
//
//  Created by Amrit Duwal on 3/28/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var favoriteColor = 0
    var poolList: CompanyList?
    
    init(poolList: CompanyList?) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        self.poolList = poolList
    }
    
    var body: some View {
        Color(darkColor)
        //            .ignoresSafeArea()
            .edgesIgnoringSafeArea(.top)
            .overlay(
                ScrollView {
                    VStack {
                        // MARK: segmented picker
                        //                        VStack {
                        //                            Picker("What is your favorite color? ", selection: $favoriteColor) {
                        //                                Text("My Pools").tag(0)
                        //                                Text("Available Pools").tag(1)
                        //                            }
                        //                            .pickerStyle(.segmented)
                        //                            .cornerRadius(6, corners: .allCorners)
                        //                            .padding(.horizontal, 10)
                        //                            .padding(.top, 10)
                        //                        }
                        //            Text("Value: \(favoriteColor)")
                        VStack {
                            companySection(title: "Lif3 Staking List", company: poolList?.lif3StakingList ?? [])
                            companySection(title: "Crypto Banter Suggesed Staking List", company: poolList?.crypoBannerSuggestedStakingList ?? [])
                            companySection(title: "Tech suggested staking list", company: poolList?.techSuggestedStakingList ?? [])
                        }
                    }
                }
                
            )
            .navigationTitle("Stake LIF3")
    }
    
}

func getRandomImageName() -> String {
    let arrayOfImageName = ["lif3_nursery", "lif3_lif3_trade", "lif3_leverage"]
    return arrayOfImageName[Int.random(in: 0..<2)]
}

struct CompanyCell: View {
    let amount: String
    let percentage: String
    let title: String
    var body: some View {
        HStack (alignment: .center, spacing: 8) {
            Image(getRandomImageName())
                .resizable()
                .frame(width: 30, height: 30)
            VStack(spacing: 0) {
                CustomText(name: title, padding: 0, font: mediumFont14)
                CustomText(name: "tradeLif3.com.com/quaidfy", textColor: lightDarkColor, alignment: .trailing, padding: 0, font: regularFont12)
            }
            //                Spacer()
            HStack(spacing: 0) {
                CustomText(name: amount,alignment: .trailing ,padding: 0, font: mediumFont12)
                CustomText(name: "\(percentage.replacingOccurrences(of: "%",with: ""))%", alignment: .trailing, padding: 0, font: mediumFont12)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(.black)
        
    }
    
}

struct companySection: View {
    let title: String
    let company: [Company]
    var body: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center, spacing: 8) {
                Image(getRandomImageName())
                    .resizable()
                    .frame(width: 30, height: 30)
                CustomText(name: title, textColor: lightDarkColor, padding: 0, font: mediumFont14)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            HStack {
                CustomText(name: "Protocol", textColor: lightDarkColor, padding: 0, font: mediumFont14)
                HStack {
                    CustomText(name: "TVL", textColor: lightDarkColor, alignment: .trailing, padding: 0 , font: mediumFont14)
                    Spacer()
                    CustomText(name: "APR", textColor: lightDarkColor, alignment: .trailing, padding: 0, font: mediumFont14)
                }
            }
            .background(Color(darkColor))
            .padding( 10)
            
            ForEach(company, id: \.self) { company in
                //                CompanyCell(amount: company.tvl ?? "", percentage: company.apr ?? "", title: company.name ?? "")
                NavigationLink {
                    StakeView()
                } label: {
                    CompanyCell(amount: company.tvl ?? "", percentage: company.apr ?? "", title: company.name ?? "")
                }
                
                //                Link(destination: StakeView()) {
                //                    CompanyCell(amount: company.tvl ?? "", percentage: company.apr ?? "", title: company.name ?? "")
                //                }
                
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(poolList: PreviewData.load(name: "PoolList"))
    }
    
}
