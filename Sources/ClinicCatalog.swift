import Foundation
import Combine

enum CatalogLoadState: Equatable {
    case loading
    case loaded
    case failed(String)
}

final class ClinicCatalog: ObservableObject {
    @Published private(set) var clinics: [Clinic] = []
    @Published private(set) var loadState: CatalogLoadState = .loading
    @Published var query = ""
    @Published var neighborhood = "Todos"
    @Published var specialty = "Todos"

    init() { load() }

    init(data: Data) {
        load(data: data)
    }

    init(clinics: [Clinic]) {
        self.clinics = clinics
        loadState = .loaded
    }

    var neighborhoods: [String] { ["Todos"] + Set(clinics.map(\.displayNeighborhood)).sorted() }
    var specialties: [String] { ["Todos"] + Set(clinics.flatMap(\.normalizedSpecialties)).sorted() }

    var filtered: [Clinic] {
        Self.filter(clinics, query: query, neighborhood: neighborhood, specialty: specialty)
    }

    var specialtyRanking: [(name: String, count: Int)] {
        let counts = Dictionary(grouping: clinics.flatMap(\.normalizedSpecialties), by: { $0 }).mapValues(\.count)
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }

    var regionRanking: [(name: String, count: Int)] {
        let counts = Dictionary(grouping: clinics, by: \.displayNeighborhood).mapValues(\.count)
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }

    static func filter(_ items: [Clinic], query: String, neighborhood: String = "Todos", specialty: String = "Todos") -> [Clinic] {
        let normalized = query.folding(options: .diacriticInsensitive, locale: .current).lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return items.filter { clinic in
            (normalized.isEmpty || clinic.searchableText.contains(normalized)) &&
                (neighborhood == "Todos" || clinic.displayNeighborhood == neighborhood) &&
                (specialty == "Todos" || clinic.specialties.contains(specialty))
        }
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json", subdirectory: "Catalog") else {
            loadState = .failed("O catálogo local não foi encontrado.")
            return
        }
        do {
            load(data: try Data(contentsOf: url))
        } catch {
            loadState = .failed("Não foi possível ler o catálogo local.")
        }
    }

    private func load(data: Data) {
        do {
            let decoded = try JSONDecoder().decode([Clinic].self, from: data)
            guard decoded.isEmpty == false else {
                loadState = .failed("O catálogo local está vazio.")
                return
            }
            clinics = decoded
            loadState = .loaded
        } catch {
            loadState = .failed("O catálogo local está indisponível.")
        }
    }
}
