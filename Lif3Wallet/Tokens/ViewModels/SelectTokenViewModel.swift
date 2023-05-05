//
//  SelectTokenViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 17.07.2020.
//

import UIKit
import Combine
import AlphaWalletFoundation

struct SelectTokenViewModelInput {
    let willAppear: AnyPublisher<Void, Never>
    let fetch: AnyPublisher<Void, Never>
}

struct SelectTokenViewModelOutput {
    let viewState: AnyPublisher<SelectTokenViewModel.ViewState, Never>
}

final class SelectTokenViewModel {
    private let filter: WalletFilter
    private let tokenCollection: TokenCollection
    private var cancelable = Set<AnyCancellable>()
    private var filteredTokens: [TokenViewModel] = []
    private let tokensFilter: TokensFilter
    private let whenFilterHasChanged: AnyPublisher<Void, Never>
    private let newTokenPublisher = CurrentValueSubject<[TokenViewModel],Never>([])
    private let swapOptionConfigurator: SwapOptionsConfigurator?
    private let selection: SwapTokens.TokenSelection

    var headerBackgroundColor: UIColor = Configuration.Color.Semantic.tableViewHeaderBackground
    var title: String = R.string.localizable.assetsSelectAssetTitle()

    init(tokenCollection: TokenCollection, tokensFilter: TokensFilter, filter: WalletFilter, swapOptionConfigurator: SwapOptionsConfigurator?, selection: SwapTokens.TokenSelection) {
        self.tokenCollection = tokenCollection
        self.tokensFilter = tokensFilter
        self.filter = filter
        self.swapOptionConfigurator = swapOptionConfigurator
        self.selection = selection

        switch filter {
        case .filter(let extendedFilter):
            whenFilterHasChanged = extendedFilter.objectWillChange
        case .all, .defi, .governance, .assets, .collectiblesOnly, .keyword:
            whenFilterHasChanged = Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
        }

        fetchTokensFromLiQuest()
        
    }
    
    func fetchTokensFromLiQuest() {
        guard let swapOptionConfigurator = swapOptionConfigurator else { return }
        guard let swapPairs = swapOptionConfigurator.tokenSwapper.swapPairs(for: swapOptionConfigurator.server) else { return }
        let tokens = swapPairs.getFromTokens()
        let newTokenViewModels = tokens.compactMap({ $0.getAppToken() }).map({ TokenViewModel(token: $0) })
        let wallet = self.tokenCollection as! WalletDataProcessingPipeline
        let sortedTokenViewModels = self.tokensFilter.sortDisplayedTokens(tokens: newTokenViewModels).map({ wallet.applyTicker(token: $0) }).map({ wallet.applyTokenScriptOverrides(token: $0) }).compactMap({ $0 })
        self.filteredTokens = sortedTokenViewModels
        self.newTokenPublisher.send(sortedTokenViewModels)
    }

    func selectTokenViewModel(at indexPath: IndexPath) -> Token? {
        let tokenViewModel = filteredTokens[indexPath.row]

        return tokenViewModel.getToken()
    }
    
    func filterTokens(tokenViewModels: [[TokenViewModel]]) -> [TokenViewModel] {
        if let swapOptionConfigurator = swapOptionConfigurator {
            var activeTokens = tokenViewModels.last!.filter({ $0.server == swapOptionConfigurator.server })
            let activeTokensAddresses = activeTokens.map({ $0.contractAddress })
            let fromTokens = tokenViewModels.first!.filter({  !activeTokensAddresses.contains($0.contractAddress) })
            activeTokens += fromTokens
            var filteredTokens = [TokenViewModel]()
            if (  UserDefaults.standard.bool(forKey: "HideToken") == true )  {
                filteredTokens = self.filterTokenWithZeroShortAmt(tokens: activeTokens)
            } else {
                filteredTokens = activeTokens
            }
            
            switch selection {
                case .from:
                    //remove the to token and zero balance tokens
                    filteredTokens.removeAll(where: { $0.contractAddress == swapOptionConfigurator.swapPair.to?.contractAddress })
                    filteredTokens.removeAll(where: { $0.balance.amountShort == "0" })
                case .to:
                    //remove the from token
                    filteredTokens.removeAll(where: { $0.contractAddress == swapOptionConfigurator.swapPair.from.contractAddress })
            }
            //remove the balance zero tokens if selecting from token
            return tokensFilter.sortDisplayedTokens(tokens: filteredTokens)
        } else {
            let tokens = tokenViewModels.flatMap({ $0 })
            var filteredTokens = [TokenViewModel]()
            if (  UserDefaults.standard.bool(forKey: "HideToken") == true )  {
                filteredTokens = self.filterTokenWithZeroShortAmt(tokens: tokens)
            } else {
                filteredTokens = tokens
            }
            let displayedTokens = tokensFilter.filterTokens(tokens: filteredTokens, filter: filter)
            return tokensFilter.sortDisplayedTokens(tokens: displayedTokens)
        }
    }

