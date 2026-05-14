import SwiftUI

struct VignetteCurtain: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
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
            .mask(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.6),
                        Color.black.opacity(1.0)
                    ]),
                    center: .center,
                    startRadius: min(w, h) * 0.05,
                    endRadius: max(w, h) * 0.35
                )
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - App Launch Screen (shown first)
struct AppNameView: View {
    let bgColour   = Color(hex: "FFEFDB")
    let titleColour = Color(hex: "2C2820")
    let mutedColour = Color(hex: "A89072")

    @State private var titleOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            bgColour.ignoresSafeArea()
            VignetteCurtain()

            GeometryReader { geo in
                Circle()
                    .stroke(mutedColour.opacity(0.5), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .offset(x: -80, y: -80)
                Circle()
                    .stroke(mutedColour.opacity(0.5), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .offset(x: geo.size.width - 80, y: geo.size.height - 80)
            }

            VStack(spacing: 12) {
                Text("SNIPPETS")
                    .font(.custom("PatrickHand-Regular", size: 40))
                    .kerning(8)
                    .foregroundColor(titleColour)
                    .opacity(titleOpacity)

                Text("journal your world")
                    .font(.system(size: 14, weight: .light))
                    .italic()
                    .foregroundColor(mutedColour)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            // Fade in title
            withAnimation(.easeIn(duration: 0.8)) {
                titleOpacity = 1
            }
            // Fade in subtitle after title
            withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                subtitleOpacity = 1
            }
        }
    }
}

// MARK: - Today's Thought / Tap to Enter Screen
struct SplashView: View {
    @EnvironmentObject var store: JournalStore
    @State private var showHome = false
    @State private var openPromptOnAppear = false

    let todaysThought = "You are allowed to slow down"
    let subtitle = "Pausing isn't falling behind, it's how you stay present"
    let bgColour      = Color(hex: "FFEFDB")
    let curtainColour = Color(hex: "A89072")
    let textColour    = Color(hex: "5A4A39")
    let mutedColour   = Color(hex: "A89072")
    let titleColour   = Color(hex: "2C2820")

    var body: some View {
        ZStack {
            bgColour.ignoresSafeArea()
            VignetteCurtain()

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

            VStack(spacing: 0) {
                Text("SNIPPETS")
                    .font(.custom("PatrickHand-Regular", size: 32))
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

            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    openPromptOnAppear = false
                    showHome = true
                }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.Name("NavigateToPrompt")
            )
        ) { _ in
            openPromptOnAppear = true
            showHome = true
        }
        .fullScreenCover(isPresented: $showHome) {
            HomeRootView(openPromptOnAppear: openPromptOnAppear)
                .environmentObject(store)
        }
    }
}

// MARK: - Root Entry Point
struct AppEntryView: View {
    @EnvironmentObject var store: JournalStore
    @State private var showSplash = false
    @State private var appNameOpacity: Double = 1

    var body: some View {
        ZStack {
            // Layer 1: App name screen (shown first)
            if !showSplash {
                AppNameView()
                    .opacity(appNameOpacity)
                    .transition(.opacity)
            }

            // Layer 2: Today's thought screen (fades in after)
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // After 2 seconds, fade out app name screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.8)) {
                    appNameOpacity = 0
                }
                // After fade out completes, show splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        showSplash = true
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppEntryView()
            .environmentObject(JournalStore())
    }
}
