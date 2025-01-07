//
//  TasteBudsApp.swift
//  TasteBuds
//
//  Created by Iacopo Lenzi on 12/9/24.
//

import SwiftUI
import Firebase


@main
struct TasteBudsApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

