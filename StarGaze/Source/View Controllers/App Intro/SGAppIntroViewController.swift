//
//  SGAppIntroViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 11/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGAppIntroViewController: UIViewController {

    @IBOutlet weak var skipButton: SGButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: SGIntroPageControl!
    
    private let viewModels = [SGAppIntroViewModel(title: NSLocalizedString("INTRO_1_TITLE", comment: ""),
                                                  subTitle: NSLocalizedString("INTRO_1_SUB", comment: ""),
                                                  imageImage: "introArt1"),
                              SGAppIntroViewModel(title: NSLocalizedString("INTRO_2_TITLE", comment: ""),
                                                  subTitle: NSLocalizedString("INTRO_2_SUB", comment: ""),
                                                  imageImage: "introArt2"),
                              SGAppIntroViewModel(title: NSLocalizedString("INTRO_3_TITLE", comment: ""),
                                                  subTitle: NSLocalizedString("INTRO_3_SUB", comment: ""),
                                                  imageImage: "introArt3")]

    var router:SGOnboardRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: "SGAppIntroCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "Cell")
        pageControl.numberOfPages = viewModels.count
        pageControl.progress = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func triggerOnboarding(_ sender: Any) {
        router.route(to: SGOnboardRouter.Route.signin.rawValue,
                     from: self,
                     parameters: nil)
    }
    
    @IBAction func triggerSkip(_ sender: Any) {
        router.route(to: SGOnboardRouter.Route.signin.rawValue,
                     from: self,
                     parameters: nil)
    }
}

extension SGAppIntroViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SGAppIntroCollectionViewCell
        let viewModel = viewModels[indexPath.item]
        viewModel.setup(cell)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension SGAppIntroViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = scrollView.bounds.width * CGFloat(viewModels.count-1)
        let offset = scrollView.contentOffset.x
        let percent = Double(offset / total)
        let progress = percent * Double(viewModels.count - 1)
        
        debugPrint(progress)
        pageControl.progress = progress
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if pageControl.currentPage == viewModels.count - 1 {
            skipButton.isHidden = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false, pageControl.currentPage == viewModels.count - 1 {
            skipButton.isHidden = true
        }
    }
}
