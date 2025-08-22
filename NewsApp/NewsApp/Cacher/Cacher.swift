import Foundation
class Cacher {
    static let shared = Cacher()

    private let fileName = "cached_repos.json"

    private init() {}

    private var fileURL: URL {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(fileName)
    }

    // MARK: - Save Articles
    func cacheResponse(_ response: [Article]) {
        do {
            let data = try JSONEncoder().encode(response)
            try data.write(to: fileURL)
        } catch {
            print("Error caching repos:", error)
        }
    }

    // MARK: - Load Articles
    func getCachedResponse() -> [Article]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let repos = try JSONDecoder().decode([Article].self, from: data)
            return repos
        } catch {
            print("Error decoding cached repos:", error)
            return []
        }
    }


    // MARK: - Clear Cache
    func clearCache() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Bookmark Handling
    func toggleBookmark(for article: Article) {
        var current = getCachedResponse() ?? []
        if let index = current.firstIndex(where: { $0.title == article.title }) {
            current[index].isBookmarked = "\( article.isBookmarked == "0" ? 1 : 0)"
        } else {
            var new = article
            new.isBookmarked = "1"
            current.append(new)
        }
        cacheResponse(current)
    }

    func getBookmarkedArticles() -> [Article] {
        return getCachedResponse()?.filter { $0.isBookmarked  == "1"} ?? []
    }

    func updateArticle(_ article: Article) {
        var current = getCachedResponse() ?? []
        if let index = current.firstIndex(of: article) {
            
            current[index] = article
        } else {
            current.append(article)
        }
        cacheResponse(current)
    }
}


