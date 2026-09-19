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
