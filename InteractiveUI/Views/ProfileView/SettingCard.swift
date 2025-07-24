//
//  SettingCard.swift
//  InteractiveUI
//
//  Created by Natasha Murashev on 7/22/25.
//

import SwiftUI

struct SettingCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let fontSize: Int
    let opacity: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: CGFloat(fontSize + 4), weight: .semibold))
                .foregroundColor(color)
                .opacity(opacity)
            
            Text(value)
                .font(.system(size: CGFloat(fontSize), weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .opacity(opacity)
            
            Text(title)
                .font(.system(size: CGFloat(fontSize - 4), weight: .medium))
                .foregroundColor(.secondary)
                .opacity(opacity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}
