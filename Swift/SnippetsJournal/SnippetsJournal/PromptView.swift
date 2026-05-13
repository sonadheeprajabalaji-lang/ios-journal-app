import SwiftUI

// MARK: - Prompts Data
struct PromptData {
    static let prompts = [
        "Capture the sunlight hitting something",
        "Find a shadow that tells a story",
        "Photograph something you walked past a hundred times",
        "Capture a colour that makes you feel calm",
        "Find something small that most people overlook",
        "Photograph the sky right now, exactly as it is",
        "Capture light coming through something",
        "Find a texture that looks beautiful up close",
        "Photograph something that represents this moment",
        "Capture the way water looks right now",
        "Find something old that still has beauty in it",
        "Photograph a reflection you notice nearby",
        "Capture something that is moving in the wind",
        "Find a corner of your space that feels peaceful",
        "Photograph what the light looks like on the floor",
        "Capture something you are grateful for right now",
        "Find a pattern in nature around you",
        "Photograph something that makes you smile",
        "Capture the colours of where you are sitting",
        "Find something that looks different in this light"
    ]
}

// MARK: - Mindfulness Step
enum MindfulnessStep {
    case pause, breathe, lookAround
}

// MARK: - Prompt View
struct PromptView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPrompt: String = PromptData.prompts.randomElement()!
    @State private var mindfulnessStep: MindfulnessStep? = nil
    @State private var promptOpacity: Double = 1.0
    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil
    @State private var showJournalPicker = false
    @State private var showMockCamera = false

    var body: some View {
        ZStack {
            if let step = mindfulnessStep {
                MindfulnessView(step: step) {
                    advanceMindfulness()
                }
                .transition(.opacity)
            } else {
                promptScreen
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: mindfulnessStep)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCamera) {
            ImagePickerView(sourceType: .camera) { image in
                capturedImage = image
                showJournalPicker = true
            }
        }
        .sheet(isPresented: $showMockCamera) {
            MockCameraView { image in
                capturedImage = image
                showJournalPicker = true
            }
        }
        .fullScreenCover(isPresented: $showJournalPicker) {
            JournalPickerView(image: capturedImage ?? UIImage(systemName: "photo") ?? UIImage())
        }
    }

    // MARK: - Prompt Screen
    var promptScreen: some View {
        ZStack {
            // Background
            Color(hex: "FFEFDB").ignoresSafeArea()

            // Curtain vignette
            VignetteCurtain()

            // Decorative arcs
            GeometryReader { geo in
                Circle()
                    .stroke(Color(hex: "A89072").opacity(0.5), lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .offset(x: -40, y: -100)
                Circle()
                    .stroke(Color(hex: "A89072").opacity(0.5), lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .offset(x: geo.size.width - 120, y: geo.size.height - 120)
            }

            // Tap anywhere to advance (behind everything)
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        mindfulnessStep = .pause
                    }
                }

            VStack(spacing: 0) {
                Spacer()

                // Prompt card with washi tape
                ZStack(alignment: .top) {
                    // Card
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color(hex: "C8A882").opacity(0.25), radius: 20, x: 0, y: 8)
                        .frame(width: 300, height: 300)

                    // Subtle inner border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "EDE0D0"), lineWidth: 1)
                        .frame(width: 300, height: 300)

                    // Prompt text centred in card
                    Text(currentPrompt)
                        .font(.custom("PatrickHand-Regular", size: 40))
                        .foregroundColor(Color(hex: "2C2820"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .frame(width: 300, height: 300, alignment: .center)
                        .opacity(promptOpacity)

                    // Washi tape image on top
                    Group {
                        if let _ = UIImage(named: "washiTape") {
                            Image("washiTape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 72)
                        } else {
                            // Fallback drawn tape
                            WashiTape()
                        }
                    }
                    .offset(y: -32)
                }
                // Stop card taps from triggering the background tap
                .contentShape(Rectangle())
                .onTapGesture { }

                // Refresh button — isolated from background tap
                Button(action: refreshPrompt) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FEFAF4"))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .light))
                            .foregroundColor(Color(hex: "A89072"))
                    }
                }
                .padding(.top, 20)
                // Critical: stop button tap reaching background
                .onTapGesture { }

                Spacer()

                Text("Tap when you are ready")
                    .font(.system(size: 13, weight: .light))
                    .italic()
                    .foregroundColor(Color(hex: "A89072"))
                    .padding(.bottom, 50)
            }
        }
    }

    func refreshPrompt() {
        withAnimation(.easeOut(duration: 0.2)) {
            promptOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            var newPrompt = PromptData.prompts.randomElement()!
            while newPrompt == currentPrompt {
                newPrompt = PromptData.prompts.randomElement()!
            }
            currentPrompt = newPrompt
            withAnimation(.easeIn(duration: 0.3)) {
                promptOpacity = 1
            }
        }
    }

    func advanceMindfulness() {
        withAnimation(.easeInOut(duration: 0.5)) {
            switch mindfulnessStep {
            case .pause:      mindfulnessStep = .breathe
            case .breathe:    mindfulnessStep = .lookAround
            case .lookAround:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    // Simulator fallback — show mock camera
                    showMockCamera = true
                }
            case nil:         mindfulnessStep = .pause
            }
        }
    }
}

