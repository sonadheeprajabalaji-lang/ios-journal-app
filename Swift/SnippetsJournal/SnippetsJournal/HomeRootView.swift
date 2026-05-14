import SwiftUI

struct HomeRootView: View {
    var openPromptOnAppear: Bool = false
        @EnvironmentObject var store: JournalStore
        @State private var path = NavigationPath()

        var body: some View {
            NavigationStack(path: $path) {
                HomeView(openPromptOnAppear: openPromptOnAppear)
            }
            .onReceive(store.$shouldPopToHome) { should in
                if should {
                    path = NavigationPath()  // ← clears entire nav stack instantly
                    store.shouldPopToHome = false
                }
            }
        }
}

struct HomeRootView_Previews: PreviewProvider {
    static var previews: some View {
        HomeRootView()
            .environmentObject(JournalStore())
    }
}
