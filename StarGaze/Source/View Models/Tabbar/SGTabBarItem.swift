//
//  SGTabBarItem.swift
//  stargaze
//
//  Created by Girish Rathod on 27/01/22.
//

class SGTabBarItem{
    var title: String
    var image: String
    var imageSelected: String
    var isSelected: Bool
    
    init(title: String, image: String, imageSelected: String, isSelected: Bool){
        self.title = title
        self.image = image
        self.imageSelected = imageSelected
        self.isSelected = isSelected
    }
}
