//
//  ColorWellView.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import AppKit
import SwiftUI

struct ColorWellView: NSViewRepresentable {
    @Binding var color: Color
    
    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell()
        colorWell.target = context.coordinator
        colorWell.action = #selector(Coordinator.colorChanged(_:))
        return colorWell
    }
    
    func updateNSView(_ nsView: NSColorWell, context: Context) {
        nsView.color = NSColor(color)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ColorWellView
        
        init(_ parent: ColorWellView) {
            self.parent = parent
        }
        
        @objc func colorChanged(_ sender: NSColorWell) {
            let newColor = Color(sender.color)
            parent.color = newColor
        }
    }
}
