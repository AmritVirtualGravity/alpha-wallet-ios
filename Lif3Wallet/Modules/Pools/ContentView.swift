//
//  ContentView.swift
//  Pools
//
//  Created by Amrit Duwal on 3/28/23.
//

import SwiftUI
import SVGKit
import Kingfisher
import UIKit

struct ContentView: View {
    
    @State private var favoriteColor = 0
    
    @StateObject private var viewModel = ContentViewModel()
    @State var showAlert               = false
#warning("uncomment")
    
#if PRODUCTION
    var poolList: PoolParent?
    let fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?
    
    init(fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        self.fungibleTokenDetailsViewModel = fungibleTokenDetailsViewModel
    }
    
#else
    //            var poolList: PoolParent?
    let fungibleTokenDetailsViewModel: String?
#endif
    
    var body: some View {
        Color(darkerBlack)
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    if(viewModel.isBusy) {
                        ProgressView()
                            .onAppear {
                                
#if PRODUCTION
                                let contactAddress = "\(self.fungibleTokenDetailsViewModel?.token.primaryKey.lowercased() ?? "")".components(separatedBy: "-").first ?? ""
                                let nativeToken = "0x0000000000000000000000000000000000000000"
                                
                                let key = contactAddress == nativeToken ? "\(self.fungibleTokenDetailsViewModel?.token.symbol.lowercased() ?? "")".lowercased() : contactAddress
                                switch self.fungibleTokenDetailsViewModel?.token.server {
                                case .fantom:
                                    viewModel.getPool(name: "ftm/\(key)")
                                case .binance_smart_chain, .binance_smart_chain_testnet:
                                    viewModel.getPool(name: "bnb/\(key)")
                                default: break
                                }
#else
                                
                                let poolParent = PreviewData.load(name: "Pools", returnType:  PoolParent.self)
                                viewModel.pools = poolParent?.pools
                                viewModel.isBusy = false
                                //                                ContentView(poolList: PreviewData.load(name: "Pools", returnType: PoolParent.self))
#endif
                                
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
                                VStack(spacing: 0) {
                                    
                                    ForEach(viewModel.pools ?? [], id: \.self) { poolSection in
                                        //                                CompanyCell(amount: company.tvl ?? "", percentage: company.apr ?? "", title: company.name ?? "")
                                        Divider()
                                            .frame(height: 0.25)
                                            .background(Color(lighterDarkColor))
                                        
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
                    .navigationTitle(getTitle())
                    .navigationBarTitleDisplayMode(.inline)
            )
    }
    
    func getTitle() -> String {
#if PRODUCTION
        return "Stake \(fungibleTokenDetailsViewModel?.token.symbol ?? "")"
#else
        return fungibleTokenDetailsViewModel ?? "Title"
#endif
    }
}

//func getRandomImageName() -> String {
//    let arrayOfImageName = ["lif3_nursery", "lif3_lif3_trade", "lif3_leverage"]
//    return arrayOfImageName[Int.random(in: 0..<2)]
//}
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
            //            AsyncImage(
            //                url: image ,
            //                placeholder: { PlaceHolderImageView() },
            //                image: { Image(uiImage: $0).resizable() })
            
            //                SVGKFastImageViewSUI(url: .constant(url), size: .constant(CGSize(width: 30,height: 30)))
            //                setSvgImage(imageUrl: "")
            //            setSvgImage(imageUrl: image, width: 30, height: 30)
            //                .frame(width: 30, height: 30)
            //                .clipShape(Circle())
            SVGImageSwiftUIView(url:  image)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            //            SVGKFastImageViewSUI(url:URL(string:"https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg"))
            VStack(spacing: 0) {
                CustomText(name: title, padding: 0, font: mediumFont12)
                CustomText(name: description, textColor: lightDarkColor, alignment: .leading, padding: 0, font: regularFont10)
            }
            //                Spacer()
            HStack(spacing: 0) {
                CustomText(name: amount,alignment: .trailing ,padding: 0, font: mediumFont12)
                CustomText(name: percentage, alignment: .trailing, padding: 0, font: mediumFont12)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        //        .background(.black)
        .background(Color(darkerBlack))
        
    }
    
}

struct companySection: View {
    let title: String
    let company: [PoolCompany]
    let image: String
#warning("uncomment")
    
#if PRODUCTION
    let fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?
#else
    let fungibleTokenDetailsViewModel: String?
#endif
    
    var body: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center, spacing: 8) {
                //                setSvgImage(imageUrl: image, width: 30, height: 30)
                //                    .frame(width: 30, height: 30)
                //                    .clipShape(Circle())
                SVGImageSwiftUIView(url:  image)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                CustomText(name: title, textColor: lightDarkColor, padding: 0, font: mediumFont12)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color(darkerSecondLastBlack))
            HStack {
                CustomText(name: "Protocol", textColor: lightDarkColor, padding: 0, font: mediumFont12)
                HStack {
                    CustomText(name: "Type", textColor: lightDarkColor, alignment: .trailing, padding: 0 , font: mediumFont12)
                    Spacer()
                    CustomText(name: "Score", textColor: lightDarkColor, alignment: .trailing, padding: 0, font: mediumFont12)
                }
            }
            .background(Color(darkColor))
            .padding( 10)
            .padding(.vertical, 3)
            
            ForEach(company, id: \.self) { company in
                //                CompanyCell(amount: company.poolType ?? "", percentage: company.score ?? "", title: company.title ?? "", description: company.urlProtocol ?? "", image: company.bannerImage ?? "")
                NavigationLink {
#warning("uncomment")
                    StakeView(poolCompany: company, fungibleTokenDetailsViewModel: fungibleTokenDetailsViewModel )
                } label: {
                    CompanyCell(amount: company.poolType ?? "", percentage: company.score ?? "", title: company.title ?? "", description: company.urlStake ?? "", image: company.icon ?? "")
                }
            }
        }.background(Color(darkColor))
        
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


struct SVGImageSwiftUIView: UIViewRepresentable {
    
    
    typealias UIViewType = Lif3SVGImage
    var url: String
    //    typealias UIViewType = BackAndForth
    //    @Binding var forthButtonPressed: Bool
    
    func makeUIView(context: Context) -> Lif3SVGImage {
        let view = Lif3SVGImage()
        //        view.forthText = "Submit Agreement"
        view.imageUrl = url
        // Do some configurations here if needed.
        return view
    }
    
    func updateUIView(_ uiView: Lif3SVGImage, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
        
    }
    
}
