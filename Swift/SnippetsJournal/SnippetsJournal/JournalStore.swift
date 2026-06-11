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
    @Published var settings: [UUID: JournalSettings] = [:]
    @Published var shouldPopToHome: Bool = false
    @Published var shouldNavigateToPrompt: Bool = false

    func settings(for journal: Journal) -> JournalSettings {
        if let existing = settings[journal.id] {
            return existing
        }
        let newSettings = JournalSettings(journal: journal)
        settings[journal.id] = newSettings
        return newSettings
    }
}
