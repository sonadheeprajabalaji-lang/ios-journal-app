import SwiftUI

// MARK: - Sticker Model
struct Sticker: Identifiable {
    let id = UUID()
    let emoji: String
    let label: String
}

// MARK: - Tape Style
struct TapeStyle: Identifiable {
    let id = UUID()
    let color: Color
    let patternColor: Color
    let label: String
    let isHorizontal: Bool
}

// MARK: - Placed Sticker (on canvas)
struct PlacedSticker: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Double = 0.0
}

// MARK: - Placed Tape (on canvas)
struct PlacedTape: Identifiable {
    let id = UUID()
    let style: TapeStyle
    var position: CGPoint
    var rotation: Double = 0.0
}

// MARK: - Stickers Content View
struct StickersContentView: View {
    let onStickerSelected: (String) -> Void

    let stickerCategories: [(String, [Sticker])] = [
        ("Nature", [
            Sticker(emoji: "🌸", label: "Cherry Blossom"),
            Sticker(emoji: "🌿", label: "Herb"),
            Sticker(emoji: "🍃", label: "Leaf"),
            Sticker(emoji: "🌻", label: "Sunflower"),
            Sticker(emoji: "🌙", label: "Moon"),
            Sticker(emoji: "⭐️", label: "Star"),
            Sticker(emoji: "🌈", label: "Rainbow"),
            Sticker(emoji: "☁️", label: "Cloud"),
            Sticker(emoji: "🍂", label: "Fallen Leaf"),
            Sticker(emoji: "🌊", label: "Wave"),
            Sticker(emoji: "🦋", label: "Butterfly"),
            Sticker(emoji: "🌺", label: "Hibiscus"),
        ]),
        ("Mood", [
            Sticker(emoji: "✨", label: "Sparkles"),
            Sticker(emoji: "💫", label: "Dizzy"),
            Sticker(emoji: "🎀", label: "Ribbon"),
            Sticker(emoji: "💌", label: "Love Letter"),
            Sticker(emoji: "🕯️", label: "Candle"),
            Sticker(emoji: "📚", label: "Books"),
            Sticker(emoji: "☕️", label: "Coffee"),
            Sticker(emoji: "🎵", label: "Music"),
            Sticker(emoji: "🌙", label: "Night"),
            Sticker(emoji: "💭", label: "Thought"),
            Sticker(emoji: "🫶", label: "Heart Hands"),
            Sticker(emoji: "🌷", label: "Tulip"),
        ]),
        ("Fun", [
            Sticker(emoji: "🎪", label: "Circus"),
            Sticker(emoji: "🎨", label: "Art"),
            Sticker(emoji: "🎭", label: "Theatre"),
            Sticker(emoji: "🎠", label: "Carousel"),
            Sticker(emoji: "🧸", label: "Teddy Bear"),
            Sticker(emoji: "🪄", label: "Magic"),
            Sticker(emoji: "🎪", label: "Tent"),
            Sticker(emoji: "🧁", label: "Cupcake"),
            Sticker(emoji: "🍰", label: "Cake"),
            Sticker(emoji: "🎁", label: "Gift"),
            Sticker(emoji: "🪁", label: "Kite"),
            Sticker(emoji: "🎈", label: "Balloon"),
        ]),
    ]

    @State private var selectedCategory = 0

    var body: some View {
        VStack(spacing: 0) {
            // Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(stickerCategories.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = index
                            }
                        }) {
                            Text(stickerCategories[index].0)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedCategory == index
                                                 ? Color(hex: "2C2820")
                                                 : Color(hex: "A89072"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == index
                                              ? Color(hex: "FDF3D2")
                                              : Color.clear)
                                )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            // Sticker grid
            let stickers = stickerCategories[selectedCategory].1
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(stickers) { sticker in
                    Button(action: {
                        onStickerSelected(sticker.emoji)
                    }) {
                        Text(sticker.emoji)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "F5F0EA"))
                            )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Tape Content View
