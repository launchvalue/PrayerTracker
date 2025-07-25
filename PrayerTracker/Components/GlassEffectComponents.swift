import SwiftUI

// MARK: - Glass Effect Container
struct GlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 20.0, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Glass Effect Modifier
struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
    }
}

extension View {
    func glassEffect() -> some View {
        modifier(GlassEffectModifier())
    }
    
    func glassEffectID(_ id: String, in namespace: Namespace.ID) -> some View {
        self.matchedGeometryEffect(id: id, in: namespace)
    }
}

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}

// MARK: - Modern Toggle Button
struct ModernToggleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Namespace private var namespace
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .glassEffectID("checkmark", in: namespace)
                }
            }
            .foregroundColor(isSelected ? .accentColor : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 16)
        }
        .buttonStyle(GlassButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Simple Navigation Buttons
struct SimpleNavigationButtons: View {
    let backAction: () -> Void
    let continueAction: () -> Void
    let continueText: String
    let canGoBack: Bool
    let canContinue: Bool
    
    init(
        backAction: @escaping () -> Void,
        continueAction: @escaping () -> Void,
        continueText: String = "Continue",
        canGoBack: Bool = true,
        canContinue: Bool = true
    ) {
        self.backAction = backAction
        self.continueAction = continueAction
        self.continueText = continueText
        self.canGoBack = canGoBack
        self.canContinue = canContinue
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Back Button with Standard Glass
            Button(action: backAction) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .controlSize(.regular)
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1.0 : 0.5)
            
            // Continue Button with Standard Glass
            Button(action: continueAction) {
                HStack(spacing: 6) {
                    Text(continueText)
                        .font(.system(size: 16, weight: .medium))
                    if continueText != "Begin Your Journey" {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .controlSize(.regular)
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.5)
        }
    }
}

// MARK: - Toolbar Navigation (Apple HIG Alternative)
struct ToolbarNavigationButtons: View {
    let backAction: () -> Void
    let continueAction: () -> Void
    let continueText: String
    let canGoBack: Bool
    let canContinue: Bool
    
    init(
        backAction: @escaping () -> Void,
        continueAction: @escaping () -> Void,
        continueText: String = "Continue",
        canGoBack: Bool = true,
        canContinue: Bool = true
    ) {
        self.backAction = backAction
        self.continueAction = continueAction
        self.continueText = continueText
        self.canGoBack = canGoBack
        self.canContinue = canContinue
    }
    
    var body: some View {
        // Toolbar approach following Apple HIG
        HStack {
            // Leading: Back button
            Button(action: backAction) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 17, weight: .regular))
                }
            }
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1.0 : 0.3)
            
            Spacer()
            
            // Trailing: Continue button
            Button(action: continueAction) {
                HStack(spacing: 4) {
                    Text(continueText)
                        .font(.system(size: 17, weight: .semibold))
                    if continueText != "Begin Your Journey" {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.regular)
            .tint(.blue)
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.3)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 0, style: .continuous)
        )
    }
}
