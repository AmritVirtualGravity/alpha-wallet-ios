// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import AlphaWalletFoundation
import Combine
import AlphaWalletCore

struct ImportMagicTokenCardRowViewModel: TokenCardRowViewModelProtocol {
    var tokenScriptHtml: String
    
    var hasTokenScriptHtml: Bool
    
    private var importMagicTokenViewControllerViewModel: ImportMagicTokenViewControllerViewModel
    private let assetDefinitionStore: AssetDefinitionStore
    
    init(importMagicTokenViewControllerViewModel: ImportMagicTokenViewControllerViewModel, assetDefinitionStore: AssetDefinitionStore) {
        self.importMagicTokenViewControllerViewModel = importMagicTokenViewControllerViewModel
        self.assetDefinitionStore = assetDefinitionStore
    }
    
    var tokenHolder: TokenHolder? {
        return importMagicTokenViewControllerViewModel.tokenHolder
    }
    
    var tokenCount: String {
        return importMagicTokenViewControllerViewModel.tokenCount
    }
    
    var city: String {
        return importMagicTokenViewControllerViewModel.city
    }
    
    var category: String {
        return importMagicTokenViewControllerViewModel.category
    }
    
    var teams: String {
        return importMagicTokenViewControllerViewModel.teams
    }
    
    var match: String {
        return importMagicTokenViewControllerViewModel.match
    }
    
    var venue: String {
        return importMagicTokenViewControllerViewModel.venue
    }
    
    var date: String {
        return importMagicTokenViewControllerViewModel.date
    }
    
    var numero: String {
        return importMagicTokenViewControllerViewModel.numero
    }
    
    var time: String {
        return importMagicTokenViewControllerViewModel.time
    }
    
    var onlyShowTitle: Bool {
        return importMagicTokenViewControllerViewModel.onlyShowTitle
    }
    
    var isMeetupContract: Bool {
        return importMagicTokenViewControllerViewModel.tokenHolder?.isSpawnableMeetupContract ?? false
    }
    
    func subscribeBuilding(withBlock block: @escaping (String) -> Void) {
        if let subscribable = importMagicTokenViewControllerViewModel.tokenHolder?.values.buildingSubscribableValue {
            subscribable.subscribe { value in
                value?.stringValue.flatMap { block($0) }
            }
        }
    }
    
    func subscribeStreetLocalityStateCountry(withBlock block: @escaping (String) -> Void) {
        func updateStreetLocalityStateCountry(street: String?, locality: String?, state: String?, country: String?) {
            let values = [street, locality, state, country].compactMap { $0 }
            let string = values.joined(separator: ", ")
            block(string)
        }
        if let subscribable = importMagicTokenViewControllerViewModel.tokenHolder?.values.streetSubscribableValue {
            subscribable.subscribe { value in
                guard let tokenHolder = self.importMagicTokenViewControllerViewModel.tokenHolder else { return }
                if let value = value?.stringValue {
                    updateStreetLocalityStateCountry(
                        street: value,
                        locality: tokenHolder.values.localitySubscribableStringValue,
                        state: tokenHolder.values.stateSubscribableStringValue,
                        country: tokenHolder.values.countryStringValue
                    )
                }
            }
        }
        if let subscribable = importMagicTokenViewControllerViewModel.tokenHolder?.values.stateSubscribableValue {
            subscribable.subscribe { value in
                guard let tokenHolder = self.importMagicTokenViewControllerViewModel.tokenHolder else { return }
                if let value = value?.stringValue {
                    updateStreetLocalityStateCountry(
                        street: tokenHolder.values.streetSubscribableStringValue,
                        locality: tokenHolder.values.localitySubscribableStringValue,
                        state: value,
                        country: tokenHolder.values.countryStringValue
                    )
                }
            }
        }
        if let subscribable = importMagicTokenViewControllerViewModel.tokenHolder?.values.localitySubscribableValue {
            subscribable.subscribe { value in
                guard let tokenHolder = self.importMagicTokenViewControllerViewModel.tokenHolder else { return }
                if let value = value?.stringValue {
                    updateStreetLocalityStateCountry(
                        street: tokenHolder.values.streetSubscribableStringValue,
                        locality: value,
                        state: tokenHolder.values.stateSubscribableStringValue,
                        country: tokenHolder.values.countryStringValue
                    )
                }
            }
        }
        if let country = importMagicTokenViewControllerViewModel.tokenHolder?.values.countryStringValue {
            guard let tokenHolder = self.importMagicTokenViewControllerViewModel.tokenHolder else { return }
            updateStreetLocalityStateCountry(
                street: tokenHolder.values.streetSubscribableStringValue,
                locality: tokenHolder.values.localitySubscribableStringValue,
                state: tokenHolder.values.stateSubscribableStringValue,
                country: country
            )
        }
        func buildingPublisher() -> AnyPublisher<String, Never> {
            return (viewModel.tokenHolder?.values.buildingSubscribableValue?.publisher ?? .empty())
                .compactMap { $0?.stringValue }
                .eraseToAnyPublisher()
        }
        
        func streetLocalityStateCountryPublisher() -> AnyPublisher<String, Never> {
            let street = (viewModel.tokenHolder?.values.streetSubscribableValue?.publisher ?? .empty())
                .map { $0?.stringValue }
                .replaceEmpty(with: nil)
            
            let state = (viewModel.tokenHolder?.values.stateSubscribableValue?.publisher ?? .empty())
                .map { $0?.stringValue }
                .replaceEmpty(with: nil)
            
            let locality = (viewModel.tokenHolder?.values.localitySubscribableValue?.publisher ?? .empty())
                .map { $0?.stringValue }
                .replaceEmpty(with: nil)
            
            let country = Just(viewModel.tokenHolder?.values.countryStringValue)
            
            return Publishers.CombineLatest4(street, locality, state, country)
                .map { [$0, $1, $2, $3].compactMap { $0 }.joined(separator: ", ") }
                .eraseToAnyPublisher()
        }
        
        var tokenScriptHtml: String {
            guard let tokenHolder = importMagicTokenViewControllerViewModel.tokenHolder else { return "" }
            let xmlHandler = XMLHandler(contract: tokenHolder.contractAddress, tokenType: tokenHolder.tokenType, assetDefinitionStore: assetDefinitionStore)
            let (html: html, style: style) = xmlHandler.tokenViewIconifiedHtml
            
            return wrapWithHtmlViewport(html: html, style: style, forTokenHolder: tokenHolder)
        }
        
        var hasTokenScriptHtml: Bool {
            //TODO improve performance? Because it is generated again when used
            return !tokenScriptHtml.isEmpty
        }
    }
}
