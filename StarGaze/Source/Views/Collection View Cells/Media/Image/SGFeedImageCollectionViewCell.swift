//
//  SGFeedImageCollectionViewCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 21/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Kingfisher

class SGFeedImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    unowned var viewModel:SGMediaViewModel! {
        didSet {
            updateContent(with: viewModel)
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoad()
        imageView.image = nil
    }
    
    func loadImage(for url:URL) {
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        
        imageView.kf.indicatorType = .activity
        if let task = imageView.kf.setImage(with: url,
                                            placeholder: nil,
                                            options: [
                                                .processor(processor),
                                                .scaleFactor(UIScreen.main.scale),
                                                .transition(ImageTransition.fade(1)),
                                                .cacheOriginalImage
                                            ], completionHandler: { _ in
                                                SGImageTaskCaching.shared.removeTask(for: url)
                                            }) {
            SGImageTaskCaching.shared.addTask(task, for: url)
        }
    }
    
    func cancelImageLoad() {
        imageView.kf.cancelDownloadTask()
    }
    
    func updateContent(with viewModel:SGMediaViewModel) {
        if let url = viewModel.url {
            loadImage(for: url)
        }
    }
}
