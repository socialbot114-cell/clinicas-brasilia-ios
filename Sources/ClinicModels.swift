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
}

private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }
