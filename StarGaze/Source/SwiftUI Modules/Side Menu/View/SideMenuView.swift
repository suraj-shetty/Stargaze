//
//  SideMenuView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 09/06/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import SwiftUI
import Kingfisher
import Introspect

struct SideMenuView: View {
//    private var menu = [SideMenuItem]()
    
    @StateObject var viewModel = SideMenuViewModel.shared
    @StateObject var user = UserViewModel()
    
    @State var currentMenu: SideMenuType = .home
        
    @State private var showMenu = false
    @State private var takeSnapShot: Bool = false
    @State private var snapShot: UIImage?
        
    @State private var hideCenter = false
    @State private var logout = false
    
    @StateObject var homeViewModel = HomeViewModel()        
    
    var body: some View {
        ZStack {
            SideMenuListView(user: user,
                             selection: $currentMenu,
                             menuItems: [.home, .profile, .notifications, .earnings, .settings, .logout]
//                                user.isCelebrity
//                             ? [.home, .profile, .settings, .logout]
//                             : [.home, .profile, .earnings, .settings, .logout]
            )
            .padding(.leading, 110)
            
            ZStack {
                Group {
                    if let snapShot = snapShot {
                        Image(uiImage: snapShot)
                            .resizable()
                            .opacity(0.1)
                            .cornerRadius(showMenu ? 35.0 : 0.0)
                            .scaleEffect(showMenu ? 0.55 : 1.0)
                            .offset(x: showMenu
                                    ? calculateGap(for: 0.45)
                                    : 0,
                                    y: 0)

                        Image(uiImage: snapShot)
                            .resizable()
                            .opacity(0.2)
                            .cornerRadius(showMenu ? 35.0 : 0.0)
                            .scaleEffect(showMenu ? 0.68 : 1.0)
                            .offset(x: showMenu
                                    ? -20 + calculateGap(for: 0.32)
                                    : 0,
                                    y: 0)
                    }
                              
                    contentView(type: currentMenu)
                        .environmentObject(viewModel)
                        .background(Color.brand1)
                        .cornerRadius(showMenu ? 35.0 : 0.0)
                        .scaleEffect(showMenu ? 0.8 : 1.0)
                        .offset(x: showMenu
                                ? -40 + calculateGap(for: 0.2)
                                : 0,
                                y: 0)
                        .allowsHitTesting(!showMenu)
                }
            }
            .zIndex(1)
            .ignoresSafeArea()
            .background(
                Color.brand1
                    .allowsHitTesting(showMenu)
                    .onTapGesture {
                        self.viewModel.showMenu = false
                    }
            )
            .offset(x: showMenu
                    ? -(UIScreen.main.bounds.width - 110)
                    : 0,
                    y: 0)
            
        }
        .onAppear(perform: {
            user.fetchUpdates()
        })
        .background(
            Color.brand1
                .ignoresSafeArea()
        )
        .onReceive(viewModel.$showMenu, perform: { output in
            if output == true {
                NotificationCenter.default.post(name: .menuWillShow,
                                                object: nil)

                let topVC = ScreenshotSharerUtility.findTopMostViewController()
                let snapshot = topVC?.view.takeScreenshot(afterScreenUpdates: false)
                self.snapShot = snapshot
                
                self.viewModel.state = .animating
                withAnimation(.easeOut(duration: 0.25)) {
                    self.showMenu = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.viewModel.state = .shown
                }
            }
            else {
                viewModel.state = .animating
                withAnimation(.easeIn(duration: 0.25)) {
                    self.showMenu = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.snapShot = nil
                    self.hideCenter = false
                    self.viewModel.state = .hidden
                    
                    NotificationCenter.default.post(name: .menuDidHide, object: currentMenu)
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .logout), perform: { _ in
            self.appLogout()
        })
        .onReceive(NotificationCenter.default.publisher(for: .updateWallet), perform: { _ in
            user.fetchUpdates()
        })
        .onReceive(NotificationCenter.default.publisher(for: .redirectApp), perform: { output in
            if currentMenu != .home {
                self.currentMenu = .home
                //In case the menu changes to home, the HomeView doesn't get a chance to receive the notification. So re-firing the same notification to handle this
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let userInfo = output.userInfo
                    NotificationCenter.default
                        .post(name: .redirectApp,
                              object: nil,
                              userInfo: userInfo)
                }
            }
        })
        .onChange(of: currentMenu) { newValue in
            
            if newValue == .logout {
                self.logout = true
                return
            }
            else {
                self.viewModel.state = .animating
                self.viewModel.showMenu = false //Hide
            }
        }
        .alert(isPresented: $logout) {
            let noButton = Alert.Button.default(Text("No"))
            let logoutButton = Alert.Button.destructive(Text("Yes")) {
                appLogout()                
            }
            
            return Alert(title: Text("Confirm Logout?"),
                         message: Text("Are you sure you want to logout"),
                         primaryButton: noButton,
                         secondaryButton: logoutButton)
        }
    }
    //MARK: - 
    
    @ViewBuilder
    private func contentView(type: SideMenuType) -> some View {
        switch type {
        case .home:
            HomeView(viewModel: homeViewModel)
//                .ignoresSafeArea()

        case .profile:
            UserProfileView()
            
        case .notifications:
            NotificationListView()
            
        case .leaderboard:
            LeaderboardView()
            
        case .settings:
            SettingsView()
            
        case .earnings:
            EarningDashboardView()
            
        case .logout:
            EmptyView()
        }
    }
    
    //MARk :-
    func calculateGap(for scale: CGFloat) -> CGFloat {
        let widthDiff = scale * UIScreen.main.bounds.width
        return (widthDiff / 2.0)
    }
    
    //MARK: -
    func appLogout() {
        let session = SGAppSession.shared
        session.cleanup()
        
        let viewController = SGAppIntroViewController(nibName: "SGAppIntroViewController", bundle: nil)
        viewController.router = SGOnboardRouter()
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.isNavigationBarHidden = true
        
        if let scene = UIApplication.shared.connectedScenes.first,
           let window = (scene as? UIWindowScene)?.keyWindow {
            window.set(rootViewController: navController,
                       options: .init(direction: .toLeft,
                                      style: .easeOut)) { _ in
            }
        }
        
        SideMenuViewModel.shared.showMenu = false
        SideMenuViewModel.shared.state = .hidden
    }
}


private struct SideMenuListView: View {
    @ObservedObject var user: UserViewModel
    @Binding var selection: SideMenuType
    var menuItems: [SideMenuType]
    
    
    
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Color.clear
                    .frame(height: 33)
                
