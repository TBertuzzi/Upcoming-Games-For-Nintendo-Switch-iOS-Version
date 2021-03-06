//
//  SearchContract.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 8/21/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation

protocol SearchProtocol {
    func setResults(games: [Game]?, error: Error?)
    var games: [Game]? {get}
}

class SearchPresenter {
    
    var view: SearchProtocol
    var interactor: GameListInteractor!
    var notificationScheduler: NotificationScheduler!
    
    init(_ view: SearchProtocol) {
        self.view = view
    }
    
    func search(query: String){
        let result = view.games?.filter {
            return $0.title.lowercased().range(of: query.lowercased()) != nil
        }
        view.setResults(games: result, error: nil)
    }
    
    func search(query: String, filterBy: FilterBy){
        switch filterBy {
        case .digitalOnly:
            let result = view.games?.filter {
                return $0.title.lowercased().range(of: query.lowercased()) != nil && !$0.physicalRelease
            }
            view.setResults(games: result, error: nil)
            return
        case .physicalOnly:
            let result = view.games?.filter {
                return $0.title.lowercased().range(of: query.lowercased()) != nil && $0.physicalRelease
            }
            view.setResults(games: result, error: nil)
            return
        default:
            return search(query:query)
            
        }
    }
    
    func saveFavorite(game: Game){
        interactor.saveFavorite(game.id)
        notificationScheduler.suscribeGameForNotifications(game: game, isFavorite: true)
    }
    
    func deleteFavorite(game: Game){
        interactor.deleteFavorite(game.id)
        notificationScheduler.suscribeGameForNotifications(game: game, isFavorite: false)
    }
    
    func isFavorite(id: String) -> Bool {
        return interactor.isFavorite(id)
    }
}
