import SwiftUI

struct LibraryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: JournalStore
    @State private var selectedTab = 2
    @State private var selectedJournal: Journal? = nil
    @State private var showEmotionArt = false
    @State private var isFavourited = false

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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FFFFFF"), Color(hex: "FDE0BC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "2C2820"))
                        Text("Journals")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "2C2820"))
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Text("\(journals.count) journals")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "5A4A39"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "A89072"))
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "C7A753"), lineWidth: 1)
                            )

                        Button(action: { showEmotionArt = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FEFAF4"))
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "C7A753"), lineWidth: 1)
                                    )
                                Image(systemName: isFavourited ? "heart.fill" : "heart")
                                    .font(.system(size: 18))
                                    .foregroundColor(isFavourited
                                                     ? Color(hex: "C8624A")
                                                     : Color(hex: "2C2820"))
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)

                Spacer()

                // MARK: Bookshelf
                ZStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 60) {
                        ForEach(journals) { journal in
                            let isSelected = selectedJournal?.id == journal.id
                            NavigationLink {
                                JournalView(
                                    journal: journal,
                                    settings: store.settings(for: journal)
                                )
                            } label: {
                                LibrarySpineView(journal: journal, isSelected: isSelected)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedJournal = journal
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)

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
                .frame(height: 500)

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
                .padding(.vertical, 16)

                TabBarView(selectedTab: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        // Navigate to emotion art
        .navigationDestination(isPresented: $showEmotionArt) {
            EmotionArtView()
        }
        .onChange(of: selectedTab) { newValue in
            switch newValue {
            case 0:
                dismiss()
            case 1:
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavigateToPrompt"),
                        object: nil
                    )
                }
            default:
                break
            }
        }
    }
}

// MARK: - Library Spine View
struct LibrarySpineView: View {
    let journal: Journal
    var isSelected: Bool = false  // ← add this

    var spineTitle: String {
        journal.title.replacingOccurrences(of: "\n", with: " ")
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(journal.coverColor)

            Image("journalTexture")
                .resizable()
                .blendMode(.softLight)
                .opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // Selection highlight
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.7), lineWidth: 2)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
            }

            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(isSelected ? 0.25 : 0.15))
                    .frame(width: 55, height: 300)

                Text(spineTitle)
                    .font(.custom("PatrickHand-Regular", size: 50))
                    .foregroundColor(Color(hex: "2C2820"))
                    .multilineTextAlignment(.center)
                    .frame(width: 130)
                    .rotationEffect(.degrees(-90))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            }
        }
        .frame(width: 80, height: isSelected ? 470 : 440)  // ← rises when selected
        .shadow(
            color: journal.coverColor.opacity(isSelected ? 0.5 : 0.3),
            radius: isSelected ? 16 : 8,
            x: 0, y: isSelected ? 10 : 4
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)  // ← slight scale up
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(JournalStore())
    }
}
