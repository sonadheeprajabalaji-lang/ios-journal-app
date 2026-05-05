import SwiftUI

// MARK: - Journal Model
struct Journal: Identifiable {
    let id = UUID()
    let title: String
    let coverColor: Color
    let stripeColor: Color
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

    static func == (lhs: Journal, rhs: Journal) -> Bool {
            lhs.id == rhs.id
        }
}

// MARK: - Home View
struct HomeView: View {
    @State private var selectedTab = 0
    @State private var currentJournalIndex = 1
    @GestureState private var dragOffset: CGFloat = 0
    @State private var selectedJournal: Journal? = nil

    let userName = "Olivia"
    let cardWidth: CGFloat = 275
    let cardHeight: CGFloat = 399
    let spacing: CGFloat = 16

    let journals: [Journal] = [
        Journal(title: "Vacation\nJournal",
                coverColor: Color(hex: "7B9BB5"),
                stripeColor: Color(hex: "6A8BA4")),
        Journal(title: "Gratitude\nJournal",
                coverColor: Color(hex: "C8624A"),
                stripeColor: Color(hex: "B8927A")),
        Journal(title: "Prompt\nJournal",
                coverColor: Color(hex: "7A8C6E"),
                stripeColor: Color(hex: "8A9C7E"))
    ]

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
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

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome\n\(userName)!")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color(hex: "2C2820"))
                                .lineSpacing(2)
                            Text(dateString)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(hex: "8C7B6B"))
                                .padding(.top, 2)
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            GlassButton(icon: "magnifyingglass")
                            GlassButton(icon: "plus")
                        }
                        .padding(.top, 0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .padding(.bottom, 28)

                    // MARK: My Journals Row
                    HStack {
                        Text("My Journals")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "2C2820"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "2C2820"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    // MARK: Carousel
                    GeometryReader { geo in
                        let totalCardWidth = cardWidth + spacing

                        HStack(spacing: spacing) {
                            ForEach(0..<journals.count, id: \.self) { index in
                                JournalCoverView(
                                    journal: journals[index],
                                    isCenter: index == currentJournalIndex,
                                    cardWidth: cardWidth,
                                    cardHeight: cardHeight
                                )
                                .onTapGesture {
                                    if index == currentJournalIndex {
                                        selectedJournal = journals[index]
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                        .offset(x: CGFloat(geo.size.width - cardWidth) / 2
                                - CGFloat(currentJournalIndex) * totalCardWidth
                                + dragOffset)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentJournalIndex)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation.width * 0.8
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    if value.translation.width < -threshold {
                                        currentJournalIndex = min(currentJournalIndex + 1, journals.count - 1)
                                    } else if value.translation.width > threshold {
                                        currentJournalIndex = max(currentJournalIndex - 1, 0)
                                    }
                                }
                        )
                    }
                    .frame(height: cardHeight + 10)
                    .clipped()

                    // MARK: Page Dots
                    HStack(spacing: 8) {
                        ForEach(0..<journals.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentJournalIndex
                                      ? Color(hex: "2C2820")
                                      : Color(hex: "C8B8A8"))
                                .frame(
                                    width: index == currentJournalIndex ? 20 : 8,
                                    height: 8
                                )
                                .animation(.spring(), value: currentJournalIndex)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }

            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: Binding(
            get: { selectedJournal != nil },
            set: { if !$0 { selectedJournal = nil } }
        )) {
            if let journal = selectedJournal {
                JournalView(journal: journal)
            }
        }
    }
}

// MARK: - Journal Cover View
struct JournalCoverView: View {
    let journal: Journal
    let isCenter: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var body: some View {
        ZStack {
            StripedCover(
                baseColor: journal.coverColor,
                stripeColor: journal.stripeColor
            )
            .clipShape(JournalCoverShape(cornerRadius: 20))
            .shadow(
                color: .black.opacity(isCenter ? 0.2 : 0.08),
                radius: isCenter ? 16 : 6,
                x: 0, y: isCenter ? 8 : 3
            )

            Image("journalTexture")
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(JournalCoverShape(cornerRadius: 20))
                .blendMode(.softLight)
                .opacity(0.7)
                .allowsHitTesting(false)

            if isCenter {
                StarLabel(title: journal.title)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .scaleEffect(isCenter ? 1.0 : 0.88)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCenter)
    }
}

// MARK: - Striped Cover
struct StripedCover: View {
    let baseColor: Color
    let stripeColor: Color

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(baseColor)
                )
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
                        with: .color(stripeColor.opacity(0.55)),
                        lineWidth: stripeWidth
                    )
                }
            }
        }
    }
}

// MARK: - Journal Cover Shape (flat left, rounded right)
struct JournalCoverShape: Shape {
    var cornerRadius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Star Label
struct StarLabel: View {
    let title: String

    var body: some View {
        ZStack {
            Image("journalStar")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

            Text(title)
                .font(.custom("PatrickHand-Regular", size: 32))
                .foregroundColor(Color(hex: "2C2820"))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(width: 110)
        }
    }
}

// MARK: - Glass Button
struct GlassButton: View {
    let icon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "FEFAF4").opacity(0.85))
                .frame(width: 44, height: 44)
                .background(Circle().fill(.ultraThinMaterial))

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            Color.white.opacity(0.15),
                            Color(hex: "FDE0BC").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color(hex: "C8B8A8").opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 44, height: 44)

            Circle()
                .trim(from: 0.0, to: 0.4)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(-45))

            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "2C2820"))
        }
        .shadow(color: Color(hex: "C8A882").opacity(0.35), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Tab Bar
struct TabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill",     label: "Home",    isSelected: selectedTab == 0) { selectedTab = 0 }
            TabBarItem(icon: "bubble.left",    label: "Prompt",  isSelected: selectedTab == 1) { selectedTab = 1 }
            TabBarItem(icon: "chart.bar.fill", label: "Library", isSelected: selectedTab == 2) { selectedTab = 2 }
        }
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(Color(hex: "FDE0BC").opacity(0.6))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(hex: "C8B8A8")),
            alignment: .top
        )
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? Color(hex: "2C2820") : Color(hex: "A89072"))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
