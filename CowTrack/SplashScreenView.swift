//  SplashScreenView.swift
//  CowTrack
//
//  Created by Alejandro on 12/07/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack {
                    
                    if colorScheme == .dark{
                        Image("SplashScreenNight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            
                    } else {
                        Image("SplashScreen")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                        
    
                    /*
                    Text("CowTrack")
                        .font(.system(size: 35))
                        .bold()
                     */
                }
                Text("CowTrack").bold()

            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    SplashScreenView()
}
