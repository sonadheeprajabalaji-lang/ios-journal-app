import SwiftUI

// MARK: - Journal Settings (per journal)
class JournalSettings: ObservableObject {
    @Published var coverColor: Color
    @Published var patternColor: Color
    @Published var coverPattern: CoverPattern
    @Published var pagePattern: PagePattern
    @Published var title: String
    @Published var emotionLog: [String] = []

    init(journal: Journal) {
        self.coverColor = journal.coverColor
        self.patternColor = journal.stripeColor
        self.coverPattern = .striped
        self.pagePattern = .plain
        self.title = journal.title.replacingOccurrences(of: "\n", with: " ")
    }
}

// MARK: - Journal Store
class JournalStore: ObservableObject {
    @Published var shouldPopToHome = false
    @Published var shouldNavigateToPrompt = false

    @Published var journals: [Journal] = [
        Journal(title: "Vacation\nJournal",
                coverColor: Color(hex: "7B9BB5"), stripeColor: Color(hex: "6A8BA4")),
        Journal(title: "Gratitude\nJournal",
                coverColor: Color(hex: "C8624A"), stripeColor: Color(hex: "B8927A")),
        Journal(title: "Prompt\nJournal",
                coverColor: Color(hex: "7A8C6E"), stripeColor: Color(hex: "8A9C7E"))
    ]

    private var settingsMap: [UUID: JournalSettings] = [:]

    init() {
        for journal in journals {
            settingsMap[journal.id] = JournalSettings(journal: journal)
        }
    }

    func settings(for journal: Journal) -> JournalSettings {
        if let existing = settingsMap[journal.id] { return existing }
        let s = JournalSettings(journal: journal)
        settingsMap[journal.id] = s
        return s
    }

    var allSettings: [JournalSettings] { Array(settingsMap.values) }
}
