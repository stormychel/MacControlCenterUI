//
//  MenuCircleToggle.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import SwiftUI

/// macOS Control Center-style circle toggle control.
/// For the momentary button variant, use ``MenuCircleButton`.
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MenuCircleToggle<Label: View>: View {
    // MARK: Public Properties
    
    @Binding public var isOn: Bool
    public var style: MenuCircleButtonStyle
    public var label: Label?
    public var onClickBlock: (Bool) -> Void
    
    // MARK: Environment
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    
    // MARK: Private State
    
    @State private var isMouseDown: Bool = false
    private var controlSize: MenuCircleButtonSize
    
    // MARK: Init - No Label
    
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        style: MenuCircleButtonStyle,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where Label == EmptyView {
        _isOn = isOn
        self.controlSize = controlSize
        self.style = style
        label = nil
        self.onClickBlock = onClickBlock
    }
    
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        image: Image,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where Label == EmptyView {
        _isOn = isOn
        self.controlSize = controlSize
        style = .init(image: image)
        label = nil
        self.onClickBlock = onClickBlock
    }
    
    // MARK: Init - With String Label
    
    @_disfavoredOverload
    public init<S>(
        _ title: S,
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        style: MenuCircleButtonStyle,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where S: StringProtocol, Label == Text {
        label = Text(title)
        _isOn = isOn
        self.controlSize = controlSize
        self.style = style
        self.onClickBlock = onClickBlock
    }
    
    @_disfavoredOverload
    public init<S>(
        _ title: S,
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        image: Image,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where S: StringProtocol, Label == Text {
        label = Text(title)
        _isOn = isOn
        self.controlSize = controlSize
        style = .init(image: image)
        self.onClickBlock = onClickBlock
    }
    
    // MARK: Init - With LocalizedStringKey Label
    
    public init(
        _ titleKey: LocalizedStringKey,
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        style: MenuCircleButtonStyle,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where Label == Text {
        label = Text(titleKey)
        _isOn = isOn
        self.controlSize = controlSize
        self.style = style
        self.onClickBlock = onClickBlock
    }
    
    public init(
        _ titleKey: LocalizedStringKey,
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        image: Image,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) where Label == Text {
        label = Text(titleKey)
        _isOn = isOn
        self.controlSize = controlSize
        style = .init(image: image)
        self.onClickBlock = onClickBlock
    }
    
    // MARK: Init - With Label Closure
    
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        style: MenuCircleButtonStyle,
        @ViewBuilder label: @escaping () -> Label,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) {
        _isOn = isOn
        self.controlSize = controlSize
        self.style = style
        self.label = label()
        self.onClickBlock = onClickBlock
    }
    
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        image: Image,
        @ViewBuilder label: @escaping () -> Label,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) {
        _isOn = isOn
        self.controlSize = controlSize
        style = .init(image: image)
        self.label = label()
        self.onClickBlock = onClickBlock
    }
    
    // MARK: Init - With Label
    
    @_disfavoredOverload
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        style: MenuCircleButtonStyle,
        label: Label,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) {
        _isOn = isOn
        self.controlSize = controlSize
        self.style = style
        self.label = label
        self.onClickBlock = onClickBlock
    }
    
    @_disfavoredOverload
    public init(
        isOn: Binding<Bool>,
        controlSize: MenuCircleButtonSize = .menu,
        image: Image,
        label: Label,
        onClick onClickBlock: @escaping (Bool) -> Void = { _ in }
    ) {
        _isOn = isOn
        self.controlSize = controlSize
        style = .init(image: image)
        self.label = label
        self.onClickBlock = onClickBlock
    }
    
    // MARK: Body
    
    public var body: some View {
        switch controlSize {
        case .menu:
            if label != nil {
                hitTestBody
                    .frame(height: controlSize.size)
                    .frame(maxWidth: .infinity)
            } else {
                hitTestBody
                    .frame(width: controlSize.size, height: controlSize.size)
            }
        case .prominent:
            if label != nil {
                hitTestBody
                    .frame(
                        minHeight: controlSize.size + 26,
                        alignment: .top
                    )
            } else {
                hitTestBody
                    .frame( // width: style.size,
                        height: controlSize.size,
                        alignment: .top
                    )
            }
        }
    }
    
    @ViewBuilder
    private var hitTestBody: some View {
        GeometryReader { geometry in
            buttonBody
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard isEnabled else { return }
                            let hit = geometry.frame(in: .local).contains(value.location)
                            isMouseDown = hit
                        }
                        .onEnded { value in
                            guard isEnabled else { return }
                            defer { isMouseDown = false }
                            if isMouseDown {
                                isOn.toggle()
                                onClickBlock(isOn)
                            }
                        }
                )
                .onChange(of: isEnabled) { newValue in
                    if !isEnabled {
                        isMouseDown = false
                    }
                }
        }
    }
    
    @ViewBuilder
    private var buttonBody: some View {
        if let label = labelWithFormatting {
            switch controlSize {
            case .menu:
                HStack {
                    circleBody
                    label.frame(maxWidth: .infinity, alignment: .leading)
                }
            case .prominent:
                VStack(alignment: .center, spacing: 4) {
                    circleBody
                    label
                }
                .fixedSize()
            }
        } else {
            circleBody
        }
    }
    
    @ViewBuilder
    private var labelWithFormatting: (some View)? {
        label?
            .foregroundColor(isEnabled ? Color.primary : .primary.opacity(0.5))
    }
    
    @ViewBuilder
    private var circleBody: some View {
        ZStack {
            if style.hasColor {
                Circle()
                    .background(visualEffect)
                    .foregroundColor(buttonBackColor)
            }
            Group {
                if let image {
                    image
                        .foregroundColor(buttonForeColor)
                        .opacity(imageOpacity)
                        .saturation(imageSaturation)
                    
                    if !style.hasColor, isMouseDown {
                        Rectangle()
                            .foregroundColor(.black)
                            .blendMode(.color)
                            .opacity(0.5)
                    }
                }
            }
            .padding(imagePadding)
            
            if isMouseDown, style.hasColor {
                if colorScheme == .dark {
                    Circle()
                        .foregroundColor(.white)
                        .opacity(0.1)
                } else {
                    Circle()
                        .foregroundColor(.black)
                        .opacity(0.1)
                }
            }
        }
        .frame(width: controlSize.size, height: controlSize.size)
    }
    
    private var image: (some View)? {
        style.image(forState: isOn)?
            // .resizable() // already applied in `MenuCircleButtonStyle`
            .scaledToFit()
    }
    
    /// Adjust padding based on whether an image is present or not for the current toggle state.
    private var imagePadding: CGFloat {
        let circlePadding = style.hasColor
            ? controlSize.imagePadding
            : 0.0
        return circlePadding + style.imagePadding
    }
    
    private var imageOpacity: CGFloat {
        var amount: CGFloat = 1.0
        
        if !isOn, let dimAmount = style.offImageDimAmount {
            let multiplier = 1.0 - dimAmount.clamped(to: 0.0 ... 1.0)
            amount *= multiplier
        }
        
        if !style.hasColor, isMouseDown {
            amount *= isOn ? 0.8 : 1.2
        }
        
        if !style.hasColor, !isEnabled {
            amount *= 0.5
        }
        
        return amount
    }
    
    private var imageSaturation: CGFloat {
        guard !style.hasColor else { return 1.0 }
        return isOn ? 1.0 : 0.0
    }
    
    // MARK: Helpers
    
    private var visualEffect: VisualEffect? {
        guard !isOn else { return nil }
        if colorScheme == .dark {
            return VisualEffect(
                .hudWindow,
                vibrancy: false,
                blendingMode: .withinWindow,
                mask: mask()
            )
        } else {
            return VisualEffect(
                .underWindowBackground,
                vibrancy: true,
                blendingMode: .behindWindow,
                mask: mask()
            )
        }
    }
    
    private func mask() -> NSImage?  {
        NSImage(
            color: .black,
            ovalSize: .init(width: controlSize.size, height: controlSize.size)
        )
    }
    
    private var buttonBackColor: Color? {
        style.color(forState: isOn, isEnabled: isEnabled, colorScheme: colorScheme)
    }
    
    private var buttonForeColor: Color {
        let base: Color = switch isOn {
        case true:
            switch colorScheme {
            case .dark:
                style.invertForeground
                    ? Color(NSColor.textBackgroundColor)
                    : Color(NSColor.textColor)
            case .light:
                style.invertForeground
                    ? Color(NSColor.textColor)
                    : Color(NSColor.textBackgroundColor)
            @unknown default:
                Color(NSColor.textColor)
            }
        case false:
            switch colorScheme {
            case .dark:
                Color(white: 0.85)
            case .light:
                .black
            @unknown default:
                Color(NSColor.selectedMenuItemTextColor)
            }
        }
        
        return isEnabled ? base : base.opacity(0.4)
    }
}

#endif
