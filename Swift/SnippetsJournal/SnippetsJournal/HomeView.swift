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
    var openPromptOnAppear: Bool = false
    @EnvironmentObject var store: JournalStore
    @State private var selectedTab = 0
    @State private var currentJournalIndex = 1
    @GestureState private var dragOffset: CGFloat = 0
    @State private var selectedJournal: Journal? = nil
    @State private var editingJournal: Journal? = nil
    @State private var showPrompt = false
    @State private var showLibrary = false
    var journals: [Journal] { store.journals }
    let userName = "Olivia"
    let cardWidth: CGFloat = 275
    let cardHeight: CGFloat = 399
    let spacing: CGFloat = 16


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
                            Button(action: {
                                NotificationManager.shared.scheduleTestNotification()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "FEFAF4").opacity(0.85))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.ultraThinMaterial))
                                    Image(systemName: "bell")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "2C2820"))
                                }
                            }
                        }
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
                            ForEach(journals) { journal in
                                let index = journals.firstIndex(where: { $0.id == journal.id }) ?? 0
                                let settings = store.settings(for: journal)
                                JournalCoverView(
                                    journal: journal,
                                    settings: settings,
                                    isCenter: index == currentJournalIndex,
                                    cardWidth: cardWidth,
                                    cardHeight: cardHeight,
                                    onEditTapped: {
                                        editingJournal = journal
                                    }
                                )
                                .onTapGesture {
                                    if index == currentJournalIndex {
                                        selectedJournal = journal
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
                    .frame(height: cardHeight + 50)
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
                                    height: 10
                                )
                                .animation(.spring(), value: currentJournalIndex)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 52)
                }
            }

            TabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            if openPromptOnAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showPrompt = true
                }
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.Name("NavigateToPrompt")
            )
        ) { _ in
            showPrompt = true
        }
        .onReceive(store.$shouldPopToHome) { should in
            if should {
                // Dismiss all pushed views by resetting navigation
                showPrompt = false
                showLibrary = false 
                selectedJournal = nil
                editingJournal = nil
                store.shouldPopToHome = false
            }
        }
        .onReceive(store.$shouldNavigateToPrompt) { should in
            if should {
                showPrompt = true
                store.shouldNavigateToPrompt = false
            }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                showPrompt = true
                selectedTab = 0
            } else if newValue == 2 {
                showLibrary = true
                selectedTab = 0
            }
        }
        .navigationDestination(isPresented: $showPrompt) {
            PromptView()
        }
        .navigationDestination(isPresented: $showLibrary) {
            LibraryView()
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedJournal != nil },
            set: { if !$0 { selectedJournal = nil } }
        )) {
            if let journal = selectedJournal {
                JournalView(journal: journal, settings: store.settings(for: journal))
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { editingJournal != nil },
            set: { if !$0 { editingJournal = nil } }
        )) {
            if let journal = editingJournal {
                EditJournalView(journal: journal, settings: store.settings(for: journal))
            }
        }
    }
}

// MARK: - Journal Cover View
struct JournalCoverView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    let isCenter: Bool
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    var onEditTapped: (() -> Void)? = nil

    var body: some View {
        ZStack {
            CoverPatternView(
                pattern: settings.coverPattern,
                baseColor: settings.coverColor,
                patternColor: settings.patternColor
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
                ZStack {
                    Image("journalStar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                    Text(settings.title)
                        .font(.custom("PatrickHand-Regular", size: 32))
                        .foregroundColor(Color(hex: "2C2820"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(width: 110)
                }
            }

            if isCenter {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { onEditTapped?() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEFAF4").opacity(0.9))
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(.ultraThinMaterial))
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "2C2820"))
                            }
                            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 14)
                        .padding(.trailing, 14)
                    }
                    Spacer()
                }
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

// MARK: - Journal Cover Shape
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

// MARK: - Custom Prompt Icon
struct PromptTabIcon: View {
    var color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 10, height: 10)
                .offset(x: -6, y: 6)
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 10, height: 10)
                .offset(x: -6, y: -6)
            RoundedRectangle(cornerRadius: 2)
                .frame(width: 10, height: 10)
                .offset(x: 6, y: 6)
            RoundedRectangle(cornerRadius: 1.5)
                .frame(width: 9, height: 9)
                .rotationEffect(.degrees(45))
                .offset(x: 6, y: -6)
        }
        .foregroundColor(color)
        .frame(width: 24, height: 24)
    }
}

// MARK: - Tab Bar
struct TabBarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            // Prompt — always fires action, never stays selected
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 4) {
                    PromptTabIcon(color: Color(hex: "A89072"))
                    Text("Prompt")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "A89072"))
                }
                .frame(maxWidth: .infinity)
            }

            // Library — always fires action, never stays selected
            TabBarItem(icon: "chart.bar.fill", label: "Library", isSelected: false) {
                selectedTab = 2
            }
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
        NavigationStack {
            HomeView()
                .environmentObject(JournalStore())
        }
    }
}
