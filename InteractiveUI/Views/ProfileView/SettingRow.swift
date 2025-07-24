//
//  SettingRow.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import SwiftUI

struct SettingRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let fontSize: Int
    let opacity: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: CGFloat(fontSize), weight: .medium))
                .foregroundColor(color)
                .opacity(opacity)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: CGFloat(fontSize), weight: .medium))
                .foregroundColor(.primary)
                .opacity(opacity)
            
            Spacer()
            
            Text(value)
                .font(.system(size: CGFloat(fontSize - 2), weight: .regular))
                .foregroundColor(.secondary)
                .opacity(opacity)
                .lineLimit(1)
        }
    }
}
