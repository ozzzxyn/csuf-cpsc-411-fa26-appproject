/*
import SwiftUI
import Playgrounds

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
*/


import SwiftUI

// MARK: - Models (match the JSON structure)
struct Entry: Codable, Identifiable {
    let word: String
    let phonetic: String?
    let meanings: [Meaning]
    var id: String { word }
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
    let example: String?
}

// MARK: - View
struct ContentView: View {
    @State private var word = "hello"
    @State private var entries: [Entry] = []
    @State private var errorMessage: String?

    var urlString: String {
        "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
    }

    var body: some View {
        /*
        TabView {
                    Text("Word of the Day").tabItem { Label("Home", systemImage: "house") }
                    Text("Lessons").tabItem { Label("Lessons", systemImage: "book") }
                    //ExploreView().tabItem { Label("Explore", systemImage: "magnifyingglass") }
                    Text("Practice").tabItem { Label("Practice", systemImage: "checkmark.circle") }
                    Text("Progress").tabItem { Label("Progress", systemImage: "chart.bar") }
                }
        .padding(
        */
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Enter a word", text: $word)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                Button("Look up word") {
                    Task { await fetchWord() }
                }
                .buttonStyle(.borderedProminent)

                // These two lines are what your screenshot needs to show
                Text("Method: GET").bold()
                Text("Endpoint: \(urlString)")
                    .font(.caption)

                if let errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }

                ForEach(entries) { entry in
                    Text("\(entry.word)  \(entry.phonetic ?? "")")
                        .font(.title2)
                    ForEach(entry.meanings.indices, id: \.self) { i in
                        let meaning = entry.meanings[i]
                        Text(meaning.partOfSpeech).italic()
                        if let first = meaning.definitions.first {
                            Text("• \(first.definition)")
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - API call
    func fetchWord() async {
        errorMessage = nil
        guard let url = URL(string: urlString) else {
            errorMessage = "Bad URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url) // GET by default
            entries = try JSONDecoder().decode([Entry].self, from: data)
        } catch {
            entries = []
            errorMessage = "Word not found or request failed."
        }
    }
}

#Preview { ContentView() }
