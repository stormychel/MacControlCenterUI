//
//  IsMenuBarExtraPresentedEnvironmentKey.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import SwiftUI

extension EnvironmentValues {
    /// MenuBarExtra ID.
    var isMenuBarExtraPresented: Binding<Bool> {
        get { self[IsMenuBarExtraPresentedEnvironmentKey.self] }
        set { self[IsMenuBarExtraPresentedEnvironmentKey.self] = newValue }
    }
}

private struct IsMenuBarExtraPresentedEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

#endif
