//
//  MacControlCenterMenu.swift
//  MacControlCenterUIDemoApp • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MenuBarExtraAccess

/// macOS Control Center Menu view.
/// For menu-style items that highlight on mouse hover and execute code upon being clicked, use
/// the specially-provided ``MenuCommand``.
///
/// Example Usage:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @State var val: CGFloat = 0.0
///
///     var body: some Scene {
///         MenuBarExtra("MyApp") {
///             MacControlCenterMenu {
///                 MacControlCenterSlider("Amount", value: $val)
///                 MenuCommand("Command 1") {
///                     print("Command 1 pressed")
///                 }
///                 MenuCommand("Command 2") {
///                     print("Command 2 pressed")
///                 }
///                 Divider()
///                 MenuCommand("Quit") {
///                     print("Quit pressed")
///                 }
///             }
///         }
///         .menuBarExtraStyle(.window) // required to render correctly
///     }
/// }
/// ```
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MacControlCenterMenu: View {
    // MARK: Public Properties
    
    @Binding public var menuBarExtraIsPresented: Bool
    public var activateAppOnCommandSelection: Bool
    public var content: [any View]
    
    // MARK: Environment
    
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Init
    
    /// Useful for building a custom `MenuBarExtra` menu when using `.menuBarExtraStyle(.window)`.
    /// This builder allows the use of any custom View, and also supplies a special
    /// ``MenuCommand`` view for replicating clickable system menu items.
    ///
    /// - Parameters:
    ///   - isPresented: Pass the binding from `.menuBarExtraAccess(isPresented:)` here.
    ///   - activateAppOnCommandSelection: Activate the app before executing
    ///     command action blocks. This is often necessary since menubar items
    ///     can be accessed while the app is not in focus. This will allow
    ///     actions that open a window to bring the window (and app) to the front.
    ///   - content: Menu item builder content.
    public init(
        isPresented: Binding<Bool>,
        activateAppOnCommandSelection: Bool = true,
        @MacControlCenterMenuBuilder _ content: () -> [any View]
    ) {
        self._menuBarExtraIsPresented = isPresented
        self.activateAppOnCommandSelection = activateAppOnCommandSelection
        self.content = content()
    }
    
    // MARK: Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            unwrapContent
        }
        .padding([.top, .bottom], menuPadding)
        .background(VisualEffect.popoverWindow())
        //.introspectMenuBarExtraWindow { menuBarExtraWindow in
        //
        //}
    }
    
    // MARK: Helpers
    
    private var unwrapContent: some View {
        ForEach(content.indices, id: \.self) {
            convertView(content[$0])
                .environment(\.menuBarExtraIsPresented, $menuBarExtraIsPresented)
        }
    }
    
    private func convertView(_ view: any View) -> AnyView {
        switch view {
        case is (any MacControlCenterMenuItem):
            return AnyView(view)
            
        default:
            let wrappedView = MenuItem {
                AnyView(view)
            }
            return AnyView(wrappedView)
        }
    }
}