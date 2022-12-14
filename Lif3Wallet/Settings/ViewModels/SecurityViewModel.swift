

import UIKit
import Combine
import AlphaWalletFoundation

class SecurityViewModel {
    private var config: Config
    private var rows: [SecurityViewModel.SecurityRow] = SecurityViewModel.SecurityRow.allCases

    var title: String = R.string.localizable.settingsSecurityTitle()
    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .never
    private let lock: Lock
    private let analytics: AnalyticsLogger
    
    init(config: Config, lock: Lock, analytics: AnalyticsLogger) {
        self.config = config
        self.lock = lock
        self.analytics = analytics
    }

    func numberOfRows() -> Int {
        return rows.count
    }

    func viewModel(for indexPath: IndexPath) -> SwitchTableViewCellViewModel {
        let row = rows[indexPath.row]
        return .init(titleText: row.title, icon: row.icon, value: lock.isPasscodeSet)
    }
    

    func row(for indexPath: IndexPath) -> SecurityViewModel.SecurityRow {
        return rows[indexPath.row]
    }
    
    func transform(input: SecurityViewModelInput) -> SecurityViewModelOutput {
        let askToSetPasscode = self.askToSetPasscodeOrDeleteExisted(trigger: input.appProtectionSelection)
        return .init(askToSetPasscode: askToSetPasscode)
    }
    
    
    
    private func askToSetPasscodeOrDeleteExisted(trigger: AnyPublisher<(indexPath: IndexPath, isOn: Bool), Never>) -> AnyPublisher<Void, Never> {
        return trigger.compactMap { event -> Bool? in
            return event.isOn
        }.compactMap { [lock, analytics] isOn -> Void? in
            analytics.setUser(property: Analytics.UserProperties.isAppPasscodeOrBiometricProtectionEnabled, value: isOn)
            if isOn {
                return ()
            } else {
                lock.deletePasscode()
                return nil
            }
        }.eraseToAnyPublisher()
    }
}

extension SecurityViewModel {
    enum SecurityRow: Int, CaseIterable {
        case passcode

        var title: String {
            switch self {
            case .passcode:
                return R.string.localizable.settingsPasscodeTitle()
           
            }
        }

        var icon: UIImage {
            switch self {
            case .passcode:
                return R.image.biometrics()!
           
            }
        }
    }
}

struct SecurityViewModelOutput {
    let askToSetPasscode: AnyPublisher<Void, Never>
}

struct SecurityViewModelInput {
    let willAppear: AnyPublisher<Void, Never>
    let appProtectionSelection: AnyPublisher<(indexPath: IndexPath, isOn: Bool), Never>
}
