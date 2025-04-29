//
//  LibrarySelection.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 30/07/22.
//

import Foundation
import Photos

struct LibrarySelection: Identifiable {
//    let index: Int
    let id :String
    
    init(assetID: String) {
//        self.index = index
        self.id = assetID
    }
}

extension LibrarySelection: Equatable {
    static func == (lhs: LibrarySelection, rhs: LibrarySelection) -> Bool {
        return lhs.id == rhs.id
    }
}
