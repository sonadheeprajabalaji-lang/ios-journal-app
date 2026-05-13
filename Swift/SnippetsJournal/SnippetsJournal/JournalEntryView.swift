import SwiftUI

// MARK: - Tool Types
enum PenTool: String, CaseIterable {
    case ink = "Ink"
    case marker = "Marker"
    case brush = "Brush"
    case spray = "Spray"

    var fontName: String {
        switch self {
        case .ink:    return "Zapfino"
        case .marker: return "Bradley Hand"
        case .brush:  return "Snell Roundhand"
        case .spray:  return "Chalkduster"
        }
    }

    var icon: String {
        switch self {
        case .ink:    return "pencil.tip"
        case .marker: return "pencil"
        case .brush:  return "paintbrush"
        case .spray:  return "airdrop"
        }
    }
}

enum ToolCategory: String, CaseIterable {
    case pens     = "Pens"
    case pictures = "Pictures"
    case tape     = "Tape"
    case stickers = "Stickers"
    case notes    = "Notes"
}

// MARK: - Journal Entry View
struct JournalEntryView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    @Environment(\.dismiss) var dismiss

    // Colour palette
    @State private var selectedColor: Color = Color(hex: "000000")

    // Page background (changed by palette when tools closed)
    @State private var pageBackgroundColor: Color = .white

    // Tools panel
    @State private var showTools = false
    @State private var selectedCategory: ToolCategory = .pens
    @State private var selectedPen: PenTool = .ink
    @State private var penSize: Double = 16
    @State private var selectedImage: UIImage? = nil

    // Text
    @State private var pageText: String = ""
    @State private var isEditing = false

    // Page navigation
    @State private var currentPage = 0
    let totalPages = 6

    let paletteColors: [Color] = [
        Color(hex: "7A4A30"), Color(hex: "1D3B5B"), Color(hex: "7C2A36"),
        Color(hex: "306A50"), Color(hex: "000000"), Color(hex: "C7956F"),
        Color(hex: "C7A753"), Color(hex: "90AF8B"), Color(hex: "9F785C"),
        Color(hex: "2C2820"), Color(hex: "AF80C6"), Color(hex: "DE7B59"),
        Color(hex: "7B8C6F"), Color(hex: "D3A5A1"), Color(hex: "D8C9E7"),
        Color(hex: "E7C755"), Color(hex: "EAE0CF"), Color(hex: "F0D8D1"),
        Color(hex: "C9DFC9"), Color(hex: "FFFFFF"),
    ]

    // Contrast hint text colour based on page background
    var hintTextColor: Color {
        let uiColor = UIColor(pageBackgroundColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.55
            ? Color(hex: "C8B8A8")
            : Color.white.opacity(0.65)
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

                VStack(spacing: 0) {

                    // MARK: Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                        }
                        Spacer()
                        Text(settings.title)
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
                    .padding(.bottom, 16)

                    // MARK: Page Canvas
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(pageBackgroundColor)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                        // Page pattern overlay
                        PagePatternView(pattern: settings.pagePattern)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Selected image overlay
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(16)
                        }
                        
                        // Text editing area
                        if isEditing || !pageText.isEmpty {
                            TextEditor(text: $pageText)
                                .font(.custom(selectedPen.fontName, size: penSize))
                                .foregroundColor(selectedColor)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .padding(16)
                        } else {
                            // Hint text
                            VStack {
                                Text("Click Tools to edit page")
                                    .font(.custom("Georgia", size: 14))
                                    .foregroundColor(hintTextColor)
                                    .padding(.top, 20)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Prompt bubble icon
                        Button(action: { isEditing = true }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 16))
                                    .foregroundColor(hintTextColor)
                            }
                        }
                        .padding(12)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: showTools ? 280 : 420)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showTools)

                    // MARK: Tools Navigation
                    HStack(spacing: 0) {
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

                        // Tools toggle button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showTools.toggle()
                            }
                        }) {
                            Text("Tools")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "2C2820"))
                                .padding(.horizontal, 28)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(showTools
                                              ? Color(hex: "2C2820")
                                              : Color(hex: "FDF3D2"))
                                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                )
                                .foregroundColor(showTools ? .white : Color(hex: "2C2820"))
                        }

                        Spacer()

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
                    .padding(.vertical, 12)

                    // MARK: Tools Panel (slides in when showTools = true)
                    if showTools {
                        ToolsPanelView(
                            selectedCategory: $selectedCategory,
                            selectedPen: $selectedPen,
                            penSize: $penSize,
                            selectedColor: $selectedColor,
                            paletteColors: paletteColors,
                            onColorSelected: { color in
                                selectedColor = color
                                isEditing = true
                            },
                            onImageSelected: { image in
                                selectedImage = image
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // MARK: Colour Palette (shown when tools closed)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(paletteColors, id: \.self) { color in
                                    Button(action: {
                                        // When tools closed, palette changes page background
                                        withAnimation {
                                            pageBackgroundColor = color
                                        }
                                        selectedColor = color
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 30, height: 30)
                                            if color == Color(hex: "FFFFFF") {
                                                Circle()
                                                    .stroke(Color(hex: "E0D8D0"), lineWidth: 1)
                                                    .frame(width: 30, height: 30)
                                            }
                                            if pageBackgroundColor == color {
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
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
    }
}

// MARK: - Tools Panel
struct ToolsPanelView: View {
    @Binding var selectedCategory: ToolCategory
    @Binding var selectedPen: PenTool
    @Binding var penSize: Double
    @Binding var selectedColor: Color
    let paletteColors: [Color]
    let onColorSelected: (Color) -> Void
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ToolCategory.allCases, id: \.self) { category in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedCategory == category
                                                 ? Color(hex: "2C2820")
                                                 : Color(hex: "A89072"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == category
                                              ? Color(hex: "FDF3D2")
                                              : Color.clear)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            // Divider
            Rectangle()
                .fill(Color(hex: "E8DDD0"))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // MARK: Category Content
            Group {
                switch selectedCategory {
                case .pens:
                    PensContentView(
                        selectedPen: $selectedPen,
                        penSize: $penSize,
                        selectedColor: $selectedColor,
                        paletteColors: paletteColors,
                        onColorSelected: onColorSelected
                    )
                case .pictures:
                    PicturesContentView(onImageSelected: onImageSelected)
                case .tape:
                    PlaceholderToolView(icon: "scissors", label: "Tape coming soon")
                case .stickers:
                    PlaceholderToolView(icon: "star", label: "Stickers coming soon")
                case .notes:
                    PlaceholderToolView(icon: "note.text", label: "Notes coming soon")
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "FDF8F2"))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Pens Content
struct PensContentView: View {
    @Binding var selectedPen: PenTool
    @Binding var penSize: Double
    @Binding var selectedColor: Color
    let paletteColors: [Color]
    let onColorSelected: (Color) -> Void

    var body: some View {
        VStack(spacing: 12) {

            // Pen type selector
            HStack(spacing: 0) {
                ForEach(PenTool.allCases, id: \.self) { pen in
                    Button(action: { selectedPen = pen }) {
                        VStack(spacing: 6) {
                            Image(systemName: pen.icon)
                                .font(.system(size: 20))
                                .foregroundColor(selectedPen == pen
                                                 ? Color(hex: "2C2820")
                                                 : Color(hex: "A89072"))

                            Text(pen.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedPen == pen
                                                 ? Color(hex: "2C2820")
                                                 : Color(hex: "A89072"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedPen == pen
                                      ? Color.white
                                      : Color.clear)
                                .shadow(color: selectedPen == pen
                                        ? .black.opacity(0.06) : .clear,
                                        radius: 4, x: 0, y: 2)
                        )
                    }

                    // Vertical divider between items
                    if pen != PenTool.allCases.last {
                        Rectangle()
                            .fill(Color(hex: "E8DDD0"))
                            .frame(width: 1, height: 36)
                    }
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "F0EAE0"))
            )
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Font preview
            Text("The quick brown fox")
                .font(.custom(selectedPen.fontName, size: penSize))
                .foregroundColor(selectedColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 20)
                .frame(height: 36)

            // Size slider
            HStack(spacing: 12) {
                Text("Size")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "5A4A39"))
                    .frame(width: 34, alignment: .leading)

                Slider(value: $penSize, in: 10...48, step: 1)
                    .accentColor(selectedColor == .white
                                 ? Color(hex: "2C2820")
                                 : selectedColor)
            }
            .padding(.horizontal, 16)

            // Colour palette
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(paletteColors, id: \.self) { color in
                        Button(action: { onColorSelected(color) }) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 28, height: 28)
                                if color == Color(hex: "FFFFFF") {
                                    Circle()
                                        .stroke(Color(hex: "E0D8D0"), lineWidth: 1)
                                        .frame(width: 28, height: 28)
                                }
                                if selectedColor == color {
                                    Circle()
                                        .stroke(Color(hex: "2C2820"), lineWidth: 2)
                                        .frame(width: 34, height: 34)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Placeholder for other tool categories
struct PlaceholderToolView: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "C8B8A8"))
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "C8B8A8"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - Pictures Content
struct PicturesContentView: View {
    let onImageSelected: (UIImage) -> Void
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        HStack(spacing: 0) {
            // Upload button
            Button(action: {
                imageSource = .photoLibrary
                showImagePicker = true
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(Color(hex: "2C2820"))
                    Text("Upload")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "2C2820"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

            // Divider
            Rectangle()
                .fill(Color(hex: "E8DDD0"))
                .frame(width: 1, height: 60)

            // Camera button
            Button(action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imageSource = .camera
                    showCamera = true
                }else {
                    // Camera not available (simulator)
                    print("Camera not available on this device")
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(Color(hex: "2C2820"))
                    Text("Camera")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "2C2820"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "FDF3D2"))
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary, onImagePicked: onImageSelected)
        }
        .sheet(isPresented: $showCamera) {
            ImagePickerView(sourceType: .camera, onImagePicked: onImageSelected)
        }
    }
}

// MARK: - Image Picker (UIKit wrapper)
struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
struct JournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let journal = Journal(
            title: "Gratitude\nJournal",
            coverColor: Color(hex: "C8624A"),
            stripeColor: Color(hex: "B8927A")
        )
        JournalEntryView(journal: journal, settings: JournalSettings(journal: journal))
    }
}
