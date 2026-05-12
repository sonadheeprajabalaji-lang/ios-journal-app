import SwiftUI

// MARK: - Cover Pattern
enum CoverPattern: CaseIterable {
    case plain, striped, checkered, dotted

    var label: String {
        switch self {
        case .plain:     return "Plain"
        case .striped:   return "Striped"
        case .checkered: return "Checkered"
        case .dotted:    return "Dotted"
        }
    }
}

// MARK: - Colour Picker Row
private struct ColorPickerRow: View {
    let colors: [Color]
    @Binding var selectedColor: Color
    @Binding var selectedPatternColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text("Cover:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C2820"))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedColor = color
                                selectedPatternColor = color.darker(by: 0.18)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                if color == Color(hex: "FFFFFF") {
                                    Circle()
                                        .stroke(Color(hex: "D0C8BE"), lineWidth: 1)
                                        .frame(width: 30, height: 30)
                                }
                                if selectedColor == color {
                                    Circle()
                                        .stroke(Color(hex: "2C2820"), lineWidth: 2.5)
                                        .frame(width: 36, height: 36)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Pattern Picker Row
private struct PatternPickerRow: View {
    let patterns = CoverPattern.allCases
    @Binding var selectedPattern: CoverPattern
    @Binding var selectedColor: Color
    @Binding var selectedPatternColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text("Pattern:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C2820"))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(patterns, id: \.self) { pattern in
                        CoverPatternThumbnail(
                            pattern: pattern,
                            baseColor: selectedColor,
                            patternColor: selectedPatternColor,
                            isSelected: selectedPattern == pattern
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPattern = pattern
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Pattern Colour Picker Row
private struct PatternColorPickerRow: View {
    let colors: [Color]
    @Binding var selectedPatternColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text("Colour:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "2C2820"))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPatternColor = color
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                if color == Color(hex: "FFFFFF") {
                                    Circle()
                                        .stroke(Color(hex: "D0C8BE"), lineWidth: 1)
                                        .frame(width: 30, height: 30)
                                }
                                if selectedPatternColor == color {
                                    Circle()
                                        .stroke(Color(hex: "2C2820"), lineWidth: 2.5)
                                        .frame(width: 36, height: 36)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Edit Cover View
struct EditCoverView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    @Environment(\.dismiss) var dismiss

    @State private var journalName: String
    @State private var isEditingName: Bool = false
    @State private var selectedColor: Color
    @State private var selectedPatternColor: Color
    @State private var selectedCoverPattern: CoverPattern

    init(journal: Journal, settings: JournalSettings) {
        self.journal = journal
        self.settings = settings
        _journalName = State(initialValue: settings.title)
        _selectedColor = State(initialValue: settings.coverColor)
        _selectedPatternColor = State(initialValue: settings.patternColor)
        _selectedCoverPattern = State(initialValue: settings.coverPattern)
    }

    let coverColors: [Color] = [
        Color(hex: "7A4A30"), Color(hex: "1D3B5B"), Color(hex: "7C2A36"),
        Color(hex: "306A50"), Color(hex: "000000"), Color(hex: "C7956F"),
        Color(hex: "C7A753"), Color(hex: "90AF8B"), Color(hex: "9F785C"),
        Color(hex: "2C2820"), Color(hex: "AF80C6"), Color(hex: "DE7B59"),
        Color(hex: "7B8C6F"), Color(hex: "D3A5A1"), Color(hex: "D8C9E7"),
        Color(hex: "E7C755"), Color(hex: "EAE0CF"), Color(hex: "F0D8D1"),
        Color(hex: "C9DFC9"), Color(hex: "FFFFFF"),
    ]

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
                        Text("Customise Cover")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2C2820"))
                        Spacer()
                        Button(action: {
                            settings.title = journalName
                            settings.coverColor = selectedColor
                            settings.patternColor = selectedPatternColor
                            settings.coverPattern = selectedCoverPattern
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                dismiss()
                            }
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

                    // MARK: Editable Name
                    HStack(spacing: 8) {
                        if isEditingName {
                            TextField("Journal name", text: $journalName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                )
                                .frame(maxWidth: 220)

                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isEditingName = false
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "2C2820"))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        } else {
                            Text(journalName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.7))
                                )

                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isEditingName = true
                                }
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "8C7B6B"))
                            }
                        }
                    }
                    .padding(.bottom, 20)

                    // MARK: Cover Preview
                    ZStack {
                        CoverPatternView(
                            pattern: selectedCoverPattern,
                            baseColor: selectedColor,
                            patternColor: selectedPatternColor
                        )
                        .clipShape(JournalCoverShape(cornerRadius: 16))

                        Image("journalTexture")
                            .resizable()
                            .scaledToFill()
                            .clipShape(JournalCoverShape(cornerRadius: 16))
                            .blendMode(.softLight)
                            .opacity(0.6)
                            .allowsHitTesting(false)

                        ZStack {
                            Image("journalStar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                            Text(journalName)
                                .font(.custom("PatrickHand-Regular", size: 22))
                                .foregroundColor(Color(hex: "2C2820"))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                                .frame(width: 90)
                        }
                    }
                    .frame(width: 200, height: 280)
                    .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
                    .padding(.bottom, 24)

                    // MARK: Pickers
                    ColorPickerRow(
                        colors: coverColors,
                        selectedColor: $selectedColor,
                        selectedPatternColor: $selectedPatternColor
                    )

                    PatternPickerRow(
                        selectedPattern: $selectedCoverPattern,
                        selectedColor: $selectedColor,
                        selectedPatternColor: $selectedPatternColor
                    )

                    PatternColorPickerRow(
                        colors: coverColors,
                        selectedPatternColor: $selectedPatternColor
                    )
                }
            }

            TabBarView(selectedTab: .constant(0))
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}

