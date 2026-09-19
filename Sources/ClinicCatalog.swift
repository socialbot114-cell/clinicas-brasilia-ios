import Foundation
import Combine

final class ClinicCatalog: ObservableObject {
    @Published private(set) var clinics: [Clinic] = []
    @Published var query = ""
    @Published var neighborhood = "Todos"
    @Published var specialty = "Todos"

    init() { load() }

    var neighborhoods: [String] { ["Todos"] + Set(clinics.map(\.displayNeighborhood)).sorted() }
    var specialties: [String] { ["Todos"] + Set(clinics.flatMap(\.specialties)).sorted() }

    var filtered: [Clinic] {
        let normalized = query.folding(options: .diacriticInsensitive, locale: .current).lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return clinics.filter { clinic in
            (normalized.isEmpty || clinic.searchableText.contains(normalized)) &&
                (neighborhood == "Todos" || clinic.displayNeighborhood == neighborhood) &&
                (specialty == "Todos" || clinic.specialties.contains(specialty))
        }
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json", subdirectory: "Catalog"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Clinic].self, from: data) else { return }
        clinics = decoded
    }
}
