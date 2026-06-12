import SwiftUI

struct JournalPickerView: View {
    let image: UIImage
    @EnvironmentObject var store: JournalStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedJournal: Journal? = nil
    @State private var isSaved = false
    @State private var navigateToEntry = false

    // Single source of truth — stable IDs, so selection always matches
    var journals: [Journal] { store.journals }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "FFFFFF"), Color(hex: "FDE0BC")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Choose a Journal")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(hex: "2C2820"))
                            Text("to save your image")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color(hex: "2C2820"))
                        }

                        Spacer()

                        Text("\(journals.count) journals")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "5A4A39"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FEFAF4"))
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)

                    Spacer()

                    // MARK: Bookshelf
                    ZStack(alignment: .bottom) {
                        HStack(alignment: .bottom, spacing: 24) {
                            ForEach(journals) { journal in
                                let isSelected = selectedJournal?.id == journal.id
                                BookSpineView(
                                    journal: journal,
                                    isSelected: isSelected,
                                    width: 80
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedJournal = journal
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .frame(height: 340, alignment: .bottom)

                        // Shelf
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(hex: "A0714F"))
                                .frame(height: 4)
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "7B4F2E"), Color(hex: "5C3A1E")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 20)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 380)

                    Spacer()

                    // MARK: Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<journals.count, id: \.self) { index in
                            let isSelected = journals[index].id == selectedJournal?.id
                            Capsule()
                                .fill(isSelected
                                      ? Color(hex: "2C2820")
                                      : Color(hex: "C8B8A8"))
                                .frame(width: isSelected ? 20 : 8, height: 8)
                                .animation(.spring(), value: selectedJournal?.id)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 52)

                    // MARK: Save button
                    if selectedJournal != nil {
                        Button(action: saveToJournal) {
                            HStack {
                                Spacer()
                                Text(isSaved ? "Saved! ✓" : "Save to Journal")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isSaved
                                          ? Color(hex: "7A8C6E")
                                          : Color(hex: "2C2820"))
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.4), value: selectedJournal?.id)
                    }

                    TabBarView(selectedTab: .constant(1))
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .onDisappear { isSaved = false }
            .navigationDestination(isPresented: $navigateToEntry) {
                if let journal = selectedJournal {
                    JournalEntryView(
                        journal: journal,
                        settings: store.settings(for: journal),
                        preloadedImage: image.size == .zero ? nil : image
                    )
                    .environmentObject(store)
                }
            }
        }
        .environmentObject(store)
    }

    func saveToJournal() {
        guard !isSaved, selectedJournal != nil else { return }
        withAnimation { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            navigateToEntry = true
        }
    }
}

// MARK: - Book Spine View
struct BookSpineView: View {
    let journal: Journal
    let isSelected: Bool
    let width: CGFloat

    var spineTitle: String {
        journal.title.replacingOccurrences(of: "\n", with: " ")
    }

    var spineHeight: CGFloat { isSelected ? 320 : 290 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(journal.coverColor)

            Image("journalTexture")
                .resizable()
                .blendMode(.softLight)
                .opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.8), lineWidth: 2.5)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(isSelected ? 0.25 : 0.12))
                    .frame(width: width - 20, height: 200)

                Text(spineTitle)
                    .font(.custom("PatrickHand-Regular", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
                    .rotationEffect(.degrees(-90))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: width, height: spineHeight)
        .shadow(
            color: journal.coverColor.opacity(isSelected ? 0.6 : 0.2),
            radius: isSelected ? 18 : 6,
            x: 0, y: isSelected ? 10 : 3
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
struct JournalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        JournalPickerView(image: UIImage())
            .environmentObject(JournalStore())
    }
}