struct TapeContentView: View {
    let onTapeSelected: (TapeStyle) -> Void

    let tapeStyles: [TapeStyle] = [
        TapeStyle(
            color: Color(hex: "C7A753"),
            patternColor: Color(hex: "B8922E"),
            label: "Gold Stripe",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "D3A5A1"),
            patternColor: Color(hex: "C48480"),
            label: "Rose",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "90AF8B"),
            patternColor: Color(hex: "7A9B74"),
            label: "Sage",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "D8C9E7"),
            patternColor: Color(hex: "B8A0D0"),
            label: "Lavender",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "7B9BB5"),
            patternColor: Color(hex: "5A7A94"),
            label: "Blue",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "EAE0CF"),
            patternColor: Color(hex: "C8B898"),
            label: "Linen",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "C8624A"),
            patternColor: Color(hex: "A84030"),
            label: "Terracotta",
            isHorizontal: true
        ),
        TapeStyle(
            color: Color(hex: "E7C755"),
            patternColor: Color(hex: "C8A830"),
            label: "Honey",
            isHorizontal: true
        ),
    ]

    var body: some View {
        VStack(spacing: 8) {
            Text("Tap a tape to add it to the page")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(hex: "A89072"))
                .padding(.top, 8)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 2),
                spacing: 12
            ) {
                ForEach(tapeStyles) { style in
                    Button(action: {
                        onTapeSelected(style)
                    }) {
                        TapePreviewView(style: style)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Tape Preview View
struct TapePreviewView: View {
    let style: TapeStyle

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "F5F0EA"))
                .frame(height: 56)

            // Tape strip preview
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(style.color.opacity(0.85))
                    .frame(width: 120, height: 22)

                // Stripe pattern on tape
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
                            with: .color(style.patternColor.opacity(0.35)),
                            lineWidth: stripeWidth
                        )
                    }
                }
                .frame(width: 120, height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .rotationEffect(.degrees(-2))

            // Label
            VStack {
                Spacer()
                Text(style.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "8C7B6B"))
                    .padding(.bottom, 4)
            }
        }
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "E0D8D0"), lineWidth: 1)
        )
    }
}

// MARK: - Placed Sticker View (draggable)
struct PlacedStickerView: View {
    @Binding var sticker: PlacedSticker
    var onRemove: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(sticker.emoji)
                .font(.system(size: 48))
                .scaleEffect(sticker.scale)
                .rotationEffect(.degrees(sticker.rotation))

            // Delete button — shown on tap
            if showDelete {
                Button(action: { onRemove() }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "2C2820"))
                            .frame(width: 20, height: 20)
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 8, y: -8)
            }
        }
        .position(
            x: sticker.position.x + dragOffset.width,
            y: sticker.position.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    showDelete = false
                }
                .onEnded { value in
                    sticker.position = CGPoint(
                        x: sticker.position.x + value.translation.width,
                        y: sticker.position.y + value.translation.height
                    )
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                showDelete.toggle()
            }
        }
    }
}

// MARK: - Placed Tape View (draggable)
struct PlacedTapeView: View {
    @Binding var tape: PlacedTape
    var onRemove: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(tape.style.color.opacity(0.85))
                    .frame(width: 100, height: 24)

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
                            with: .color(tape.style.patternColor.opacity(0.35)),
                            lineWidth: stripeWidth
                        )
                    }
                }
                .frame(width: 100, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            .rotationEffect(.degrees(tape.rotation))

            // Delete button — shown on tap
            if showDelete {
                Button(action: { onRemove() }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "2C2820"))
                            .frame(width: 20, height: 20)
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 8, y: -8)
            }
        }
        .position(
            x: tape.position.x + dragOffset.width,
            y: tape.position.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    showDelete = false
                }
                .onEnded { value in
                    tape.position = CGPoint(
                        x: tape.position.x + value.translation.width,
                        y: tape.position.y + value.translation.height
                    )
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                showDelete.toggle()
            }
        }
    }
}
