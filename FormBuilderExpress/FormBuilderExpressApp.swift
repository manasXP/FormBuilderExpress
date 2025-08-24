//
//  FormBuilderExpressApp.swift
//  FormBuilderExpress
//
//  Created by Manas Pradhan on 07/07/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
#if DEBUG
      let providerFactory = AppCheckDebugProviderFactory()
      AppCheck.setAppCheckProviderFactory(providerFactory)
#endif
    return true
  }
}

@main
struct FormBuilderExpressApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var kycViewModel = KYCFormViewModel()
    @StateObject var authViewModel = AuthViewModel()
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView(showSplashScreen: $showSplashScreen)
                    .environmentObject(kycViewModel)
                    .environmentObject(authViewModel)
            } else {
                ContentView()
                    .environmentObject(kycViewModel)
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        if authViewModel.isAuthenticated {
            KYCFormView()
        } else {
            AuthenticationView()
        }
    }
}