                HStack {
                    Spacer()
                    profileView()
                }
                
                Color.clear
                    .frame(minHeight: 10, maxHeight: 26)
                
                ForEach (menuItems,
                         id: \.self) { item in
                    menuCell(for: item)
                }
                //            }
                
                Color.clear
                    .frame(minHeight: 10)
                
                HStack {
                    Spacer()
                    
                    Text(Bundle.main.releaseVersionNumberPretty)
                        .font(.system(size: 17,
                                      weight: .regular))
                        .foregroundColor(.text2)
                        .opacity(0.6)
                }
                .padding(.trailing, 20)
            }
            .frame(minHeight: contentHeight)
        }
        .introspectScrollView { scrollView in
            let inset = scrollView.contentInset
            let frameHeight = scrollView.frame.height - inset.top - inset.bottom
            
            self.contentHeight = frameHeight
        }
    }
    
    private func menuCell(for type: SideMenuType) -> some View {
        HStack(alignment: .center,
               spacing: 20) {
            Text(type.title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.text1)
            
            Image(type.iconName)
                .resizable()
                .renderingMode(.template)
                .tint(.text1)
                .frame(width: 20, height: 20)
                .aspectRatio(contentMode: .fit)
        }
               .onTapGesture(perform: {
                   self.selection = type
               })
               .frame(maxWidth:.infinity,
                      minHeight: 48,
                      alignment: .trailing)
               .padding(.trailing, 20)
               .background(
                LinearGradient(colors: [.menuGradientLead, .menuGradientTrail],
                               startPoint: .leading,
                               endPoint: .trailing)
                .padding(.leading, 33)
                .opacity(type == self.selection ? 1 : 0)
               )
    }
    
    private func profileView() -> some View {
        return AnyView(
            VStack(alignment: .trailing,
                   spacing: 14) {
                       KFImage(user.profileURL)
                           .resizable()
                           .fade(duration: 0.25)
                           .scaleFactor(UIScreen.main.scale)
                           .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 68,
                                                                                 height: 68))
                           )
                           .cacheOriginalImage()
                           .aspectRatio(contentMode: .fill)
                           .frame(width: 68, height: 68)
                           .background(Color.text1.opacity(0.2))
                           .clipShape(Capsule())
                       
                       VStack(alignment: .trailing,
                              spacing: 4) {
                           Text(user.name)
                               .foregroundColor(.text1)
                               .font(.system(size: 18, weight: .medium))
                               .frame(height: 20)
                           
                           Text("")
                               .opacity(0.6)
                               .foregroundColor(.text2)
                               .font(.system(size: 16, weight: .regular))
                               .frame(height: 18)
                       }
                   }
                .padding(.trailing, 20)
        )
        
    }
}


extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        else {
            for view in self.view.subviews  {
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as! UIViewController
                        return viewController.topMostViewController()
                    }
                }
            }
            return self
        }
    }
}

class ScreenshotSharerUtility {
    static func findTopMostViewController() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController()
    }
    
    static func findTopMostWindow() -> UIWindow? {
        return UIApplication.shared.keyWindow?.rootViewController?.topMostViewController().view.window
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        return (UIApplication.shared
            .connectedScenes
            .first?
            .delegate as? SceneDelegate)?
            .window
    }
}
