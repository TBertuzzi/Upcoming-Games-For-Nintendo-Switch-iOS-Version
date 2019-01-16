//
//  SwinjectSetup+Storyboard.swift
//  Upcoming Games
//
//  Created by Eleazar Estrella on 7/18/17.
//  Copyright © 2017 Eleazar Estrella. All rights reserved.
//

import Foundation
import SwinjectStoryboard
import RealmSwift

extension SwinjectStoryboard {
    class func setup() {
        defaultContainer.register(Client.self) {
            _ in APIClient()
        }.inObjectScope(.container)
        
        defaultContainer.register(GameService.self) { r  in
            GameService(client: r.resolve(Client.self)!)
        }
        
        defaultContainer.register(Realm.self) { _  in
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config
            return try! Realm()
        }.inObjectScope(.transient)
        
        defaultContainer.register(GameLocalDataManager.self) { r  in
            GameLocalDataManager(realm: r.resolve(Realm.self)!)
        }
        
        defaultContainer.register(GameRemoteDataManager.self) { r  in
            GameRemoteDataManager(service: r.resolve(GameService.self)!)
        }
        
        defaultContainer.register(GameListInteractor.self) { _ in GameListInteractor() }
            .initCompleted { (r, c) in
                let gameListInteractor = c
                gameListInteractor.localDataManager = r.resolve(GameLocalDataManager.self)!
                gameListInteractor.remoteDataManager = r.resolve(GameRemoteDataManager.self)!
        }
        
        defaultContainer.storyboardInitCompleted(GamesViewController.self) { (r, c) in
            let presenter = GameListPresenter(c)
            let interactor = r.resolve(GameListInteractor.self)
            presenter.interactor = interactor
            c.presenter = presenter
        }
        
        defaultContainer.storyboardInitCompleted(SearchViewController.self) { (r,c) in
            let presenter = SearchPresenter(c)
            presenter.interactor = r.resolve(GameListInteractor.self)!
            c.presenter = presenter
        }
    }
}
