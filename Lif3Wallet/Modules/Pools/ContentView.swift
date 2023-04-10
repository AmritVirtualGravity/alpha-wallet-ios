//
//  ContentView.swift
//  Pools
//
//  Created by Amrit Duwal on 3/28/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var favoriteColor = 0
    //    var poolList: PoolParent?
    @StateObject private var viewModel = ContentViewModel()
    @State var showAlert               = false
#warning("uncomment")
    //    let fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?
    //
    //    init(fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?) {
    //        UISegmentedControl.appearance().selectedSegmentTintColor = .white
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
    //        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    //        self.fungibleTokenDetailsViewModel = fungibleTokenDetailsViewModel
    //    }
    
    
    
    let fungibleTokenDetailsViewModel: String?
    
    init(fungibleTokenDetailsViewModel: String?) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        self.fungibleTokenDetailsViewModel = fungibleTokenDetailsViewModel
    }
    
    var body: some View {
        Color(darkerBlack)
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    if(viewModel.isBusy) {
                        ProgressView()
                            .onAppear {
                                viewModel.getPool(name: "ftm")
                            }
                    } else {
                        
                        let showAlert = Binding<Bool>(
                            get: { viewModel.showAlert ?? false },
                            set: { _ in viewModel.showAlert = viewModel.showAlert}
                        )
                        
                        //                  VStack(spacing: 20) {
                        //                      Text("Overlay").font(.largeTitle)
                        //                      Text("Example").font(.title).foregroundColor(.white)
                        //              }
                        ScrollView {
                            VStack {
                                //                                Spacer()
                                //                                    .frame(height: 40)
                                //                        VStack {
                                //                            Picker("What is your favorite color? ", selection: $favoriteColor) {
                                //                                Text("My Pools").tag(0)
                                //                                Text("Available Pools").tag(1)
                                //                                //                Text("Blue").tag(2)
                                //                            }
                                //                            .pickerStyle(.segmented)
                                //                            .cornerRadius(6, corners: .allCorners)
                                //                            .padding(.horizontal, 10)
                                //
                                //
                                //                        }
                                //            Text("Value: \(favoriteColor)")
                                //            List {
                                VStack {
                                    
                                    ForEach(viewModel.pools ?? [], id: \.self) { poolSection in
                                        //                                CompanyCell(amount: company.tvl ?? "", percentage: company.apr ?? "", title: company.name ?? "")
                                        companySection(title: poolSection.stakingList ?? "", company: poolSection.list ?? [], image: poolSection.imageURL ?? "", fungibleTokenDetailsViewModel: fungibleTokenDetailsViewModel)
                                    }
                                }
                            }
                        }
                        .alert(viewModel.error?.localizedDescription ?? "", isPresented: showAlert) {
                            Button("OK") {
                                // Handle acknowledgement.
                                viewModel.showAlert = false
                            }
                        }
                    }
                }
                    .navigationTitle("Lif3")
                    .navigationBarTitleDisplayMode(.inline)
            )
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
    let description: String
    let image: String
    var body: some View {
        HStack (alignment: .center, spacing: 8) {
            //            Image(getRandomImageName())
            //                .resizable()
            //                .frame(width: 30, height: 30)
            AsyncImage(
                url: image ,
                placeholder: { PlaceHolderImageView() },
                image: { Image(uiImage: $0).resizable() })
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            VStack(spacing: 0) {
                CustomText(name: title, padding: 0, font: mediumFont14)
                CustomText(name: description, textColor: lightDarkColor, alignment: .leading, padding: 0, font: regularFont12)
            }
            //                Spacer()
            HStack(spacing: 0) {
                CustomText(name: amount,alignment: .trailing ,padding: 0, font: mediumFont12)
                CustomText(name: percentage, alignment: .trailing, padding: 0, font: mediumFont12)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(.black)
        
    }
    
}

struct companySection: View {
    let title: String
    let company: [PoolCompany]
    let image: String
#warning("uncomment")
    //    let fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?
    let fungibleTokenDetailsViewModel: String?
    var body: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center, spacing: 8) {
                AsyncImage(
                    url: image ,
                    placeholder: { PlaceHolderImageView() },
                    image: { Image(uiImage: $0).resizable() })
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                CustomText(name: title, textColor: lightDarkColor, padding: 0, font: mediumFont14)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            HStack {
                CustomText(name: "Protocol", textColor: lightDarkColor, padding: 0, font: mediumFont14)
                HStack {
                    CustomText(name: "Type", textColor: lightDarkColor, alignment: .trailing, padding: 0 , font: mediumFont14)
                    Spacer()
                    CustomText(name: "Score", textColor: lightDarkColor, alignment: .trailing, padding: 0, font: mediumFont14)
                }
            }
            .background(Color(darkColor))
            .padding( 10)
            
            ForEach(company, id: \.self) { company in
                //                CompanyCell(amount: company.poolType ?? "", percentage: company.score ?? "", title: company.title ?? "", description: company.urlProtocol ?? "", image: company.bannerImage ?? "")
                NavigationLink {
#warning("uncomment")
                                        StakeView(poolCompany: company, fungibleTokenDetailsViewModel: fungibleTokenDetailsViewModel )
                } label: {
                    CompanyCell(amount: company.poolType ?? "", percentage: company.score ?? "", title: company.title ?? "", description: company.urlStake ?? "", image: company.bannerImage ?? "")
                }
            }
        }           .background(Color(darkColor))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            //            ContentView(poolList: PreviewData.load(name: "Pools", returnType: PoolParent.self))
            ContentView(fungibleTokenDetailsViewModel: nil)
        }
        
    }
}
