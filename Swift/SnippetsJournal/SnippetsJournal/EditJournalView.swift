import SwiftUI

// MARK: - Page Pattern
enum PagePattern: CaseIterable {
    case plain, ruled, dotted, grid

    var label: String {
        switch self {
        case .plain:  return "Plain"
        case .ruled:  return "Ruled"
        case .dotted: return "Dotted"
        case .grid:   return "Grid"
        }
    }
}

// MARK: - Edit Journal View (Page Style)
struct EditJournalView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    @Environment(\.dismiss) var dismiss
    @State private var selectedPattern: PagePattern
    @State private var navigateToCover = false

    init(journal: Journal, settings: JournalSettings) {
        self.journal = journal
        self.settings = settings
        _selectedPattern = State(initialValue: settings.pagePattern)
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
                        Text("Edit")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2C2820"))
                        Spacer()
                        Button(action: {
                            settings.pagePattern = selectedPattern
                            navigateToCover = true
                        }) {
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
                    .padding(.bottom, 24)

                    // MARK: Pattern Name
                    VStack(spacing: 6) {
                        Text(selectedPattern.label)
                            .font(.custom("PatrickHand-Regular", size: 28))
                            .foregroundColor(Color(hex: "2C2820"))
                            .id(selectedPattern)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: selectedPattern)

                        Text("page style")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Color(hex: "A89072"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)

                    Spacer()

                    // MARK: Open Book Preview
                    ZStack {
                        ForEach((0..<4).reversed(), id: \.self) { i in
                            StackedPageView(
                                offset: CGFloat(i) * 4,
                                coverColor: settings.coverColor
                            )
                            .offset(y: CGFloat(i) * 1.5)
                        }

                        EditOpenBookView(
                            coverColor: settings.coverColor,
                            selectedPattern: selectedPattern
                        )
                    }
                    .frame(height: 360)

                    Spacer()

                    // MARK: Pattern Picker
                    HStack(spacing: 0) {
                        Text("Pattern:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "2C2820"))
                            .frame(width: 70, alignment: .leading)
                            .padding(.leading, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(PagePattern.allCases, id: \.self) { pattern in
                                    PatternThumbnail(
                                        pattern: pattern,
                                        isSelected: selectedPattern == pattern
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedPattern = pattern
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 14)
                            .padding(.trailing, 20)
                        }
                    }
                    .background(Color(hex: "FDE0BC").opacity(0.5))
                }
            }

            TabBarView(selectedTab: .constant(0))
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToCover) {
            EditCoverView(journal: journal, settings: settings)
        }
    }
}

// MARK: - Edit Open Book View
struct EditOpenBookView: View {
    let coverColor: Color
    let selectedPattern: PagePattern

    var body: some View {
        ZStack {
            // Left page
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: -4, y: 4)
                PagePatternView(pattern: selectedPattern)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 155, height: 310)
            .offset(x: -79)

            // Right page
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 4, y: 4)
                PagePatternView(pattern: selectedPattern)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 155, height: 310)
            .offset(x: 79)

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
        }
    }
}

// MARK: - Page Pattern View
struct PagePatternView: View {
    let pattern: PagePattern
    var isThumbnail: Bool = false

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                switch pattern {

                case .plain:
                    break

                case .ruled:
                    let lineSpacing: CGFloat = isThumbnail ? 10 : 24
                    let topPad: CGFloat = isThumbnail ? 10 : 32
                    let sidePad: CGFloat = isThumbnail ? 8 : 16
                    var y = topPad
                    while y < size.height - (isThumbnail ? 8 : 16) {
                        var path = Path()
                        path.move(to: CGPoint(x: sidePad, y: y))
                        path.addLine(to: CGPoint(x: size.width - sidePad, y: y))
                        context.stroke(
                            path,
                            with: .color(Color(hex: "B0A898").opacity(isThumbnail ? 0.9 : 0.7)),
                            lineWidth: isThumbnail ? 1.2 : 0.8
                        )
                        y += lineSpacing
                    }

                case .dotted:
                    let spacing: CGFloat = isThumbnail ? 11 : 18
                    let startX: CGFloat = isThumbnail ? spacing : 20
                    let startY: CGFloat = isThumbnail ? spacing : 20
                    var y = startY
                    while y < size.height - (isThumbnail ? 4 : 10) {
                        var x = startX
                        while x < size.width - (isThumbnail ? 4 : 10) {
                            let dotSize: CGFloat = isThumbnail ? 2.5 : 3
                            let rect = CGRect(
                                x: x - dotSize / 2,
                                y: y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            )
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(Color(hex: "B0A898").opacity(isThumbnail ? 0.9 : 0.6))
                            )
                            x += spacing
                        }
                        y += spacing
                    }

                case .grid:
                    let spacing: CGFloat = isThumbnail ? 10 : 20
                    var x: CGFloat = spacing
                    while x < size.width {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            path,
                            with: .color(Color(hex: "B0A898").opacity(isThumbnail ? 0.9 : 0.6)),
                            lineWidth: isThumbnail ? 0.8 : 0.6
                        )
                        x += spacing
                    }
                    var y: CGFloat = spacing
                    while y < size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(
                            path,
                            with: .color(Color(hex: "B0A898").opacity(isThumbnail ? 0.9 : 0.6)),
                            lineWidth: isThumbnail ? 0.8 : 0.6
                        )
                        y += spacing
                    }
                }
            }
        }
    }
}

// MARK: - Pattern Thumbnail
struct PatternThumbnail: View {
    let pattern: PagePattern
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 80, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? Color(hex: "2C2820") : Color(hex: "D0C8BE"),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

            PagePatternView(pattern: pattern, isThumbnail: true)
                .frame(width: 80, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(width: 80, height: 56)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
struct EditJournalView_Previews: PreviewProvider {
    static var previews: some View {
        let journal = Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        )
        EditJournalView(journal: journal, settings: JournalSettings(journal: journal))
    }
}
