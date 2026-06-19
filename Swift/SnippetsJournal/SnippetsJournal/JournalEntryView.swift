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

// MARK: - Placed Photo (on canvas)
struct PlacedPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Double = -4.0
}

// MARK: - Journal Entry View
struct JournalEntryView: View {
    let journal: Journal
    @ObservedObject var settings: JournalSettings
    var preloadedImage: UIImage? = nil
    var initialPage: Int = 0
    @Environment(\.dismiss) var dismiss

    @State private var selectedColor: Color = Color(hex: "000000")
    @State private var showTools = false
    @State private var selectedCategory: ToolCategory = .pens
    @State private var selectedPen: PenTool = .ink
    @State private var penSize: Double = 16
    @State private var isEditing = false
    @State private var currentPage = 0
    @State private var showEmotionView = false
    @State private var didPlacePreloaded = false

    var totalPages: Int { settings.pages.count }

    let paletteColors: [Color] = [
        Color(hex: "7A4A30"), Color(hex: "1D3B5B"), Color(hex: "7C2A36"),
        Color(hex: "306A50"), Color(hex: "000000"), Color(hex: "C7956F"),
        Color(hex: "C7A753"), Color(hex: "90AF8B"), Color(hex: "9F785C"),
        Color(hex: "2C2820"), Color(hex: "AF80C6"), Color(hex: "DE7B59"),
        Color(hex: "7B8C6F"), Color(hex: "D3A5A1"), Color(hex: "D8C9E7"),
        Color(hex: "E7C755"), Color(hex: "EAE0CF"), Color(hex: "F0D8D1"),
        Color(hex: "C9DFC9"), Color(hex: "FFFFFF"),
    ]

    var page: JournalPage {
        settings.pages[currentPage]
    }

