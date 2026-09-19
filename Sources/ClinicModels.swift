import Foundation

struct Clinic: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let specialties: [String]
    let neighborhood: String?
    let address: String?
    let city: String?
    let state: String?
    let phone: String?
    let whatsapp: String?
    let email: String?
    let mapsRef: String?
    let source: String
    let sourceURL: String?
    let lastVerified: String
    let dataStatus: String

    enum CodingKeys: String, CodingKey {
        case id, name, specialties, neighborhood, address, city, state, phone, whatsapp, email
        case mapsRef = "maps_ref"
        case source
        case sourceURL = "source_url"
        case lastVerified = "last_verified"
        case dataStatus = "data_status"
    }

    var displayNeighborhood: String { neighborhood?.nilIfEmpty ?? "Distrito Federal" }
    var displaySpecialty: String { specialties.first?.nilIfEmpty ?? "Clínica" }
    var searchableText: String {
        ([name, displaySpecialty, displayNeighborhood] + specialties + [address ?? ""]).joined(separator: " ").folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }

    var phoneURL: URL? { contactURL(for: phone, scheme: "tel") }
    var whatsappURL: URL? {
        guard let number = BrazilianPhone.normalizedDigits(whatsapp) else { return nil }
        return URL(string: "https://wa.me/\(number)")
    }

    private func contactURL(for value: String?, scheme: String) -> URL? {
        guard let number = BrazilianPhone.normalizedDigits(value) else { return nil }
        return URL(string: "\(scheme):+\(number)")
    }
}

enum BrazilianPhone {
    static func normalizedDigits(_ value: String?) -> String? {
        guard let value else { return nil }
        var digits = value.filter(\.isNumber)
        guard digits.isEmpty == false else { return nil }

        if digits.hasPrefix("55") {
            return (digits.count == 12 || digits.count == 13) ? digits : nil
        }
        if digits.hasPrefix("0") && (digits.count == 11 || digits.count == 12) {
            digits.removeFirst()
        }
        if digits.count == 10 || digits.count == 11 { return "55\(digits)" }
        return nil
    }
}

private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }
