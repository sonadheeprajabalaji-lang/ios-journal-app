import SwiftUI

struct EmotionArtView: View {
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss

    // ← Pre-compute art data once so it doesn't regenerate on every render
    @State private var artData: [ArtElement] = []

    let affirmations: [String] = [
        "Every feeling you've had is valid.",
        "Your emotions are a map of your inner world.",
        "Feeling deeply is a sign of great strength.",
        "You are allowed to feel everything.",
        "Each colour is a piece of your story.",
    ]

    @State private var affirmation: String = ""

    var allEmotionColors: [Color] {
        let hexes = store.settings.values.flatMap { $0.emotionLog }
        guard !hexes.isEmpty else {
            return [
                Color(hex: "C7956F"), Color(hex: "7A4A30"),
                Color(hex: "306A50"), Color(hex: "90AF8B"),
                Color(hex: "D3A5A1"), Color(hex: "C7A753"),
                Color(hex: "AF80C6"), Color(hex: "1D3B5B"),
            ]
        }
        return hexes.compactMap { Color(hex: $0) }
    }

    var body: some View {
        ZStack {
            Color(hex: "FAF6F0").ignoresSafeArea()

            // Draw from pre-computed stable data
            Canvas { context, size in
                for element in artData {
                    switch element.type {
                    case .blob:
                        let rect = CGRect(
                            x: element.x - element.size,
                            y: element.y - element.size,
                            width: element.size * 2,
                            height: element.size * 2
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(element.color.opacity(element.opacity))
                        )
                    case .stroke:
                        var path = Path()
                        path.move(to: CGPoint(
                            x: element.x - cos(element.angle) * element.size / 2,
                            y: element.y - sin(element.angle) * element.size / 2
                        ))
                        path.addQuadCurve(
                            to: CGPoint(
                                x: element.x + cos(element.angle) * element.size / 2,
                                y: element.y + sin(element.angle) * element.size / 2
                            ),
                            control: CGPoint(x: element.cpX, y: element.cpY)
                        )
                        context.stroke(
                            path,
                            with: .color(element.color.opacity(element.opacity)),
                            style: StrokeStyle(lineWidth: element.lineWidth, lineCap: .round)
                        )
                    case .dot:
                        let r = element.size
                        let rect = CGRect(x: element.x - r, y: element.y - r, width: r * 2, height: r * 2)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(element.color.opacity(element.opacity))
                        )
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
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

                VStack(spacing: 10) {
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
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Generate art data once on appear
            affirmation = affirmations.randomElement() ?? affirmations[0]
            artData = generateArtData()
        }
    }

    func generateArtData() -> [ArtElement] {
        let colors = allEmotionColors
        guard !colors.isEmpty else { return [] }
        var elements: [ArtElement] = []

        // Blobs
        for i in 0..<min(colors.count, 20) {
            elements.append(ArtElement(
                type: .blob,
                color: colors[i % colors.count],
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: 0...800),
                size: CGFloat.random(in: 60...160),
                opacity: Double.random(in: 0.15...0.35),
                angle: 0, cpX: 0, cpY: 0, lineWidth: 0
            ))
        }

        // Strokes
        for i in 0..<min(colors.count * 2, 40) {
            let x = CGFloat.random(in: 30...370)
            let y = CGFloat.random(in: 30...770)
            elements.append(ArtElement(
                type: .stroke,
                color: colors[i % colors.count],
                x: x,
                y: y,
                size: CGFloat.random(in: 40...120),
                opacity: Double.random(in: 0.4...0.75),
                angle: CGFloat.random(in: 0...Double.pi * 2),
                cpX: x + CGFloat.random(in: -30...30),
                cpY: y + CGFloat.random(in: -30...30),
                lineWidth: CGFloat.random(in: 6...20)
            ))
        }

        // Dots
        for i in 0..<min(colors.count * 3, 60) {
            elements.append(ArtElement(
                type: .dot,
                color: colors[i % colors.count],
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: 0...800),
                size: CGFloat.random(in: 3...12),
                opacity: Double.random(in: 0.5...0.9),
                angle: 0, cpX: 0, cpY: 0, lineWidth: 0
            ))
        }

        return elements
    }
}

// MARK: - Art Element
struct ArtElement {
    enum ElementType { case blob, stroke, dot }
    let type: ElementType
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let angle: CGFloat
    let cpX: CGFloat
    let cpY: CGFloat
    let lineWidth: CGFloat
}

// MARK: - Preview
struct EmotionArtView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionArtView()
            .environmentObject(JournalStore())
    }
}
