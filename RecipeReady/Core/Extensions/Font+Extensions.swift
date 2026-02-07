import SwiftUI

extension Font {
    static func pangram(_ weight: PangramWeight = .regular, size: CGFloat) -> Font {
        return .custom(weight.rawValue, size: size)
    }

    enum PangramWeight: String {
        case black = "Pangram-Black"
        case bold = "Pangram-Bold"
        case extraBold = "Pangram-ExtraBold"
        case extraLight = "Pangram-ExtraLight"
        case light = "Pangram-Light"
        case medium = "Pangram-Medium"
        case regular = "Pangram-Regular"
    }
}

struct Font_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Pangram Black").font(.pangram(.black, size: 24))
                    Text("Pangram Bold").font(.pangram(.bold, size: 24))
                    Text("Pangram ExtraBold").font(.pangram(.extraBold, size: 24))
                    Text("Pangram Medium").font(.pangram(.medium, size: 24))
                    Text("Pangram Regular").font(.pangram(.regular, size: 24))
                    Text("Pangram Light").font(.pangram(.light, size: 24))
                    Text("Pangram ExtraLight").font(.pangram(.extraLight, size: 24))
                    Text("Default Weight (Regular)").font(.pangram(size: 24))

                }
                
                Divider()
                
                Text("Design System:")
                    .font(.headline)
                
                Group {
                    Text("Heading 1").font(.heading1)
                    Text("Heading 2").font(.heading2)
                    Text("Heading 3").font(.heading3)
                    Text("Body Bold").font(.bodyBold)
                    Text("Body Regular").font(.bodyRegular)
                    Text("Caption Meta").font(.captionMeta)
                }
            }
            .padding()
        }
    }
}
