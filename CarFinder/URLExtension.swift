//
//  URLExtension.swift
//  CarFinder
//
//  Created by Mauri on 10/5/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

extension URL {
    //Obtiene los items contenidos en una query
    func getQueryItemValueForKey(key: String) -> String? {
        guard let components = NSURLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        guard let queryItems = components.queryItems else { return nil }
        return queryItems.filter {
            $0.name.lowercased() == key.lowercased()
            }.first?.value
    }
}
