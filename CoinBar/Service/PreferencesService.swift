import Foundation

protocol PreferencesServiceProtocol {
    
    func getPreferences() -> Preferences
    
    func setFavouriteCoins(_ coins: [Coin])
    func addFavouriteCoin(_ coin: Coin)
    func removeFavouriteCoin(_ coin: Coin)
    
    func setCurrency(_ currency: Preferences.Currency)

    func setChangeInterval(_ changeInterval: Preferences.ChangeInterval)
}

final class PreferencesService: PreferencesServiceProtocol {
    
    private let persistence: PersistenceProtocol
    
    init(persistence: PersistenceProtocol) {
        self.persistence = persistence
    }
    
    // MARK: - Get Preferences
    
    func getPreferences() -> Preferences {
        return persistence.readPreferences()
    }
    
    // MARK: - Coins
    
    func setFavouriteCoins(_ coins: [Coin]) {
        persistence.writePreferences {
            var preferences: Preferences = $0
            preferences.favouriteCoins = coins.map { $0.id }
            return preferences
        }
        
        notify()
    }
    
    func addFavouriteCoin(_ coin: Coin) {
        persistence.writePreferences {
            var preferences: Preferences = $0
            guard !preferences.favouriteCoins.contains(coin.id) else {
                return preferences
            }
            preferences.favouriteCoins.append(coin.id)
            return preferences
        }
        
        notify()
    }
    
    func removeFavouriteCoin(_ coin: Coin) {
        persistence.writePreferences {
            var preferences: Preferences = $0
            if let index = preferences.favouriteCoins.index(of: coin.id) {
                preferences.favouriteCoins.remove(at: index)
            }
            return preferences
        }
        
        notify()
    }
    
    // MARK: - Currency
    
    func setCurrency(_ currency: Preferences.Currency) {
        persistence.writePreferences {
            var preferences: Preferences = $0
            preferences.currency = currency.rawValue
            return preferences
        }
        
        notify()
    }
    
    // MARK: - Change Interval
    
    func setChangeInterval(_ changeInterval: Preferences.ChangeInterval) {
        persistence.writePreferences {
            var preferences: Preferences = $0
            preferences.changeInterval = changeInterval.rawValue
            return preferences
        }
        
        notify()
    }
    
    // MARK: - Notifications
    
    private func notify() {
        NotificationCenter.default.post(name: ServiceObserver.preferencesUpdateNotificationName, object: nil)
    }
    
}
