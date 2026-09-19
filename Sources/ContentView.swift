import SwiftUI

struct ContentView: View {
    @StateObject private var catalog = ClinicCatalog()
    @StateObject private var favorites = FavoritesStore()

    var body: some View {
        TabView {
            HomeView(catalog: catalog, favorites: favorites)
                .tabItem { Label("Início", systemImage: "house") }
            ExploreView(catalog: catalog, favorites: favorites)
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
            FavoritesView(catalog: catalog, favorites: favorites)
                .tabItem { Label("Salvos", systemImage: "heart") }
        }
        .tint(Theme.cerrado)
    }
}

// MARK: - Home

private struct HomeView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore
    @State private var query = ""
    @State private var selectedSpecialty: String?
    @State private var selectedRegion: String?

    private var isBrowsing: Bool { !query.isEmpty || selectedSpecialty != nil || selectedRegion != nil }

    private var results: [Clinic] {
        ClinicCatalog.filter(catalog.clinics, query: query, neighborhood: selectedRegion ?? "Todos", specialty: selectedSpecialty ?? "Todos")
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    SearchBar(text: $query, placeholder: "Clínica, especialidade ou região")

                    if catalog.loadState == .failed {
                        CatalogStatusView(state: catalog.loadState)
                    } else if isBrowsing {
                        browsingResults
                    } else {
                        discovery
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.canvas)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.cerrado).frame(width: 36, height: 36)
                    Image(systemName: "cross.case.fill").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                }
                Text("CLÍNICAS BRASÍLIA")
                    .font(.caption.weight(.heavy)).tracking(1.4).foregroundStyle(Theme.sky)
            }
            Text("Encontre atendimento no Distrito Federal")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Um diretório calmo e transparente de clínicas e especialidades.")
                .font(.subheadline).foregroundStyle(.secondary)
            trustStrip
        }
    }

    private var trustStrip: some View {
        HStack(spacing: 12) {
            Label("Diretório público do DF", systemImage: "building.2")
            Label("Sem conta", systemImage: "person.crop.circle.badge.checkmark")
            Label("Sem rastreamento", systemImage: "hand.raised")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private var browsingResults: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(selectedSpecialty ?? selectedRegion ?? "Resultados").font(.title3.bold())
                Spacer()
                Button("Limpar") { query = ""; selectedSpecialty = nil; selectedRegion = nil }
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.cerrado)
            }
            Text("\(results.count) clínica\(results.count == 1 ? "" : "s")").font(.footnote).foregroundStyle(.secondary)

            if results.isEmpty {
                ContentUnavailableView("Nada por aqui", systemImage: "cross.case", description: Text("Tente outra busca, especialidade ou região."))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(results.prefix(40)) { clinic in
                        clinicRow(clinic)
                    }
                }
            }
        }
    }

    private var discovery: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Buscar por especialidade").font(.title3.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(Array(catalog.specialtyRanking.prefix(6).enumerated()), id: \.element.name) { index, item in
                        specialtyTile(item).accessibilityIdentifier("specialty-\(index)")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Explorar por região").font(.title3.bold())
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(catalog.regionRanking.prefix(10), id: \.name) { item in
                            Button {
                                selectedRegion = item.name
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name).font(.caption.weight(.semibold)).foregroundStyle(.primary)
                                    Text("\(item.count)").font(.caption2).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.quaternary.opacity(0.6)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            methodology
        }
    }

    private func specialtyTile(_ item: (name: String, count: Int)) -> some View {
        let style = SpecialtyStyle.identity(for: item.name)
        return Button {
            selectedSpecialty = item.name
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(style.tint.opacity(0.15)).frame(height: 64)
                    Image(systemName: style.symbol).font(.system(size: 26)).foregroundStyle(style.tint)
                }
                Text(item.name).font(.caption.weight(.semibold)).foregroundStyle(.primary).lineLimit(2).multilineTextAlignment(.center)
                Text("\(item.count)").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var methodology: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle").foregroundStyle(.secondary)
            Text("Os dados vêm de fontes públicas e ainda estão em revisão editorial. Confirme horários e serviços diretamente com a clínica.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func clinicRow(_ clinic: Clinic) -> some View {
        HStack(spacing: 10) {
            NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: {
                ClinicCard(clinic: clinic, showFavorite: false)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("row-\(clinic.id)")
            FavoriteButton(clinic: clinic, favorites: favorites)
        }
    }
}

// MARK: - Explore

private struct ExploreView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore
    @State private var ascending = true
    @State private var showRegion = false
    @State private var showSpecialty = false

    private var results: [Clinic] {
        catalog.filtered.sorted {
            ascending
                ? $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
                : $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedDescending
        }
    }

    private var hasFilters: Bool {
        catalog.query.isEmpty == false || catalog.neighborhood != "Todos" || catalog.specialty != "Todos"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SearchBar(text: $catalog.query, placeholder: "Clínica, especialidade ou região")
                    filterChips
                    Text("\(results.count) clínica\(results.count == 1 ? "" : "s")")
                        .font(.footnote.weight(.semibold)).foregroundStyle(.secondary)

                    if catalog.loadState == .failed {
                        CatalogStatusView(state: catalog.loadState)
                    } else if results.isEmpty {
                        ContentUnavailableView("Nenhum resultado", systemImage: "magnifyingglass", description: Text("Ajuste a busca ou limpe os filtros."))
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(results) { clinic in
                                HStack(spacing: 10) {
                                    NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: {
                                        ClinicCard(clinic: clinic, showFavorite: false)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("row-\(clinic.id)")
                                    FavoriteButton(clinic: clinic, favorites: favorites)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.canvas)
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { ascending = true } label: { Label("Nome A–Z", systemImage: ascending ? "checkmark" : "textformat") }
                        Button { ascending = false } label: { Label("Nome Z–A", systemImage: ascending ? "textformat" : "checkmark") }
                    } label: {
                        Label("Ordenar", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showRegion) {
                OptionPicker(title: "Região", options: catalog.neighborhoods, selection: $catalog.neighborhood)
            }
            .sheet(isPresented: $showSpecialty) {
                OptionPicker(title: "Especialidade", options: catalog.specialties, selection: $catalog.specialty)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: catalog.specialty == "Todos" ? "Especialidade" : catalog.specialty, active: catalog.specialty != "Todos") { showSpecialty = true }
                chip(title: catalog.neighborhood == "Todos" ? "Região" : catalog.neighborhood, active: catalog.neighborhood != "Todos") { showRegion = true }
                if hasFilters {
                    Button {
                        catalog.query = ""; catalog.neighborhood = "Todos"; catalog.specialty = "Todos"
                    } label: {
                        Label("Limpar", systemImage: "xmark").font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 8)
                            .background(Theme.sky.opacity(0.14), in: Capsule()).foregroundStyle(Theme.sky)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func chip(title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 8)
                .background(active ? Theme.cerrado : Theme.softSurface, in: Capsule())
                .foregroundStyle(active ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Favorites

private struct FavoritesView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore

    var body: some View {
        NavigationStack {
            Group {
                let saved = catalog.clinics.filter { favorites.contains($0.id) }
                if saved.isEmpty {
                    ContentUnavailableView {
                        Label("Nada salvo ainda", systemImage: "heart")
                    } description: {
                        Text("Toque no coração de uma clínica para guardá-la aqui.")
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(saved) { clinic in
                                HStack(spacing: 10) {
                                    NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: {
                                        ClinicCard(clinic: clinic, showFavorite: false)
                                    }
                                    .buttonStyle(.plain)
                                    FavoriteButton(clinic: clinic, favorites: favorites)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Theme.canvas)
            .navigationTitle("Salvos")
        }
    }
}

// MARK: - Detail

private struct ClinicDetailView: View {
    let clinic: Clinic
    @ObservedObject var favorites: FavoritesStore
    @Environment(\.openURL) private var openURL

    private var style: SpecialtyStyle.Identity { SpecialtyStyle.identity(for: clinic.displaySpecialty) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                identity

                trustPanel

                if let address = clinic.address, !address.isEmpty { addressBlock(address) }

                if !clinic.normalizedSpecialties.isEmpty { specialtiesBlock }

                actions

                disclaimer
            }
            .padding()
        }
        .background(Theme.canvas)
        .navigationTitle(clinic.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { favorites.toggle(clinic.id) } label: {
                    Image(systemName: favorites.contains(clinic.id) ? "heart.fill" : "heart")
                        .foregroundStyle(Theme.cerrado)
                }
            }
        }
    }

    private var identity: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(style.tint.opacity(0.15)).frame(width: 72, height: 72)
                Image(systemName: style.symbol).font(.system(size: 32)).foregroundStyle(style.tint)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(clinic.displayName).font(.system(size: 24, weight: .bold, design: .serif))
                HStack(spacing: 8) {
                    Text(clinic.displaySpecialty).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 4)
                        .background(style.tint.opacity(0.15), in: Capsule()).foregroundStyle(style.tint)
                    Text(clinic.displayNeighborhood).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private var trustPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: clinic.isVerified ? "checkmark.seal.fill" : "clock.badge.questionmark").foregroundStyle(clinic.isVerified ? Theme.cerrado : Theme.ipe)
                Text(clinic.isVerified ? "Dados confirmados pela clínica" : "Dados públicos · ainda não confirmados")
                    .font(.subheadline.weight(.semibold))
            }
            Text("Origem: clinicasbrasilia.com.br. Confirme horários, serviços e disponibilidade diretamente com a clínica.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func addressBlock(_ address: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Endereço").font(.headline)
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "mappin.and.ellipse").foregroundStyle(style.tint)
                Text(address).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    private var specialtiesBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Especialidades").font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(clinic.normalizedSpecialties, id: \.self) { specialty in
                    let s = SpecialtyStyle.identity(for: specialty)
                    Text(specialty).font(.caption.weight(.semibold)).padding(.horizontal, 12).padding(.vertical, 6)
                        .background(s.tint.opacity(0.13), in: Capsule()).foregroundStyle(s.tint)
                }
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            let query = clinic.address ?? "\(clinic.name), Brasília DF"
            if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Brasilia")") {
                PrimaryAction(title: "Como chegar", systemImage: "map", url: url, openURL: openURL)
            }
            if let url = clinic.phoneURL {
                SecondaryAction(title: "Ligar", systemImage: "phone", url: url, openURL: openURL)
            }
        }
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary)
            Text("Este app é um diretório informativo, não um serviço de saúde. Em emergências, procure atendimento médico imediato.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Theme.softSurface, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Components

private struct ClinicCard: View {
    let clinic: Clinic
    var showFavorite: Bool = false

    private var style: SpecialtyStyle.Identity { SpecialtyStyle.identity(for: clinic.displaySpecialty) }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(style.tint.opacity(0.15)).frame(width: 56, height: 56)
                Image(systemName: style.symbol).font(.system(size: 22)).foregroundStyle(style.tint)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(clinic.displayName).font(.headline).foregroundStyle(.primary).lineLimit(1)
                HStack(spacing: 6) {
                    Text(clinic.displaySpecialty).font(.caption).foregroundStyle(style.tint)
                    Text("·").foregroundStyle(.secondary)
                    Text(clinic.displayNeighborhood).font(.caption).foregroundStyle(.secondary)
                }
                if clinic.normalizedSpecialties.count > 1 {
                    Text("+\(clinic.normalizedSpecialties.count - 1) especialidade\(clinic.normalizedSpecialties.count - 1 == 1 ? "" : "s")")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.quaternary.opacity(0.6)))
    }
}

