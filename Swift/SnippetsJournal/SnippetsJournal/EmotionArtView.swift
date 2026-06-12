import SwiftUI

// MARK: - Seeded Random
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: Int) { self.state = UInt64(bitPattern: Int64(seed)) }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
    mutating func nextDouble() -> Double {
        return Double(next()) / Double(UInt64.max)
    }
    mutating func nextCGFloat(in range: ClosedRange<CGFloat>) -> CGFloat {
        return range.lowerBound + CGFloat(nextDouble()) * (range.upperBound - range.lowerBound)
    }
    mutating func nextDouble(in range: ClosedRange<Double>) -> Double {
        return range.lowerBound + nextDouble() * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Art Element
struct ArtElement {
    enum ElementType { case wash, blob, disc, stroke, dot, ring }

    let type: ElementType
    let color: Color
    let position: CGPoint        // normalised 0...1
    let size: CGFloat            // fraction of the smaller screen dimension
    let opacity: Double
    let points: [CGPoint]        // normalised path points (strokes only)
    let lineWidth: CGFloat
    let appearDelay: Double
    let appearDuration: Double
    let driftPhase: Double
    let driftSpeed: Double
    let driftAmp: CGFloat
}

// MARK: - Emotion Art View
struct EmotionArtView: View {
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss

    @State private var artData: [ArtElement] = []
    @State private var paletteSwatches: [Color] = []
    @State private var startDate = Date()
    @State private var showCard = false
    @State private var affirmation: String = ""

    let affirmations: [String] = [
        "Every feeling you've had is valid.",
        "Your emotions are a map of your inner world.",
        "Feeling deeply is a sign of great strength.",
        "You are allowed to feel everything.",
        "Each colour is a piece of your story.",
    ]

    var body: some View {
        ZStack {
            Color(hex: "FAF6F0").ignoresSafeArea()

            // MARK: Living canvas
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSince(startDate)
                    drawArt(context: context, size: size, time: t)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "FEFAF4").opacity(0.85))
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                // MARK: Affirmation card
                VStack(spacing: 12) {
                    Text("Your emotion palette")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "A89072"))
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text(affirmation)
                        .font(.custom("Georgia", size: 20))
                        .foregroundColor(Color(hex: "2C2820"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)

                    HStack(spacing: 8) {
                        ForEach(paletteSwatches.indices, id: \.self) { i in
                            Circle()
                                .fill(paletteSwatches[i])
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "2C2820").opacity(0.1), lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "FEFAF4").opacity(0.88))
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
                .opacity(showCard ? 1 : 0)
                .offset(y: showCard ? 0 : 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            affirmation = affirmations.randomElement() ?? affirmations[0]
            generateArt()
            startDate = Date()
            showCard = false
            withAnimation(.easeOut(duration: 0.9).delay(2.6)) {
                showCard = true
            }
        }
    }

    // MARK: - Drawing
    func drawArt(context: GraphicsContext, size: CGSize, time t: Double) {
        let minDim = min(size.width, size.height)

        for element in artData {
            let raw = (t - element.appearDelay) / element.appearDuration
            let progress = min(max(raw, 0), 1)
            guard progress > 0 else { continue }
            let eased = easeOutCubic(progress)

            let drift = CGPoint(
                x: sin(t * element.driftSpeed + element.driftPhase) * element.driftAmp * minDim,
                y: cos(t * element.driftSpeed * 0.8 + element.driftPhase) * element.driftAmp * minDim * 0.7
            )
            let center = CGPoint(
                x: element.position.x * size.width + drift.x,
                y: element.position.y * size.height + drift.y
            )

            switch element.type {

            case .wash:
                let breathe = 1 + 0.04 * sin(t * element.driftSpeed + element.driftPhase)
                let radius = element.size * minDim * CGFloat(eased) * breathe
                let rect = CGRect(x: center.x - radius, y: center.y - radius,
                                  width: radius * 2, height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            element.color.opacity(element.opacity * eased),
                            element.color.opacity(0)
                        ]),
                        center: center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )

            case .blob:
                let radius = element.size * minDim * CGFloat(0.6 + 0.4 * eased)
                let rect = CGRect(x: center.x - radius, y: center.y - radius,
                                  width: radius * 2, height: radius * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            element.color.opacity(element.opacity * eased),
                            element.color.opacity(element.opacity * 0.5 * eased),
                            element.color.opacity(0)
                        ]),
                        center: center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )

            case .disc:
                // Flat circle of solid colour — pops in with a bounce,
                // then drifts and gently breathes.
                let pop = easeOutBack(progress)
                let breathe = 1 + 0.04 * sin(t * element.driftSpeed * 1.4 + element.driftPhase)
                let r = element.size * minDim * CGFloat(pop) * breathe
                let rect = CGRect(x: center.x - r, y: center.y - r,
                                  width: r * 2, height: r * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(element.color.opacity(element.opacity * eased))
                )

            case .stroke:
                guard element.points.count > 1 else { break }
                var path = Path()
                let pts = element.points.map { p in
                    CGPoint(x: p.x * size.width + drift.x,
                            y: p.y * size.height + drift.y)
                }
                path.move(to: pts[0])
                for i in 1..<pts.count {
                    let prev = pts[i - 1]
                    let curr = pts[i]
                    let mid = CGPoint(x: (prev.x + curr.x) / 2, y: (prev.y + curr.y) / 2)
                    path.addQuadCurve(to: mid, control: prev)
                }
                path.addLine(to: pts[pts.count - 1])

                let visible = path.trimmedPath(from: 0, to: CGFloat(eased))

                if element.lineWidth >= 8 {
                    context.stroke(
                        visible,
                        with: .color(element.color.opacity(element.opacity * 0.22)),
                        style: StrokeStyle(lineWidth: element.lineWidth * 1.5,
                                           lineCap: .round, lineJoin: .round)
                    )
                }
                context.stroke(
                    visible,
                    with: .color(element.color.opacity(element.opacity)),
                    style: StrokeStyle(lineWidth: element.lineWidth,
                                       lineCap: .round, lineJoin: .round)
                )

            case .ring:
                let breathe = 1 + 0.05 * sin(t * element.driftSpeed * 1.6 + element.driftPhase)
                let radius = element.size * minDim * breathe
                let spin = t * element.driftSpeed * 0.6 + element.driftPhase
                let sweep = 2 * Double.pi * eased

                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(spin),
                    endAngle: .radians(spin + sweep),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(element.color.opacity(element.opacity * eased)),
                    style: StrokeStyle(lineWidth: element.lineWidth, lineCap: .round)
                )

            case .dot:
                let pop = easeOutBack(progress)
                let twinkle = 0.85 + 0.15 * sin(t * 1.4 + element.driftPhase)
                let r = element.size * minDim * CGFloat(pop)
                let rect = CGRect(x: center.x - r, y: center.y - r,
                                  width: r * 2, height: r * 2)
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(element.color.opacity(element.opacity * eased * twinkle))
                )
            }
        }

        // Warm paper vignette
        let vignetteRadius = max(size.width, size.height) * 0.75
        let screenCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(
                Gradient(colors: [
                    Color.clear,
                    Color(hex: "C8A882").opacity(0.18)
                ]),
                center: screenCenter,
                startRadius: vignetteRadius * 0.45,
                endRadius: vignetteRadius
            )
        )
    }

    // MARK: - Easing
    func easeOutCubic(_ x: Double) -> Double {
        1 - pow(1 - x, 3)
    }

    func easeOutBack(_ x: Double) -> Double {
        let c: Double = 1.70158
        return 1 + (c + 1) * pow(x - 1, 3) + c * pow(x - 1, 2)
    }

    // MARK: - Palette derivation
    func derivedPalette(from baseColors: [Color]) -> [Color] {
        var palette: [Color] = []
        for color in baseColors {
            let ui = UIColor(color)
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
                palette.append(color)
                continue
            }
            palette.append(color)                                              // base
            palette.append(hsb(h, max(s - 0.18, 0.05), min(b + 0.18, 0.97)))   // lighter
            palette.append(hsb(h, min(s + 0.12, 1.0), max(b - 0.22, 0.15)))    // deeper
            palette.append(hsb(h, s * 0.35, min(b + 0.25, 0.95)))              // muted pastel
            palette.append(hsb(fmod(h + 0.055, 1.0), s * 0.85, b))             // analogous warm
            palette.append(hsb(fmod(h + 0.945, 1.0), s * 0.85, b * 0.92))      // analogous cool
        }
        return palette
    }

    func hsb(_ h: CGFloat, _ s: CGFloat, _ b: CGFloat) -> Color {
        Color(UIColor(hue: h, saturation: s, brightness: b, alpha: 1.0))
    }

    // MARK: - Generation (seeded — same emotion log, same artwork)
    func generateArt() {
        let hexes = store.allSettings.flatMap { $0.emotionLog }

        let hexSource: [String] = hexes.isEmpty
            ? ["C7956F", "7A4A30", "306A50", "90AF8B"]
            : hexes

        let baseColors = hexSource.map { Color(hex: $0) }
        let palette = derivedPalette(from: baseColors)

        var seen = Set<String>()
        paletteSwatches = hexSource
            .filter { seen.insert($0).inserted }
            .prefix(8)
            .map { Color(hex: $0) }

        let seed = hexSource.joined().unicodeScalars.reduce(0) { $0 + Int($1.value) }
        var rng = SeededRandom(seed: Int.random(in: 1...Int.max))
        var elements: [ArtElement] = []

        // The invisible current every stroke follows
        let fa = rng.nextDouble(in: 1.6...2.8)
        let fb = rng.nextDouble(in: 1.6...2.8)
        let p1 = rng.nextDouble(in: 0...(2 * .pi))
        let p2 = rng.nextDouble(in: 0...(2 * .pi))
        let baseAngle = rng.nextDouble(in: 0...(2 * .pi))

        func fieldAngle(_ pt: CGPoint) -> Double {
            baseAngle
                + 0.9 * sin(Double(pt.x) * fa * .pi + p1)
                + 0.9 * cos(Double(pt.y) * fb * .pi + p2)
        }

        func flowStroke(from start: CGPoint, steps: Int, stepSize: CGFloat) -> [CGPoint] {
            var pts = [start]
            var current = start
            for _ in 0..<steps {
                let angle = fieldAngle(current)
                current = CGPoint(
                    x: current.x + CGFloat(cos(angle)) * stepSize,
                    y: current.y + CGFloat(sin(angle)) * stepSize * 0.5
                )
                if current.x < 0.02 || current.x > 0.98 ||
                   current.y < 0.02 || current.y > 0.98 { break }
                pts.append(current)
            }
            return pts
        }

        var starts: [CGPoint] = []
        for gx in 0..<5 {
            for gy in 0..<8 {
                starts.append(CGPoint(
                    x: (CGFloat(gx) + 0.5) / 5 + rng.nextCGFloat(in: -0.07...0.07),
                    y: (CGFloat(gy) + 0.5) / 8 + rng.nextCGFloat(in: -0.04...0.04)
                ))
            }
        }
        starts.shuffle(using: &rng)

        // 1. Large washes — the underpainting
        for i in 0..<5 {
            elements.append(ArtElement(
                type: .wash,
                color: palette[i * 3 % palette.count],
                position: CGPoint(x: rng.nextCGFloat(in: 0.1...0.9),
                                  y: rng.nextCGFloat(in: 0.1...0.9)),
                size: rng.nextCGFloat(in: 0.45...0.85),
                opacity: rng.nextDouble(in: 0.10...0.18),
                points: [], lineWidth: 0,
                appearDelay: rng.nextDouble(in: 0.0...0.4),
                appearDuration: 1.4,
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.15...0.3),
                driftAmp: rng.nextCGFloat(in: 0.004...0.01)
            ))
        }

        // 2. Pigment blobs
        for i in 0..<10 {
            elements.append(ArtElement(
                type: .blob,
                color: palette[(i * 5 + 1) % palette.count],
                position: CGPoint(x: rng.nextCGFloat(in: 0.08...0.92),
                                  y: rng.nextCGFloat(in: 0.08...0.92)),
                size: rng.nextCGFloat(in: 0.07...0.16),
                opacity: rng.nextDouble(in: 0.14...0.26),
                points: [], lineWidth: 0,
                appearDelay: rng.nextDouble(in: 0.3...1.2),
                appearDuration: 1.0,
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.2...0.45),
                driftAmp: rng.nextCGFloat(in: 0.003...0.008)
            ))
        }

        // 3. Flat colour discs — solid filled circles, the most playful
        // and most visibly moving layer.
        for i in 0..<12 {
            elements.append(ArtElement(
                type: .disc,
                color: palette[(i * 5 + 2) % palette.count],
                position: CGPoint(x: rng.nextCGFloat(in: 0.06...0.94),
                                  y: rng.nextCGFloat(in: 0.06...0.94)),
                size: rng.nextCGFloat(in: 0.018...0.06),
                opacity: rng.nextDouble(in: 0.5...0.85),
                points: [], lineWidth: 0,
                appearDelay: rng.nextDouble(in: 0.8...2.2),
                appearDuration: rng.nextDouble(in: 0.5...0.8),
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.25...0.5),
                driftAmp: rng.nextCGFloat(in: 0.006...0.014)
            ))
        }

        // 4a. Wide soft ribbons
        for i in 0..<8 {
            let start = starts[i % starts.count]
            elements.append(ArtElement(
                type: .stroke,
                color: palette[(i * 7 + 2) % palette.count],
                position: start, size: 0,
                opacity: rng.nextDouble(in: 0.22...0.34),
                points: flowStroke(from: start, steps: 14,
                                   stepSize: rng.nextCGFloat(in: 0.035...0.05)),
                lineWidth: rng.nextCGFloat(in: 14...26),
                appearDelay: rng.nextDouble(in: 0.6...1.4),
                appearDuration: rng.nextDouble(in: 1.4...2.0),
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.15...0.3),
                driftAmp: rng.nextCGFloat(in: 0.002...0.005)
            ))
        }

        // 4b. Mid brush strokes
        for i in 0..<14 {
            let start = starts[(i + 8) % starts.count]
            elements.append(ArtElement(
                type: .stroke,
                color: palette[(i * 11 + 4) % palette.count],
                position: start, size: 0,
                opacity: rng.nextDouble(in: 0.45...0.65),
                points: flowStroke(from: start, steps: 11,
                                   stepSize: rng.nextCGFloat(in: 0.028...0.04)),
                lineWidth: rng.nextCGFloat(in: 6...11),
                appearDelay: rng.nextDouble(in: 1.0...2.0),
                appearDuration: rng.nextDouble(in: 1.0...1.5),
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.2...0.4),
                driftAmp: rng.nextCGFloat(in: 0.002...0.005)
            ))
        }

        // 4c. Fine lines
        for i in 0..<14 {
            let start = starts[(i + 22) % starts.count]
            elements.append(ArtElement(
                type: .stroke,
                color: palette[(i * 13 + 6) % palette.count],
                position: start, size: 0,
                opacity: rng.nextDouble(in: 0.55...0.8),
                points: flowStroke(from: start, steps: 9,
                                   stepSize: rng.nextCGFloat(in: 0.022...0.034)),
                lineWidth: rng.nextCGFloat(in: 1.5...3.5),
                appearDelay: rng.nextDouble(in: 1.4...2.4),
                appearDuration: rng.nextDouble(in: 0.8...1.2),
                driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                driftSpeed: rng.nextDouble(in: 0.25...0.5),
                driftAmp: rng.nextCGFloat(in: 0.001...0.004)
            ))
        }

        // 5. Rings — circle outlines echoing the app's decorative arcs
        for i in 0..<6 {
            let ringCenter = CGPoint(x: rng.nextCGFloat(in: 0.12...0.88),
                                     y: rng.nextCGFloat(in: 0.1...0.9))
            let ringColor = palette[(i * 7 + 5) % palette.count]
            let baseSize = rng.nextCGFloat(in: 0.05...0.16)
            let ringCount = rng.nextDouble() < 0.4 ? 2 : 1

            for r in 0..<ringCount {
                elements.append(ArtElement(
                    type: .ring,
                    color: ringColor,
                    position: ringCenter,
                    size: baseSize + CGFloat(r) * rng.nextCGFloat(in: 0.03...0.05),
                    opacity: rng.nextDouble(in: 0.3...0.55) * (r == 0 ? 1.0 : 0.6),
                    points: [],
                    lineWidth: rng.nextCGFloat(in: 1...2.5),
                    appearDelay: rng.nextDouble(in: 0.5...2.2) + Double(r) * 0.3,
                    appearDuration: rng.nextDouble(in: 1.0...1.6),
                    driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                    driftSpeed: rng.nextDouble(in: 0.2...0.45),
                    driftAmp: rng.nextCGFloat(in: 0.004...0.01)
                ))
            }
        }

        // 6. Speckles — clustered like flicked paint
        for c in 0..<6 {
            let clusterCenter = CGPoint(x: rng.nextCGFloat(in: 0.12...0.88),
                                        y: rng.nextCGFloat(in: 0.12...0.88))
            let clusterColor = palette[(c * 9 + 3) % palette.count]
            for _ in 0..<5 {
                elements.append(ArtElement(
                    type: .dot,
                    color: clusterColor,
                    position: CGPoint(
                        x: min(max(clusterCenter.x + rng.nextCGFloat(in: -0.06...0.06), 0.02), 0.98),
                        y: min(max(clusterCenter.y + rng.nextCGFloat(in: -0.045...0.045), 0.02), 0.98)
                    ),
                    size: rng.nextCGFloat(in: 0.002...0.008),
                    opacity: rng.nextDouble(in: 0.45...0.8),
                    points: [], lineWidth: 0,
                    appearDelay: rng.nextDouble(in: 1.8...2.8),
                    appearDuration: 0.5,
                    driftPhase: rng.nextDouble(in: 0...(2 * .pi)),
                    driftSpeed: rng.nextDouble(in: 0.3...0.6),
                    driftAmp: rng.nextCGFloat(in: 0.001...0.003)
                ))
            }
        }

        artData = elements
    }
}

// MARK: - Preview
struct EmotionArtView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionArtView()
            .environmentObject(JournalStore())
    }
}
