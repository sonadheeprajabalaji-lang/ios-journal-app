import SwiftUI

struct MockCameraView: View {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    // Sample images to cycle through — uses SF Symbols as placeholder
    // Replace these with real photo assets if you have them
    @State private var currentImageIndex = 0
    @State private var isCapturing = false
    @State private var flashOpacity = 0.0
    
    // Add your own sample images to Assets.xcassets
    // named: sample1, sample2, sample3 etc
    // If not found, we use a gradient placeholder
    let sampleImageNames = ["sample1", "sample2", "sample3"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Camera viewfinder area
                ZStack {
                    // Viewfinder background
                    if let uiImage = UIImage(named: sampleImageNames[currentImageIndex]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.65)
                            .clipped()
                    } else {
                        // Placeholder gradient if no sample images
                        LinearGradient(
                            colors: [
                                Color(hex: "FFEFDB"),
                                Color(hex: "FDE0BC"),
                                Color(hex: "C8A882")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.65)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 60, weight: .ultraLight))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Point at something beautiful")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        )
                    }
                    
                    // Flash overlay
                    Color.white
                        .opacity(flashOpacity)
                        .ignoresSafeArea()
                    
                    // Top controls
                    VStack {
                        HStack {
                            // Close button
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Swap image button (simulates moving camera)
                            Button(action: swapImage) {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Focus indicator
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.yellow.opacity(0.8), lineWidth: 1.5)
                            .frame(width: 80, height: 80)
                            .padding(.bottom, 20)
                    }
                }
                
                // MARK: Camera controls bar
                ZStack {
                    Color(hex: "FDF8F2")
                    
                    HStack {
                        // Thumbnail of last captured (placeholder)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "EDE0D0"))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(Color(hex: "A89072"))
                            )
                        
                        Spacer()
                        
                        // Shutter button
                        Button(action: capturePhoto) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 72, height: 72)
                                    .shadow(color: .black.opacity(0.15), radius: 4)
                                
                                Circle()
                                    .stroke(Color(hex: "2C2820").opacity(0.3), lineWidth: 3)
                                    .frame(width: 80, height: 80)
                                
                                if isCapturing {
                                    Circle()
                                        .fill(Color(hex: "C8624A").opacity(0.3))
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        .disabled(isCapturing)
                        
                        Spacer()
                        
                        // Swap view button
                        Button(action: swapImage) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "EDE0D0"))
                                .frame(width: 52, height: 52)
                                .overlay(
                                    Image(systemName: "arrow.left.arrow.right")
                                        .foregroundColor(Color(hex: "A89072"))
                                )
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .frame(height: UIScreen.main.bounds.height * 0.18)
            }
        }
        .ignoresSafeArea()
    }
    
    func swapImage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentImageIndex = (currentImageIndex + 1) % max(sampleImageNames.count, 1)
        }
    }
    
    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true
        
        // Flash effect
        withAnimation(.easeIn(duration: 0.1)) {
            flashOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
            flashOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Get the current image or create a placeholder
            let image = UIImage(named: sampleImageNames[currentImageIndex])
                ?? createPlaceholderImage()
            onImageCaptured(image)
            isCapturing = false
            dismiss()
        }
    }
    
    // Creates a simple gradient image as placeholder
    func createPlaceholderImage() -> UIImage {
        let size = CGSize(width: 400, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let colors = [
                UIColor(red: 1.0, green: 0.94, blue: 0.87, alpha: 1.0),
                UIColor(red: 0.99, green: 0.88, blue: 0.74, alpha: 1.0)
            ]
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: [0, 1]
            )!
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
    }
}

// MARK: - Preview
struct MockCameraView_Previews: PreviewProvider {
    static var previews: some View {
        MockCameraView(onImageCaptured: { _ in })
    }
}
