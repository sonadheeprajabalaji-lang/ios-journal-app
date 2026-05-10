import SwiftUI

struct JournalEntryView: View {
    let journal: Journal
    @Environment(\.dismiss) var dismiss
    @State private var selectedColor: Color = Color(hex: "000000")
    @State private var currentPage = 0
    let totalPages = 6

    let paletteColors: [Color] = [
        Color(hex: "7A4A30"),
        Color(hex: "1D3B5B"),
        Color(hex: "7C2A36"),
        Color(hex: "306A50"),
        Color(hex: "000000"),
        Color(hex: "C7956F"),
        Color(hex: "C7A753"),
        Color(hex: "90AF8B"),
        Color(hex: "9F785C"),
        Color(hex: "2C2820"),
        Color(hex: "AF80C6"),
        Color(hex: "DE7B59"),
        Color(hex: "7B8C6F"),
        Color(hex: "D3A5A1"),
        Color(hex: "D8C9E7"),
        Color(hex: "E7C755"),
        Color(hex: "EAE0CF"),
        Color(hex: "F0D8D1"),
        Color(hex: "C9DFC9"),
        Color(hex: "FFFFFF"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Background
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

                        Text(journal.title.replacingOccurrences(of: "\n", with: " "))
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
                    .padding(.top, 40)
                    .padding(.bottom, 28)

                    // MARK: Page Canvas
                    ZStack(alignment: .bottomLeading) {
                        // Page background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                        // Hint text
                        VStack {
                            Text("Click Tools to edit page")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(Color(hex: "C8B8A8"))
                                .padding(.top, 20)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)

                        // Bottom left prompt icon
                        Button(action: {}) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "F5F0EA"))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "C8B8A8"))
                            }
                        }
                        .padding(12)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxHeight: .infinity)

                    // MARK: Tools Navigation
                    HStack(spacing: 0) {
                        // Previous page
                        Button(action: {
                            if currentPage > 0 { currentPage -= 1 }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEFAF4"))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "2C2820"))
                            }
                        }

                        Spacer()

                        // Tools button
                        Button(action: {}) {
                            Text("Tools")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "FDF3D2"))
                                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                )
                        }

                        Spacer()

                        // Next page
                        Button(action: {
                            if currentPage < totalPages - 1 { currentPage += 1 }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEFAF4"))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "2C2820"))
                            }
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.vertical, 14)

                    // MARK: Colour Palette
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(paletteColors, id: \.self) { color in
                                Button(action: {
                                    selectedColor = color
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 30, height: 30)

                                        // White border for white swatch
                                        if color == Color(hex: "FFFFFF") {
                                            Circle()
                                                .stroke(Color(hex: "E0D8D0"), lineWidth: 1)
                                                .frame(width: 30, height: 30)
                                        }

                                        // Selection ring
                                        if selectedColor == color {
                                            Circle()
                                                .stroke(Color(hex: "2C2820"), lineWidth: 2)
                                                .frame(width: 36, height: 36)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    .background(Color(hex: "FEFAF4").opacity(0.6))
                    .padding(.bottom, 8)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryView(journal: Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        ))
    }
}
