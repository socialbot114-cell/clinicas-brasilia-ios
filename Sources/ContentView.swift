import SwiftUI

struct ContentView: View {
    @StateObject private var catalog = ClinicCatalog()
    @StateObject private var favorites = FavoritesStore()

    var body: some View {
        TabView {
            HomeView(catalog: catalog, favorites: favorites).tabItem { Label("Início", systemImage: "house") }
            ExploreView(catalog: catalog, favorites: favorites).tabItem { Label("Explorar", systemImage: "magnifyingglass") }
            FavoritesView(catalog: catalog, favorites: favorites).tabItem { Label("Favoritos", systemImage: "heart") }
        }
        .tint(Color(red: 0.05, green: 0.30, blue: 0.29))
    }
}

private struct HomeView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cuidado perto de você").font(.largeTitle.bold())
                        Text("Encontre clínicas e especialidades em Brasília.").foregroundStyle(.secondary)
                    }
                    SearchField(text: $catalog.query)
                    HStack { Text("Clínicas encontradas").font(.title2.bold()); Spacer(); Text("\(catalog.filtered.count)").foregroundStyle(.secondary) }
                    LazyVStack(spacing: 12) {
                        ForEach(catalog.filtered.prefix(20)) { clinic in
                            NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: { ClinicCard(clinic: clinic, isFavorite: favorites.contains(clinic.id)) }.buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Clínicas Brasília")
        }
    }
}

private struct ExploreView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore
    var body: some View {
        NavigationStack {
            List {
                Section("Buscar") { SearchField(text: $catalog.query) }
                Section("Especialidade") { Picker("Especialidade", selection: $catalog.specialty) { ForEach(catalog.specialties, id: \.self) { Text($0).tag($0) } }.pickerStyle(.navigationLink) }
                Section("Região") { Picker("Região", selection: $catalog.neighborhood) { ForEach(catalog.neighborhoods, id: \.self) { Text($0).tag($0) } }.pickerStyle(.navigationLink) }
                Section("Resultados") { ForEach(catalog.filtered) { clinic in NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: { ClinicCard(clinic: clinic, isFavorite: favorites.contains(clinic.id)) } } }
            }
            .navigationTitle("Explorar")
            .toolbar { if catalog.query.isEmpty == false || catalog.neighborhood != "Todos" || catalog.specialty != "Todos" { Button("Limpar") { catalog.query = ""; catalog.neighborhood = "Todos"; catalog.specialty = "Todos" } } }
        }
    }
}

private struct FavoritesView: View {
    @ObservedObject var catalog: ClinicCatalog
    @ObservedObject var favorites: FavoritesStore
    var body: some View {
        NavigationStack {
            List {
                let saved = catalog.clinics.filter { favorites.contains($0.id) }
                if saved.isEmpty { ContentUnavailableView("Nenhuma clínica salva", systemImage: "heart", description: Text("Toque no coração de uma clínica para encontrá-la aqui.")) }
                else { ForEach(saved) { clinic in NavigationLink { ClinicDetailView(clinic: clinic, favorites: favorites) } label: { ClinicCard(clinic: clinic, isFavorite: true) } } }
            }
            .navigationTitle("Favoritos")
        }
    }
}

private struct ClinicDetailView: View {
    let clinic: Clinic
    @ObservedObject var favorites: FavoritesStore
    @Environment(\.openURL) private var openURL
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Color(red: 0.05, green: 0.30, blue: 0.29), .mint], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(height: 180).overlay(Image(systemName: "cross.case.fill").font(.system(size: 54)).foregroundStyle(.white.opacity(0.9)))
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) { Text(clinic.name).font(.title.bold()); Text("\(clinic.displaySpecialty) • \(clinic.displayNeighborhood)").foregroundStyle(.secondary) }
                    Spacer()
                    Button { favorites.toggle(clinic.id) } label: { Image(systemName: favorites.contains(clinic.id) ? "heart.fill" : "heart") }.accessibilityLabel(favorites.contains(clinic.id) ? "Remover dos favoritos" : "Adicionar aos favoritos")
                }
                if let address = clinic.address, !address.isEmpty { Label(address, systemImage: "mappin.and.ellipse") }
                if !clinic.specialties.isEmpty { Text("Especialidades").font(.headline); Text(clinic.specialties.joined(separator: ", ")).foregroundStyle(.secondary) }
                if let verified = clinic.lastVerified.nilIfEmpty { Text("Dados verificados em \(verified)").font(.footnote).foregroundStyle(.secondary) }
                VStack(spacing: 10) {
                    if let phone = clinic.phone, let url = URL(string: "tel:\(phone.filter { $0.isNumber })") { ActionButton(title: "Ligar", systemImage: "phone", url: url, openURL: openURL) }
                    if let whatsapp = clinic.whatsapp, let url = URL(string: "https://wa.me/\(whatsapp.filter { $0.isNumber })") { ActionButton(title: "WhatsApp", systemImage: "message", url: url, openURL: openURL) }
                    let query = clinic.address ?? "\(clinic.name), Brasília DF"
                    if let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Brasilia")") { ActionButton(title: "Como chegar", systemImage: "map", url: url, openURL: openURL) }
                }
                Text("O aplicativo apresenta dados cadastrais públicos. Confirme horários, serviços e disponibilidade diretamente com a clínica.").font(.footnote).foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ClinicCard: View {
    let clinic: Clinic
    let isFavorite: Bool
    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14).fill(Color.mint.opacity(0.25)).frame(width: 64, height: 64).overlay(Image(systemName: "cross.case.fill").foregroundStyle(.teal))
            VStack(alignment: .leading, spacing: 4) { Text(clinic.name).font(.headline).foregroundStyle(.primary); Text(clinic.displaySpecialty).font(.subheadline).foregroundStyle(.secondary); Text(clinic.displayNeighborhood).font(.caption).foregroundStyle(.secondary) }
            Spacer()
            if isFavorite { Image(systemName: "heart.fill").foregroundStyle(.pink).accessibilityHidden(true) }
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.quaternary))
    }
}

private struct SearchField: View { @Binding var text: String; var body: some View { HStack { Image(systemName: "magnifyingglass"); TextField("Buscar clínica ou especialidade", text: $text).textInputAutocapitalization(.never) }.padding(12).background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 14)) } }
private struct ActionButton: View { let title: String; let systemImage: String; let url: URL; let openURL: OpenURLAction; var body: some View { Button { openURL(url) } label: { Label(title, systemImage: systemImage).frame(maxWidth: .infinity) }.buttonStyle(.borderedProminent) } }
private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }

#Preview { ContentView() }
