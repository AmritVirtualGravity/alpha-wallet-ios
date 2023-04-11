//
//  StakeView.swift
//  Pools
//
//  Created by Amrit Duwal on 3/29/23.
//

import SwiftUI

#if PRODUCTION
import WalletCore
import AlphaWalletFoundation
#else

#endif

import SafariServices

struct StakeView: View {
    
    let poolCompany: PoolCompany
    
#if PRODUCTION
    let fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel?
#else
    let fungibleTokenDetailsViewModel: String?
#endif
    
    @State private var showSafari: Bool = false
    
    var body: some View {
        return Color(darkerBlack)
            .overlay(
                ScrollView {
                    VStack(spacing: 16) {
                        AsyncImage(
                            url: poolCompany.bannerImage ?? "" ,
                            placeholder: { PlaceHolderImageView() },
                            image: { Image(uiImage: $0).resizable() })
                        .frame(height: 151)
                        .cornerRadius(10, corners: .allCorners)
                        //                        .clipShape(Circle())
                        CustomText(name: "About", padding: 0, font: mediumFont14)
                        StakeCell(title: poolCompany.title ?? "", urlString: poolCompany.urlProtocol ?? "")
                        VStack(spacing: 16) {
                            StakeViewTitleDescription(title: "Staking Page:", description: poolCompany.urlStake ?? "")
                            StakeViewTitleDescription(title: "About Protocol:", description: poolCompany.aboutProtocol ?? "")
                            StakeViewTitleDescription(title: "About Staking Pool:", description: poolCompany.aboutStake ?? "")
                        }
                        //                        NavigationLink {
                        //                            if let fungibleTokenDetailsViewModel = fungibleTokenDetailsViewModel {
                        //                                //                                BrowserViewController(account: fungibleTokenDetailsViewModel.wallet, server: fungibleTokenDetailsViewModel.token.server)
                        //                                MyMasterViewController(fungibleTokenDetailsViewModel: fungibleTokenDetailsViewModel, poolCompany: poolCompany)
                        //                            } else {
                        //                                Spacer()
                        //                            }
                        //
                        //                        } label: {
                        PrimaryButton(text: "Begin Staking", clicked: {
                            //                                let config = SFSafariViewController.Configuration()
                            //                                config.entersReaderIfAvailable = true
                            //
                            //                                let url = URL(string: poolCompany.urlStake ?? "")
                            //                                let vc = SFSafariViewController(url: url, configuration: config)
                            //                                present(vc, animated: true)
                            //                            showSafari = true
                            NotificationCenter.default.post(name: .gotoBrowser, object: poolCompany.urlStake ?? "")
                            
                        })
                        .frame(height: 44)
                        //                                .overlay (
                        //                                    RoundedRectangle(cornerRadius: 0).allowsHitTesting(true).background(.clear)
                        //                                )
                        //                        }
                    }
                    .padding(.horizontal, 16)
                }
                    .navigationTitle(fungibleTokenDetailsViewModel?.token.symbol.lowercased().capitalizingFirstLetter() ?? "")
                    .navigationBarTitleDisplayMode(.inline)
            )
    }
}

struct StakeCell: View {
    let title: String
    let urlString: String
    var body: some View {
        HStack (alignment: .center, spacing: 8) {
            Image(getRandomImageName())
                .resizable()
                .frame(width: 30, height: 30)
            VStack(spacing: 0) {
                CustomText(name: title, padding: 0, font: mediumFont14)
                CustomText(name: urlString, textColor: lightDarkColor, alignment: .leading, padding: 0, font: regularFont12, maxWidth: true)
            }
        }
        //        .padding(.vertical, 10)
        //        .padding(.horizontal, 10)
        //        .background(.black)
    }
    
}

struct StakeView_Previews: PreviewProvider {
    static var previews: some View {
        let poolList: PoolParent = PreviewData.load(name: "Pools", returnType: PoolParent.self)!
        StakeView(poolCompany: poolList.pools?.first?.list?.first ?? PoolCompany(token: nil, title: nil, subtitle: nil, aboutProtocol: nil, aboutStake: nil, urlProtocol: nil, urlStake: nil, icon: nil, bannerImage: nil, poolType: nil, score: nil, isNative: nil, urlStaking: nil, image: nil), fungibleTokenDetailsViewModel: nil)
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

#if PRODUCTION
struct MyMasterViewController: UIViewControllerRepresentable {
    
    var fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel
    var poolCompany: PoolCompany
    typealias UIViewControllerType = BrowserHomeViewController
    
    func makeUIViewController(context: Context) -> BrowserHomeViewController {
        //        let storyboard = UIStoryboard(name: "Esewa", bundle: Bundle.main)
        let viewModel = BrowserHomeViewModel(bookmarksStore: BookmarksStore())
        let vc        = BrowserHomeViewController(viewModel: viewModel)
        //        discoverVC.didT
        //        discoverVC.delegate = self
        //        if let url = URL(string: poolCompany.urlStake ?? "") {
        //            discoverVC.goTo(url: url)
        //        }
        //        let loginViewController = storyboard.instantiateInitialViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: BrowserHomeViewController, context: Context) {
        
    }
    
}

//struct MyMasterViewController: UIViewControllerRepresentable {
//
//    var fungibleTokenDetailsViewModel: FungibleTokenDetailsViewModel
//    var poolCompany: PoolCompany
//    typealias UIViewControllerType = BrowserViewController
//
//    func makeUIViewController(context: Context) -> BrowserViewController {
//        //        let storyboard = UIStoryboard(name: "Esewa", bundle: Bundle.main)
//        let discoverVC = BrowserViewController(account: fungibleTokenDetailsViewModel.wallet, server: fungibleTokenDetailsViewModel.token.server)
//        if let url = URL(string: poolCompany.urlStake ?? "") {
//            discoverVC.goTo(url: url)
//        }
////        let loginViewController = storyboard.instantiateInitialViewController()
//        return discoverVC
//    }
//
//    func updateUIViewController(_ uiViewController: BrowserViewController, context: Context) {
//
//    }
//
//
//}

#else

#endif


struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}