private struct FavoriteButton: View {
    let clinic: Clinic
    @ObservedObject var favorites: FavoritesStore

    var body: some View {
        Button {
            favorites.toggle(clinic.id)
        } label: {
            Image(systemName: favorites.contains(clinic.id) ? "heart.fill" : "heart")
                .font(.system(size: 18))
                .foregroundStyle(favorites.contains(clinic.id) ? Theme.cerrado : .secondary)
                .frame(width: 40, height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(favorites.contains(clinic.id) ? "Remover dos favoritos" : "Adicionar aos favoritos")
    }
}

private struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField(placeholder, text: $text).textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary.opacity(0.6)))
    }
}

private struct OptionPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var filtered: [String] {
        let normalized = search.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        guard !normalized.isEmpty else { return options }
        return options.filter { $0.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(normalized) }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.self) { option in
                Button {
                    selection = option
                    dismiss()
                } label: {
                    HStack {
                        Text(option).foregroundStyle(.primary)
                        Spacer()
                        if option == selection { Image(systemName: "checkmark").foregroundStyle(Theme.cerrado) }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Buscar")
        }
    }
}

private struct PrimaryAction: View {
    let title: String
    let systemImage: String
    let url: URL
    let openURL: OpenURLAction

    var body: some View {
        Button { openURL(url) } label: {
            Label(title, systemImage: systemImage).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.cerrado)
    }
}

private struct SecondaryAction: View {
    let title: String
    let systemImage: String
    let url: URL
    let openURL: OpenURLAction

    var body: some View {
        Button { openURL(url) } label: {
            Label(title, systemImage: systemImage).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .tint(Theme.cerrado)
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

private struct CatalogStatusView: View {
    let state: CatalogLoadState
    var body: some View {
        switch state {
        case .loading:
            ProgressView("Carregando catálogo…").frame(maxWidth: .infinity).padding(.vertical, 40)
        case .loaded:
            EmptyView()
        case .failed(let message):
            ContentUnavailableView("Catálogo indisponível", systemImage: "exclamationmark.triangle", description: Text(message))
        }
    }
}

#Preview { ContentView() }