// MARK: - Washi Tape (fallback if no image)
struct WashiTape: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "C7A753").opacity(0.85))
                .frame(width: 90, height: 24)

            Canvas { context, size in
                let stripeWidth: CGFloat = 5
                let total: CGFloat = 10
                let count = Int(size.width / total) + 1
                for i in 0..<count {
                    let x = CGFloat(i) * total
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(
                        path,
                        with: .color(Color(hex: "B8922E").opacity(0.35)),
                        lineWidth: stripeWidth
                    )
                }
            }
            .frame(width: 90, height: 24)
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .rotationEffect(.degrees(-1.5))
    }
}

// MARK: - Mindfulness View
struct MindfulnessView: View {
    let step: MindfulnessStep
    let onTap: () -> Void

    @State private var circleScale: CGFloat = 1.0
    @State private var textOpacity: Double = 0.0

    var stepText: String {
        switch step {
        case .pause:      return "Pause"
        case .breathe:    return "Breathe"
        case .lookAround: return "Look around\nyou"
        }
    }

    var body: some View {
        ZStack {
            Color(hex: "FFEFDB").ignoresSafeArea()
            VignetteCurtain()

            GeometryReader { geo in
                Circle()
                    .stroke(Color(hex: "A89072").opacity(0.5), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .offset(x: -80, y: -80)
                Circle()
                    .stroke(Color(hex: "A89072").opacity(0.5), lineWidth: 1)
                    .frame(width: 160, height: 160)
                    .offset(x: geo.size.width - 80, y: geo.size.height - 80)
            }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Color(hex: "C8A882").opacity(0.15))
                        .frame(width: 220, height: 220)
                        .scaleEffect(circleScale * 1.12)
                        .animation(
                            .easeInOut(duration: 3.5)
                            .repeatForever(autoreverses: true),
                            value: circleScale
                        )

                    // Main breathing circle
                    Circle()
                        .fill(Color(hex: "C8A882").opacity(0.5))
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)
                        .animation(
                            .easeInOut(duration: 3.5)
                            .repeatForever(autoreverses: true),
                            value: circleScale
                        )

                    Text(stepText)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Color(hex: "5A4A39"))
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                }

                Spacer()

                // Show tap hint on last screen only
                if step == .lookAround {
                    Text("Tap when you are ready")
                        .font(.system(size: 13, weight: .light))
                        .italic()
                        .foregroundColor(Color(hex: "A89072"))
                        .padding(.bottom, 50)
                        .opacity(textOpacity)
                } else {
                    Color.clear.frame(height: 70)
                }
            }

            // Tap to advance
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onTap() }
        }
        .onAppear {
            withAnimation {
                circleScale = 1.18
            }
            withAnimation(.easeIn(duration: 0.8)) {
                textOpacity = 1.0
            }
        }
        .onChange(of: step) { _ in
            textOpacity = 0
            withAnimation(.easeIn(duration: 0.8)) {
                textOpacity = 1.0
            }
        }
    }
}

// MARK: - Preview
struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView()
    }
}
