import SwiftUI
import UIKit

enum Theme {
    static let cerrado = Color(red: 0.12, green: 0.29, blue: 0.25)
    static let cerradoDeep = Color(red: 0.08, green: 0.21, blue: 0.18)
    static let sky = Color(red: 0.24, green: 0.49, blue: 0.69)
    static let ipe = Color(red: 0.91, green: 0.72, blue: 0.29)
    static let ink = Color(red: 0.11, green: 0.17, blue: 0.16)

    static var canvas: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.10, alpha: 1)
                : UIColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 1)
        })
    }

    static var surface: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.16, blue: 0.15, alpha: 1)
                : UIColor.white
        })
    }

    static var softSurface: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.20, blue: 0.18, alpha: 1)
                : UIColor(red: 0.93, green: 0.92, blue: 0.88, alpha: 1)
        })
    }
}

enum SpecialtyStyle {
    struct Identity { let symbol: String; let tint: Color }

    static func identity(for specialty: String) -> Identity {
        let key = specialty.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        return Self.map[key] ?? Self.hashFallback(key)
    }

    static let map: [String: Identity] = [
        "clinica geral": Identity(symbol: "stethoscope", tint: Theme.cerrado),
        "cardiologia": Identity(symbol: "heart.fill", tint: Color(red: 0.80, green: 0.30, blue: 0.32)),
        "dermatologia": Identity(symbol: "sun.max.fill", tint: Color(red: 0.88, green: 0.55, blue: 0.33)),
        "endocrinologia": Identity(symbol: "drop.fill", tint: Color(red: 0.20, green: 0.52, blue: 0.50)),
        "pediatria": Identity(symbol: "figure.child", tint: Theme.sky),
        "oftalmologia": Identity(symbol: "eye.fill", tint: Color(red: 0.32, green: 0.40, blue: 0.66)),
        "ginecologia": Identity(symbol: "figure.stand", tint: Color(red: 0.80, green: 0.45, blue: 0.58)),
        "ortopedia": Identity(symbol: "figure.walk", tint: Color(red: 0.42, green: 0.52, blue: 0.62)),
        "neurologia": Identity(symbol: "brain.head.profile", tint: Color(red: 0.52, green: 0.40, blue: 0.70)),
        "psiquiatria": Identity(symbol: "face.smiling.fill", tint: Color(red: 0.60, green: 0.45, blue: 0.72)),
        "pneumologia": Identity(symbol: "lungs.fill", tint: Color(red: 0.30, green: 0.60, blue: 0.62)),
        "oncologia": Identity(symbol: "cross.circle.fill", tint: Color(red: 0.30, green: 0.40, blue: 0.60)),
        "urologia": Identity(symbol: "drop.fill", tint: Color(red: 0.22, green: 0.50, blue: 0.56)),
        "nefrologia": Identity(symbol: "drop.fill", tint: Color(red: 0.20, green: 0.55, blue: 0.52)),
        "gastroenterologia": Identity(symbol: "waveform.path.ecg", tint: Color(red: 0.45, green: 0.52, blue: 0.28)),
        "otorrinolaringologia": Identity(symbol: "ear.fill", tint: Color(red: 0.70, green: 0.60, blue: 0.30)),
        "fonoaudiologia": Identity(symbol: "waveform", tint: Color(red: 0.30, green: 0.60, blue: 0.64)),
        "radiologia": Identity(symbol: "waveform.path.ecg", tint: Color(red: 0.42, green: 0.50, blue: 0.58)),
        "acupuntura": Identity(symbol: "waveform.path.ecg", tint: Color(red: 0.28, green: 0.55, blue: 0.34)),
        "anestesiologia": Identity(symbol: "moon.zzz.fill", tint: Color(red: 0.50, green: 0.55, blue: 0.66)),
        "angiologia": Identity(symbol: "heart.circle.fill", tint: Color(red: 0.65, green: 0.34, blue: 0.30)),
        "cirurgia plastica": Identity(symbol: "scissors", tint: Color(red: 0.45, green: 0.50, blue: 0.56)),
        "geriatria": Identity(symbol: "person.crop.circle.fill", tint: Color(red: 0.68, green: 0.56, blue: 0.38)),
        "homeopatia": Identity(symbol: "leaf.fill", tint: Color(red: 0.34, green: 0.56, blue: 0.32)),
        "infectologia": Identity(symbol: "allergens", tint: Color(red: 0.72, green: 0.50, blue: 0.22)),
        "mastologia": Identity(symbol: "cross.case.fill", tint: Color(red: 0.80, green: 0.45, blue: 0.56)),
        "medicina do trabalho": Identity(symbol: "briefcase.fill", tint: Color(red: 0.42, green: 0.48, blue: 0.52)),
        "nutricao": Identity(symbol: "leaf.fill", tint: Color(red: 0.34, green: 0.58, blue: 0.34)),
        "reproducao humana": Identity(symbol: "figure.stand", tint: Color(red: 0.82, green: 0.50, blue: 0.60)),
        "reumatologia": Identity(symbol: "figure.arms.open", tint: Color(red: 0.30, green: 0.52, blue: 0.56))
    ]

    private static let fallbackTints: [Color] = [
        Theme.cerrado, Theme.sky, Color(red: 0.52, green: 0.40, blue: 0.70),
        Color(red: 0.30, green: 0.60, blue: 0.62), Color(red: 0.68, green: 0.56, blue: 0.38),
        Color(red: 0.42, green: 0.48, blue: 0.56)
    ]

    private static func hashFallback(_ key: String) -> Identity {
        let sum = key.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Identity(symbol: "stethoscope", tint: fallbackTints[sum % fallbackTints.count])
    }
}

func compactCount(_ value: Int) -> String {
    if value >= 1000 {
        let v = Double(value) / 1000.0
        return String(format: "%.1f mil", v).replacingOccurrences(of: ".", with: ",")
    }
    return "\(value)"
}
