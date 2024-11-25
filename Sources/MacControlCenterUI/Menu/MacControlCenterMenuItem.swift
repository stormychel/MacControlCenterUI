//
//  MacControlCenterMenuItem.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import SwiftUI

// MARK: - Menu Item Protocol

/// Internal use only.
/// It is not necessary to conform your views to this protocol unless you require custom view padding in a ``MacControlCenterMenu``.
@MainActor public protocol MacControlCenterMenuItem { }

#endif
