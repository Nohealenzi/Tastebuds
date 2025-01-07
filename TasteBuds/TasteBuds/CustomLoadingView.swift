//
//  CustomLoadingView.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/10/24.
//

import Foundation
import SwiftUI

struct CustomLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryGreen))
                .scaleEffect(1.5)
            Text("Loading...")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}
