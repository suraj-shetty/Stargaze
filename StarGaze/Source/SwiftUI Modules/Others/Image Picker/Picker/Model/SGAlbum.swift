//
//  SGAlbum.swift
//  PhotoLibrary
//
//  Created by Suraj Shetty on 28/07/22.
//

import Foundation
import Photos

struct SGAlbum: Identifiable {
    var title: String = ""
    var itemCount: Int = 0
    var collection: PHAssetCollection?
    var id: String = UUID().uuidString
}

extension SGAlbum: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
