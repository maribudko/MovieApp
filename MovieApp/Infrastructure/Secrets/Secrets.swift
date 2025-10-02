//
//  Secrets.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Foundation

enum Secrets {
    static let tmdbApiKey: String = {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = dict["TMDB_API_KEY"] as? String,
            !key.isEmpty
        else {
            assertionFailure("TMDB_API_KEY missing. Create Secrets.plist from Secrets.plist.example and set the key.")
            return ""
        }
        return key
    }()
}