    func transform(input: SelectTokenViewModelInput) -> SelectTokenViewModelOutput {
        let _loadingState: CurrentValueSubject<LoadingState, Never> = .init(.idle)

        let whenAppearOrFetchOrFilterHasChanged = input.willAppear.merge(with: input.fetch, whenFilterHasChanged)
            .handleEvents(receiveOutput: { [_loadingState] in
                _loadingState.send(.beginLoading)
            }).flatMap { [tokenCollection] _ in tokenCollection.tokenViewModels.first() }

        let snapshot = newTokenPublisher.merge(with: whenAppearOrFetchOrFilterHasChanged)
            .collect(swapOptionConfigurator == nil ? 1 : 2)
            .map { tokens -> [TokenViewModel] in
                self.filterTokens(tokenViewModels: tokens)
            }.handleEvents(receiveOutput: { self.filteredTokens = $0 })
            .map { self.buildViewModels(for: $0) }
            .handleEvents(receiveOutput: { [_loadingState] _ in
                switch _loadingState.value {
                case .beginLoading:
                    _loadingState.send(.endLoading)
                case .endLoading, .idle:
                    break
                }
            }).removeDuplicates()
            .map { self.buildSnapshot(for: $0) }
            .eraseToAnyPublisher()

        let loadingState = _loadingState
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        let viewState = Publishers.CombineLatest(snapshot, loadingState)
            .map { SelectTokenViewModel.ViewState(snapshot: $0.0, loadingState: $0.1, title: self.title) }
            .eraseToAnyPublisher()

        return .init(viewState: viewState)
    }

    private func buildSnapshot(for viewModels: [SelectTokenViewModel.ViewModelType]) -> SelectTokenViewModel.Snapshot {
        var snapshot = NSDiffableDataSourceSnapshot<SelectTokenViewModel.Section, SelectTokenViewModel.ViewModelType>()
        snapshot.appendSections([.tokens])
        snapshot.appendItems(viewModels, toSection: .tokens)

        return snapshot
    }

    private func buildViewModels(for tokens: [TokenViewModel]) -> [SelectTokenViewModel.ViewModelType] {
        return tokens.map { token -> SelectTokenViewModel.ViewModelType in
            switch token.type {
            case .nativeCryptocurrency:
                let viewModel = EthTokenViewCellViewModel(token: token)
                return .nativeCryptocurrency(viewModel)
            case .erc20:
                let viewModel = FungibleTokenViewCellViewModel(token: token)
                return .fungible(viewModel)
            case .erc721, .erc721ForTickets, .erc875, .erc1155:
                let viewModel = NonFungibleTokenViewCellViewModel(token: token)
                return .nonFungible(viewModel)
            }
        }
    }
    
    func filterTokenWithZeroShortAmt(tokens: [TokenViewModel]) -> [TokenViewModel] {
          var filteredTokens = [TokenViewModel]()
          for token in tokens {
              if (token.type != .nativeCryptocurrency) {
                  if (token.balance.amountShort != "0") {
                      filteredTokens.append(token)
                  }
              } else {
                  filteredTokens.append(token)
              }
          }
          return filteredTokens
      }
}

extension SelectTokenViewModel {
    enum Section: Int, CaseIterable {
        case tokens
    }

    enum ViewModelType {
        case nativeCryptocurrency(EthTokenViewCellViewModel)
        case fungible(FungibleTokenViewCellViewModel)
        case nonFungible(NonFungibleTokenViewCellViewModel)
    }

    enum LoadingState {
        case idle
        case beginLoading
        case endLoading
    }
    typealias Snapshot = NSDiffableDataSourceSnapshot<SelectTokenViewModel.Section, SelectTokenViewModel.ViewModelType>

    struct ViewState {
        let snapshot: Snapshot
        let loadingState: LoadingState
        let title: String
    }
}

extension SelectTokenViewModel.ViewModelType: Hashable {
    static func == (lhs: SelectTokenViewModel.ViewModelType, rhs: SelectTokenViewModel.ViewModelType) -> Bool {
        switch (lhs, rhs) {
        case (.nonFungible(let vm1), .nonFungible(let vm2)):
            return vm1 == vm2
        case (.fungible(let vm1), .fungible(let vm2)):
            return vm1 == vm2
        case (.nativeCryptocurrency(let vm1), .nativeCryptocurrency(let vm2)):
            return vm1 == vm2
        default:
            return false
        }
    }
}

extension TokenViewModel {
    
    func getToken() -> Token {
        Token(contract: contractAddress, server: server, name: name, symbol: symbol, decimals: decimals, shouldDisplay: true)
    }
    
}
