import SwiftUI

// MARK: - Journal View
struct JournalView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var isFlipping = false
    @State private var flipDirection: FlipDirection = .forward
    @State private var flipProgress: Double = 0
    @State private var selectedTab = 0
    @State private var showEntryView = false

    let totalPages = 6

    enum FlipDirection {
        case forward, backward
    }

    var body: some View {
        VStack(spacing: 0) {
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
                        Text(settings.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2C2820"))
                        Spacer()
                        Button(action: {}) {
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
                    .padding(.bottom, 40)

                    Spacer()

                    // MARK: Book
                    ZStack {
                        ForEach((0..<4).reversed(), id: \.self) { i in
                            StackedPageView(
                                offset: CGFloat(i) * 4,
                                coverColor: settings.coverColor
                            )
                            .offset(y: CGFloat(i) * 1.5)
                        }

                        OpenBookWithFlip(
                            currentPage: $currentPage,
                            isFlipping: $isFlipping,
                            flipDirection: $flipDirection,
                            flipProgress: $flipProgress,
                            totalPages: totalPages,
                            coverColor: settings.coverColor,
                            pagePattern: settings.pagePattern,
                            onFlipForward: flipForward,
                            onFlipBackward: flipBackward
                        )
                    }
                    .frame(height: 360)

                    // Page indicator
                    Text("Page \(currentPage + 1) of \(totalPages)")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(hex: "A89072"))
                        .padding(.top, 16)

                    Spacer()

                    // MARK: Action Buttons
                    HStack(spacing: 20) {
                        ActionButton(icon: "xmark", isDark: true) { dismiss() }
                        ActionButton(icon: "trash", isDark: false) {}
                        ActionButton(icon: "pencil", isDark: false) {
                            showEntryView = true
                        }
                    }
                    .padding(.bottom, 30)
                }
            }

            TabBarView(selectedTab: .constant(0))
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showEntryView) {
            JournalEntryView(journal: journal, settings: settings)
        }
    }

    func flipForward() {
        guard currentPage < totalPages - 1, !isFlipping else { return }
        flipDirection = .forward
        isFlipping = true
        withAnimation(.easeInOut(duration: 0.5)) { flipProgress = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { currentPage += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { flipProgress = 0; isFlipping = false }
    }

    func flipBackward() {
        guard currentPage > 0, !isFlipping else { return }
        flipDirection = .backward
        isFlipping = true
        withAnimation(.easeInOut(duration: 0.5)) { flipProgress = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { currentPage -= 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { flipProgress = 0; isFlipping = false }
    }
}

// MARK: - Open Book With Flip
struct OpenBookWithFlip: View {
    @Binding var currentPage: Int
    @Binding var isFlipping: Bool
    @Binding var flipDirection: JournalView.FlipDirection
    @Binding var flipProgress: Double
    let totalPages: Int
    let coverColor: Color
    let pagePattern: PagePattern
    let onFlipForward: () -> Void
    let onFlipBackward: () -> Void

    var body: some View {
        ZStack {
            // LEFT page
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: -4, y: 4)

                PagePatternView(pattern: pagePattern)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Spacer()
                    if currentPage == 0 {
                        Text("Start writing...")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(Color(hex: "C8B8A8"))
                    }
                    Spacer()
                }
                .padding(20)
            }
            .frame(width: 155, height: 310)
            .offset(x: -79)
            .onTapGesture { onFlipBackward() }

            // RIGHT page
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 4, y: 4)

                PagePatternView(pattern: pagePattern)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack {
                    Spacer()
                    if currentPage == totalPages - 1 {
                        Text("End of journal")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(Color(hex: "C8B8A8"))
                    }
                    Spacer()
                }
                .padding(20)
            }
            .frame(width: 155, height: 310)
            .offset(x: 79)
            .onTapGesture { onFlipForward() }

            // Spine shadow
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.06),
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.06)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 16, height: 310)

            // Flipping page overlay
            if isFlipping {
                let angle = flipDirection == .forward
                    ? -180 * flipProgress
                    :  180 * flipProgress

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "F5F0EA"), Color.white],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 155, height: 310)
                    .overlay(
                        PagePatternView(pattern: pagePattern)
                    )
                    .overlay(
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(Color.black.opacity(0.06))
                                .frame(width: 8)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .rotation3DEffect(
                        .degrees(angle),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: flipDirection == .forward ? .leading : .trailing,
                        perspective: 0.4
                    )
                    .offset(x: flipDirection == .forward ? 79 : -79)
                    .shadow(
                        color: .black.opacity(0.12 * (1 - abs(flipProgress - 0.5) * 2)),
                        radius: 8, x: 0, y: 4
                    )
            }
        }
    }
}

// MARK: - Stacked Page
struct StackedPageView: View {
    let offset: CGFloat
    let coverColor: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 148, height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(coverColor.opacity(0.15), lineWidth: 0.5)
                )
                .offset(x: -79 - offset, y: offset * 0.4)
                .shadow(color: .black.opacity(0.03), radius: 2, x: -1, y: 1)

            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 148, height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(coverColor.opacity(0.15), lineWidth: 0.5)
                )
                .offset(x: 79 + offset, y: offset * 0.4)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 1, y: 1)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let isDark: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isDark ? Color(hex: "2C2820") : Color(hex: "FEFAF4").opacity(0.9))
                    .frame(width: 52, height: 52)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                Circle()
                    .stroke(
                        isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.8),
                        lineWidth: 1
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isDark ? .white : Color(hex: "2C2820"))
            }
        }
    }
}

// MARK: - Preview
struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        let journal = Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        )
        JournalView(journal: journal, settings: JournalSettings(journal: journal))
    }
}
