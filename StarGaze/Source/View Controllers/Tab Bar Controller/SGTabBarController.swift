//
//  SGTabBarController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 16/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import SwiftUI

enum SGTabBarType: Int {
    case feeds = 0
    case celebrities = 1
    case events = 2
    case menu = 3
}

extension SGTabBarType {
    var title: String {
        get {
            switch self {
            case .feeds:
                return NSLocalizedString("TAB_TITLE_FEEDS", comment: "")
            case .celebrities:
                return NSLocalizedString("TAB_TITLE_STARS", comment: "")
            case .events:
                return NSLocalizedString("TAB_TITLE_EVENTS", comment: "")
            case .menu:
                return NSLocalizedString("TAB_TITLE_MENU", comment: "")
            }
        }
    }
    
    var iconTitle: String {
        get {
            switch self {
            case .feeds:
                return "feeds_tab"
            case .celebrities:
                return "stars_tab"
            case .events:
                return "events_tab"
            case .menu:
                return "menu_tab"
            }
        }
    }
    
    var highlightIconTitle: String {
        get {
            switch self {
            case .feeds:
                return "feeds_tab_selected"
            case .celebrities:
                return "stars_tab_selected"
            case .events:
                return "events_tab_selected"
            case .menu:
                return "menu_tab_selected"
            }
        }
    }
}


class SGTabBarController: UIViewController {

    @IBOutlet weak var tabView: UIStackView!
    @IBOutlet weak var contentView: SGRoundedView!
    
    lazy private var tabs:[SGTabItemView] = {
        var items = [SGTabItemView]()
        for _ in 0..<4{
            items.append(SGTabItemView.instance)
        }
        return items
    }()
    lazy private var tabModels: [SGTabBarItem] = {
        return [
            SGTabBarItem(title: TAB_TITLE_FEEDS, image: IMAGE_NAME_FEEDS_TAB, imageSelected: IMAGE_NAME_FEEDS_TAB_SELECTED, isSelected: false),
            SGTabBarItem(title: TAB_TITLE_STARS, image: IMAGE_NAME_STARS_TAB, imageSelected:IMAGE_NAME_STARS_TAB_SELECTED, isSelected: false),
            SGTabBarItem(title: TAB_TITLE_EVENTS, image: IMAGE_NAME_EVENT_TAB, imageSelected: IMAGE_NAME_EVENT_TAB_SELECTED, isSelected: false),
            SGTabBarItem(title: TAB_TITLE_MENU, image: IMAGE_NAME_MENU_TAB, imageSelected: IMAGE_NAME_MENU_TAB_SELECTED, isSelected: false)
        ]
    }()
    
    private var tabTypes:[SGTabBarType] = [.feeds, .celebrities, .events, .menu]
    
    private var viewControllers = [//UIHostingController(rootView: FeedsListView()),
//                                   UIHostingController(rootView: SGCelebrityListView()),
//                                   UIHostingController(rootView: EventView()),
                                   UIViewController()
    ]
    
    private var previousIndex = 0
    private var currentIndex = 0
    private var disposeBag = DisposeBag()
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentView.corners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        setupTabbar()
        add(viewControllers[currentIndex])
        registerNotifications()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let currentView = viewControllers[currentIndex].view
        currentView?.frame = contentView.bounds
    }
}

private extension SGTabBarController {
    func setupTabbar() {
        for(index, model) in tabModels.enumerated() {
            let tabItemView = tabs[index]
            model.isSelected = index == 0
            tabItemView.item = model
            tabView.addArrangedSubview(tabItemView)
            
            tabItemView.rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[weak self] _ in
                    self?.selectTab(view: tabItemView)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func selectTab(view:SGTabItemView) {
        currentIndex = tabs.firstIndex(where: { $0 === view}) ?? 0
        
        let pickedType = tabTypes[currentIndex]
        if pickedType == .menu {
            SideMenuViewModel.shared.showMenu.toggle()
            return
        }
        
        if (currentIndex != previousIndex){
            //load next
            tabs[previousIndex].isSelected = false
            view.isSelected = true
            loadRespectiveTabs()
            previousIndex = currentIndex
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .tabSwitched, object: pickedType)
        }
        
    }
}

extension SGTabBarController{
    func add(_ child : UIViewController){
        addChild(child)
        
        let frame = contentView.bounds
        child.view.frame = frame
        
        child.willMove(toParent: self)
        contentView.addSubview(child.view)
        contentView.sendSubviewToBack(child.view)
        child.didMove(toParent: self)
    }
    
    ///remove a vc previoously added from a child
    func remove(_ child: UIViewController){
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        child.didMove(toParent: nil)
    }
    
    func loadRespectiveTabs() {
        self.remove(viewControllers[previousIndex])
        self.add(viewControllers[currentIndex])
    }
}

private extension SGTabBarController {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuHideHandle(_:)),
                                               name: .menuDidHide,
                                               object: nil)
    }
    
    @objc func menuHideHandle(_ notification:Notification) {
        guard let menu = notification.object as? SideMenuType,
           menu == .home
        else {
            return
        }
        
        let pickedType = tabTypes[currentIndex]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .tabSwitched, object: pickedType)
        }
    }
}
