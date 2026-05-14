import SwiftUI

// MARK: - Emotion Stroke
struct EmotionStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    let color: Color
}

// MARK: - Emotion View
struct EmotionView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedColor: Color = Color(hex: "C7956F")
    @State private var strokes: [EmotionStroke] = []
    @State private var currentStroke: EmotionStroke? = nil
    @State private var showSaved = false

    let emotionColors: [Color] = [
        Color(hex: "7A4A30"),
        Color(hex: "306A50"),
        Color(hex: "7C2A36"),
        Color(hex: "1D3B5B"),
        Color(hex: "000000"),
        Color(hex: "C7956F"),
        Color(hex: "C7A753"),
        Color(hex: "90AF8B"),
        Color(hex: "D3A5A1"),
        Color(hex: "AF80C6"),
    ]

    var body: some View {
        if showSaved {
            EmotionSavedView()
        } else {
            emotionCanvas
        }
    }

    var emotionCanvas: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(hex: "FFFFFF"), Color(hex: "FDE0BC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "2C2820"))
                    }
                    Spacer()
                    Text("How are you feeling?")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2C2820"))
                    Spacer()
                    Button(action: { saveAndContinue() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FEFAF4").opacity(0.85))
                                .frame(width: 36, height: 36)
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                .frame(width: 36, height: 36)
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "2C2820"))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 16)

                Text("Paint a colour that represents\nyour feeling right now...")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(Color(hex: "8C7B6B"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                // MARK: Paint Canvas
                GeometryReader { geo in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)

                        Canvas { context, size in
                            for stroke in strokes {
                                drawStroke(context: context, stroke: stroke)
                            }
                            if let current = currentStroke {
                                drawStroke(context: context, stroke: current)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        if strokes.isEmpty && currentStroke == nil {
                            Text("Paint your feeling here...")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(Color(hex: "C8B8A8"))
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let loc = value.location
                                guard loc.x >= 0 && loc.x <= geo.size.width &&
                                      loc.y >= 0 && loc.y <= geo.size.height else { return }
                                if currentStroke == nil {
                                    currentStroke = EmotionStroke(points: [loc], color: selectedColor)
                                } else {
                                    currentStroke?.points.append(loc)
                                }
                            }
                            .onEnded { _ in
                                if let stroke = currentStroke {
                                    strokes.append(stroke)
                                    currentStroke = nil
                                }
                            }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // MARK: Colour Palette
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: {
                            if !strokes.isEmpty { strokes.removeLast() }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEFAF4"))
                                    .frame(width: 34, height: 34)
                                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "2C2820"))
                            }
                        }

                        ForEach(emotionColors, id: \.self) { color in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedColor = color
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 34, height: 34)
                                    if selectedColor == color {
                                        Circle()
                                            .stroke(Color(hex: "2C2820"), lineWidth: 2.5)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                }
                .background(Color(hex: "FEFAF4").opacity(0.6))
                .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }

    func drawStroke(context: GraphicsContext, stroke: EmotionStroke) {
        guard stroke.points.count > 1 else {
            if let pt = stroke.points.first {
                let rect = CGRect(x: pt.x - 10, y: pt.y - 10, width: 20, height: 20)
                context.fill(Path(ellipseIn: rect), with: .color(stroke.color.opacity(0.85)))
            }
            return
        }

        var path = Path()
        path.move(to: stroke.points[0])
        for i in 1..<stroke.points.count {
            let prev = stroke.points[i - 1]
            let curr = stroke.points[i]
            let mid = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
            path.addQuadCurve(to: mid, control: prev)
        }
        path.addLine(to: stroke.points[stroke.points.count - 1])

        context.stroke(
            path,
            with: .color(stroke.color.opacity(0.85)),
            style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
        )
    }

    func saveAndContinue() {
        let colorHexes = strokes.map { UIColor($0.color).toHex() ?? "" }
        settings.emotionLog.append(contentsOf: colorHexes)
        withAnimation(.easeInOut(duration: 0.4)) {
            showSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            store.shouldPopToHome = true
        }
    }

    func navigateToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        func findNavController(_ vc: UIViewController) -> UINavigationController? {
            if let nav = vc as? UINavigationController { return nav }
            for child in vc.children {
                if let nav = findNavController(child) { return nav }
            }
            return nil
        }
        findNavController(rootVC)?.popToRootViewController(animated: true)
    }
}

// MARK: - Emotion Saved View
struct EmotionSavedView: View {
    var body: some View {
        ZStack {
            Color(hex: "F0E6D3").ignoresSafeArea()

            GeometryReader { geo in
                Canvas { context, size in
                    let lineCount = 28
                    let spacing = size.width / CGFloat(lineCount)
                    for i in 0..<lineCount {
                        let x = CGFloat(i) * spacing
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            path,
                            with: .color(Color(hex: "E8D9C4").opacity(0.6)),
                            lineWidth: spacing * 0.6
                        )
                    }
                }
            }
            .ignoresSafeArea()

            GeometryReader { geo in
                Path { path in
                    path.addArc(
                        center: CGPoint(x: 0, y: 0),
                        radius: geo.size.width * 0.45,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false
                    )
                }
                .stroke(Color(hex: "2C2820").opacity(0.25), lineWidth: 1)

                Path { path in
                    path.addArc(
                        center: CGPoint(x: geo.size.width, y: geo.size.height),
                        radius: geo.size.width * 0.45,
                        startAngle: .degrees(180),
                        endAngle: .degrees(270),
                        clockwise: false
                    )
                }
                .stroke(Color(hex: "2C2820").opacity(0.25), lineWidth: 1)
            }
            .ignoresSafeArea()

            VStack(spacing: 8) {
                Text("Feeling noted")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(Color(hex: "3C2E22"))
                Text("Your emotion has been saved.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "7A6555"))
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - UIColor hex helper
extension UIColor {
    func toHex() -> String? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

// MARK: - Preview
struct EmotionView_Previews: PreviewProvider {
    static var previews: some View {
        let journal = Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        )
        EmotionView(
            journal: journal,
            settings: JournalSettings(journal: journal)
        )
        .environmentObject(JournalStore())
    }
}
