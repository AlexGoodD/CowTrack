//
//  TransparentBlurView.swift
//  CowTrack
//
//  Created by Alejandro on 11/07/24.
//

import SwiftUI

struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

#Preview{
    TransparentBlurView()
}
