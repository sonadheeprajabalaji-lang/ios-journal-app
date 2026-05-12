import SwiftUI

// MARK: - Vignette Curtain (Radial)
struct VignetteCurtain: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Vertical stripes across full screen
            Canvas { context, size in
                let stripeWidth: CGFloat = 24
                let gapWidth: CGFloat = 20
                let total = stripeWidth + gapWidth
                let count = Int(size.width / total) + 1

                for i in 0..<count {
                    let x = CGFloat(i) * total
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(
                        path,
                        with: .color(Color(hex: "E8C9A5").opacity(0.5)),
                        lineWidth: stripeWidth
                    )
                }
            }
            // Radial mask — clear oval in centre, stripes show at edges
            .mask(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0), // Centre — fully transparent
                        Color.black.opacity(0.0), // Stay clear for a while
                        Color.black.opacity(0.6), // Start appearing
                        Color.black.opacity(1.0)  // Full stripes at edges
                    ]),
                    center: .center,
                    startRadius: min(w, h) * 0.05,  // How big the clear oval is
                    endRadius: max(w, h) * 0.35    // How far the stripes reach
                )
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @State private var navigateToHome = false

    let todaysThought = "You are allowed to slow down"
    let subtitle = "Pausing isn't falling behind, it's how you stay present"

    let bgColour    = Color(hex: "FFEFDB")
    let curtainColour = Color(hex: "A89072")
    let textColour  = Color(hex: "5A4A39")
    let mutedColour = Color(hex: "A89072")
    let titleColour = Color(hex: "2C2820")

    var body: some View {
        NavigationStack {
            ZStack {
                // Base background
                bgColour.ignoresSafeArea()

                // Vignette curtain — all edges, oval clear centre
                VignetteCurtain()

                // Decorative arcs
                GeometryReader { geo in
                    Circle()
                        .stroke(curtainColour.opacity(0.5), lineWidth: 1)
                        .frame(width: 160, height: 160)
                        .offset(x: -80, y: -80)

                    Circle()
                        .stroke(curtainColour.opacity(0.5), lineWidth: 1)
                        .frame(width: 160, height: 160)
                        .offset(x: geo.size.width - 80, y: geo.size.height - 80)
                }

                // Main content
                VStack(spacing: 0) {
                    Text("SNIPPETS")
                        .font(.custom("Georgia", size: 22))
                        .kerning(5)
                        .foregroundColor(titleColour)
                        .padding(.top, 70)

                    Spacer()

                    VStack(spacing: 18) {
                        Text("Today's Thought")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(mutedColour)

                        Text(todaysThought)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(textColour)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 50)

                        Text(subtitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(textColour)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 55)
                            .padding(.top, 6)
                    }

                    Spacer()

                    Text("Tap anywhere to enter")
                        .font(.system(size: 13, weight: .light))
                        .italic()
                        .foregroundColor(mutedColour)
                        .padding(.bottom, 88)
                }

                // Tap to navigate
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigateToHome = true
                    }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
