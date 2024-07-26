//
//  CowTrackApp.swift
//  CowTrack
//
//  Created by Alejandro on 10/07/24.
//

import SwiftUI

@main
struct CowTrackApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showSplashScreen = false
                        }
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