// MARK: - Cover Pattern View
struct CoverPatternView: View {
    let pattern: CoverPattern
    let baseColor: Color
    let patternColor: Color
    var isThumbnail: Bool = false

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(baseColor)
                )
                switch pattern {
                case .plain:
                    break
                case .striped:
                    let stripeWidth: CGFloat = isThumbnail ? 8 : 20
                    let gapWidth: CGFloat = isThumbnail ? 7 : 18
                    let total = stripeWidth + gapWidth
                    let count = Int(size.width / total) + 2
                    for i in 0..<count {
                        let x = CGFloat(i) * total
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(path, with: .color(patternColor.opacity(0.85)), lineWidth: stripeWidth)
                    }
                case .checkered:
                    let cellSize: CGFloat = isThumbnail ? 10 : 24
                    var row = 0
                    var y: CGFloat = 0
                    while y < size.height {
                        var col = 0
                        var x: CGFloat = 0
                        while x < size.width {
                            if (row + col) % 2 == 0 {
                                context.fill(Path(CGRect(x: x, y: y, width: cellSize, height: cellSize)), with: .color(patternColor.opacity(0.75)))
                            }
                            x += cellSize
                            col += 1
                        }
                        y += cellSize
                        row += 1
                    }
                case .dotted:
                    let spacing: CGFloat = isThumbnail ? 9 : 22
                    let dotSize: CGFloat = isThumbnail ? 2.5 : 6
                    var y: CGFloat = spacing
                    while y < size.height {
                        var x: CGFloat = spacing
                        while x < size.width {
                            let rect = CGRect(x: x - dotSize/2, y: y - dotSize/2, width: dotSize, height: dotSize)
                            context.fill(Path(ellipseIn: rect), with: .color(patternColor.opacity(0.85)))
                            x += spacing
                        }
                        y += spacing
                    }
                }
            }
        }
    }
}

// MARK: - Cover Pattern Thumbnail
struct CoverPatternThumbnail: View {
    let pattern: CoverPattern
    let baseColor: Color
    let patternColor: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            CoverPatternView(
                pattern: pattern,
                baseColor: baseColor,
                patternColor: patternColor,
                isThumbnail: true
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))

            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected ? Color(hex: "2C2820") : Color.white.opacity(0.4),
                    lineWidth: isSelected ? 2.5 : 1
                )
        }
        .frame(width: 70, height: 50)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
struct EditCoverView_Previews: PreviewProvider {
    static var previews: some View {
        let journal = Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        )
        EditCoverView(journal: journal, settings: JournalSettings(journal: journal))
    }
}