    var hintTextColor: Color {
        let uiColor = UIColor(page.backgroundColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.55
            ? Color(hex: "C8B8A8")
            : Color.white.opacity(0.65)
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(hex: "FFFFFF"), Color(hex: "FDE0BC")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
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
                        Button(action: { showEmotionView = true }) {
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

                    // MARK: Page Canvas — edits settings.pages[currentPage] directly
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(page.backgroundColor)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                        PagePatternView(pattern: settings.pagePattern)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        if isEditing || !page.text.isEmpty {
                            TextEditor(text: $settings.pages[currentPage].text)
                                .font(.custom(page.fontName, size: page.fontSize))
                                .foregroundColor(page.textColor)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .padding(16)
                                .frame(height: 420)
                        } else if page.photos.isEmpty {
                            Text("Click Tools to edit page")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(hintTextColor)
                                .padding(.top, 20)
                                .padding(.leading, 20)
                        }

                        ForEach($settings.pages[currentPage].photos) { photo in
                            PlacedPhotoView(photo: photo) {
                                settings.pages[currentPage].photos.removeAll { $0.id == photo.id }
                            }
                        }

                        ForEach($settings.pages[currentPage].tapes) { tape in
                            PlacedTapeView(tape: tape) {
                                settings.pages[currentPage].tapes.removeAll { $0.id == tape.id }
                            }
                        }

                        ForEach($settings.pages[currentPage].stickers) { sticker in
                            PlacedStickerView(sticker: sticker) {
                                settings.pages[currentPage].stickers.removeAll { $0.id == sticker.id }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 570)
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }

                    // MARK: Page Navigation + Tools
                    HStack(spacing: 0) {
                        Button(action: {
                            if currentPage > 0 {
                                isEditing = false
                                currentPage -= 1
                            }
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

                        VStack(spacing: 4) {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showTools.toggle()
                                }
                            }) {
                                Text("Tools")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(showTools ? .white : Color(hex: "2C2820"))
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(showTools
                                                  ? Color(hex: "2C2820")
                                                  : Color(hex: "FDF3D2"))
                                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    )
                            }
                            Text("Page \(currentPage + 1) of \(totalPages)")
                                .font(.system(size: 11, weight: .light))
                                .foregroundColor(Color(hex: "A89072"))
                        }

                        Spacer()

                        Button(action: {
                            if currentPage < totalPages - 1 {
                                isEditing = false
                                currentPage += 1
                            }
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

                    // MARK: Tools Panel or Colour Palette
                    if showTools {
                        ToolsPanelView(
                            selectedCategory: $selectedCategory,
                            selectedPen: $selectedPen,
                            penSize: $penSize,
                            selectedColor: $selectedColor,
                            paletteColors: paletteColors,
                            onColorSelected: { color in
                                selectedColor = color
                                settings.pages[currentPage].textColor = color
                                isEditing = true
                            },
                            onImageSelected: { image in
                                addPhoto(image)
                            },
                            onStickerSelected: { emoji in
                                let center = CGPoint(x: 175, y: 210)
                                let randomOffset = CGPoint(
                                    x: CGFloat.random(in: -60...60),
                                    y: CGFloat.random(in: -80...80)
                                )
                                settings.pages[currentPage].stickers.append(PlacedSticker(
                                    emoji: emoji,
                                    position: CGPoint(
                                        x: center.x + randomOffset.x,
                                        y: center.y + randomOffset.y
                                    ),
                                    rotation: Double.random(in: -15...15)
                                ))
                            },
                            onTapeSelected: { style in
                                let center = CGPoint(x: 175, y: 210)
                                let randomOffset = CGPoint(
                                    x: CGFloat.random(in: -40...40),
                                    y: CGFloat.random(in: -80...80)
                                )
                                settings.pages[currentPage].tapes.append(PlacedTape(
                                    style: style,
                                    position: CGPoint(
                                        x: center.x + randomOffset.x,
                                        y: center.y + randomOffset.y
                                    ),
                                    rotation: Double.random(in: -8...8)
                                ))
                            },
                            onClose: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showTools = false
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(paletteColors, id: \.self) { color in
                                    Button(action: {
                                        withAnimation {
                                            settings.pages[currentPage].backgroundColor = color
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
                                            if page.backgroundColor == color {
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

                    Spacer().frame(height: 40)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            if preloadedImage != nil {
                currentPage = firstEmptyPage()  // photo goes to first empty page
            } else {
                currentPage = min(max(initialPage, 0), settings.pages.count - 1)
            }
            if let img = preloadedImage, !didPlacePreloaded {
                settings.pages[currentPage].photos.append(PlacedPhoto(
                    image: img,
                    position: CGPoint(x: 175, y: 200)
                ))
                didPlacePreloaded = true
            }
        }
        .onChange(of: selectedPen) { newPen in
            settings.pages[currentPage].fontName = newPen.fontName
        }
        .onChange(of: penSize) { newSize in
            settings.pages[currentPage].fontSize = newSize
        }
        .navigationDestination(isPresented: $showEmotionView) {
            EmotionView(journal: journal, settings: settings)
        }
    }

    func firstEmptyPage() -> Int {
            for (i, page) in settings.pages.enumerated() {
                if page.isEmpty { return i }
            }
            return 0  // fallback to page 1 if none are empty
        }

    func addPhoto(_ image: UIImage) {
        let center = CGPoint(x: 175, y: 200)
        let randomOffset = CGPoint(
            x: CGFloat.random(in: -20...20),
            y: CGFloat.random(in: -30...30)
        )
        settings.pages[currentPage].photos.append(PlacedPhoto(
            image: image,
            position: CGPoint(
                x: center.x + randomOffset.x,
                y: center.y + randomOffset.y
            ),
            rotation: Double.random(in: -6...6)
        ))
    }
}

// MARK: - Placed Photo View (draggable + deletable)
struct PlacedPhotoView: View {
    @Binding var photo: PlacedPhoto
    var onRemove: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                .scaleEffect(photo.scale)
                .rotationEffect(.degrees(photo.rotation))

            if showDelete {
                Button(action: { onRemove() }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "2C2820"))
                            .frame(width: 24, height: 24)
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 10, y: -10)
            }
        }
        .position(
            x: photo.position.x + dragOffset.width,
            y: photo.position.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    showDelete = false
                }
                .onEnded { value in
                    photo.position = CGPoint(
                        x: photo.position.x + value.translation.width,
                        y: photo.position.y + value.translation.height
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

// MARK: - Tools Panel
struct ToolsPanelView: View {
    @Binding var selectedCategory: ToolCategory
    @Binding var selectedPen: PenTool
    @Binding var penSize: Double
    @Binding var selectedColor: Color
    let paletteColors: [Color]
    let onColorSelected: (Color) -> Void
    let onImageSelected: (UIImage) -> Void
    let onStickerSelected: (String) -> Void
    let onTapeSelected: (TapeStyle) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {

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

            Rectangle()
                .fill(Color(hex: "E8DDD0"))
                .frame(height: 1)
                .padding(.horizontal, 16)

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
                    TapeContentView(onTapeSelected: onTapeSelected)
                case .stickers:
                    StickersContentView(onStickerSelected: onStickerSelected)
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
                                .fill(selectedPen == pen ? Color.white : Color.clear)
                                .shadow(color: selectedPen == pen
                                        ? .black.opacity(0.06) : .clear,
                                        radius: 4, x: 0, y: 2)
                        )
                    }
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

            Text("The quick brown fox")
                .font(.custom(selectedPen.fontName, size: penSize))
                .foregroundColor(selectedColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 20)
                .frame(height: 36)

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

// MARK: - Placeholder Tool
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

            Rectangle()
                .fill(Color(hex: "E8DDD0"))
                .frame(width: 1, height: 60)

            Button(action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    imageSource = .camera
                    showCamera = true
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

// MARK: - Image Picker
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
        init(_ parent: ImagePickerView) { self.parent = parent }

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
        JournalEntryView(
            journal: journal,
            settings: JournalSettings(journal: journal),
            preloadedImage: nil
        )
    }
}
