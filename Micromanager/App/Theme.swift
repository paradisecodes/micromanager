import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }

    // Surfaces
    static let dsBackground = Color(hex: "F7F6FB")
    static let dsCard = Color.white
    static let dsChrome = Color(hex: "15142B")
    static let dsDivider = Color(hex: "E5E3EF")
    static let dsTint = Color(hex: "EEEDF7")
    static let dsTintAlt = Color(hex: "F1F0F6")
    static let dsTrack = Color(hex: "DFDDEC")
    static let dsDashedBorder = Color(hex: "B4B1D2")
    static let dsChevron = Color(hex: "C4C1D8")

    // Text
    static let dsTextPrimary = Color(hex: "15142B")
    static let dsTextSecondary = Color(hex: "6E6B85")
    static let dsTextTertiary = Color(hex: "8B88A3")

    // Brand
    static let dsIndigo = Color(hex: "2E2C6E")
    static let dsIndigoLight = Color(hex: "6C69C9")
    static let dsIndigoPale = Color(hex: "9C9AD9")
    static let dsMint = Color(hex: "8FE3C4")
    static let dsOnIndigoSecondary = Color(hex: "BDBBE4")
    static let dsOnIndigoTertiary = Color(hex: "A7A4D6")

    // Default category palette
    static let dsCategoryWork = dsIndigo
    static let dsCategoryFamily = Color(hex: "C8663F")
    static let dsCategoryPersonal = Color(hex: "4F8A7B")
    static let dsCategoryHealth = Color(hex: "B08A2E")
    static let dsCategorySleep = Color(hex: "4A4A68")
    static let dsCategoryUntracked = Color(hex: "9B9B9B")
}

extension Font {
    static func dsRegular(_ size: CGFloat) -> Font { .custom("InstrumentSans-Regular", size: size) }
    static func dsMedium(_ size: CGFloat) -> Font { .custom("InstrumentSans-Medium", size: size) }
    static func dsSemiBold(_ size: CGFloat) -> Font { .custom("InstrumentSans-SemiBold", size: size) }
    static func dsBold(_ size: CGFloat) -> Font { .custom("InstrumentSans-Bold", size: size) }
}

/// Card container matching the mockups' white rounded panels with a soft shadow.
struct DSCard<Content: View>: View {
    var padding: CGFloat = 18
    var cornerRadius: CGFloat = 22
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(padding)
            .background(Color.dsCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.dsChrome.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct DSPrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.dsSemiBold(17))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.dsIndigo)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
