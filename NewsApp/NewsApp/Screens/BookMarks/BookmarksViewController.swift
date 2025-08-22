//
//  BookmarksViewController.swift
//  NewsApp
//
//  Created by Geetha Sai Durga on 21/08/25.
//

import UIKit

class BookmarksViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    /// List of bookmarked articles
    private var bookmarkedArticles: [Article] = []
    
    
    // MARK: - Initializer
    class func instance() -> BookmarksViewController? {
        return UIStoryboard(name: "BookMark", bundle: .main)
            .instantiateViewController(withIdentifier: "BookmarksViewController") as? BookmarksViewController
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bookmarks"
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        loadBookmarks()
        
        // Observe bookmark changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .bookmarkUpdated,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarks()
        collectionView.reloadData()
    }
    
    
    // MARK: - Data Loading
    /// Reload when bookmarks are updated
    @objc private func reloadData() {
        bookmarkedArticles = Cacher.shared.getBookmarkedArticles()
        collectionView.reloadData()
    }
    
    /// Load bookmarked articles from cache
    private func loadBookmarks() {
        bookmarkedArticles = Cacher.shared.getBookmarkedArticles()
    }
    
    
    // MARK: - UI Setup
    /// Configure collection view layout and registration
    private func configureCollectionView() {
        collectionView.register(
            ArticalsCollectionViewCell.nib,
            forCellWithReuseIdentifier: ArticalsCollectionViewCell.id
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = CollectionViewLayout.share.setUpCollectionViewLayout()
    }
}


// MARK: - UICollectionView Delegate + DataSource
extension BookmarksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Show either bookmarks or an empty state message
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bookmarkedArticles.isEmpty {
            let noDataLabel = UILabel(frame: collectionView.bounds)
            noDataLabel.text = "No Bookmarked Articles"
            noDataLabel.textColor = .secondaryLabel
            noDataLabel.textAlignment = .center
            collectionView.backgroundView = noDataLabel
        } else {
            collectionView.backgroundView = nil
        }
        return bookmarkedArticles.count
    }
    
    /// Render bookmark cells
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArticalsCollectionViewCell.id,
            for: indexPath
        ) as? ArticalsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let article = bookmarkedArticles[indexPath.item]
        cell.configure(with: article)
        return cell
    }
    
    /// Handle article tap → open in Safari
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = bookmarkedArticles[indexPath.item]
        if let url = URL(string: article.url ?? "") {
            UIApplication.shared.open(url)
        }
    }
}


// MARK: - Bookmark Handling
extension BookmarksViewController {
    
    /// Toggle bookmark state for an article and persist changes
    private func toggleBookmark(for article: Article) {
        if let index = bookmarkedArticles.firstIndex(where: { $0.title == article.title }) {
            // Remove if already bookmarked
            bookmarkedArticles.remove(at: index)
        }
        
        // Save updated list to UserDefaults (legacy, could be removed if only using `Cacher`)
        if let encoded = try? JSONEncoder().encode(bookmarkedArticles) {
            UserDefaults.standard.set(encoded, forKey: "bookmarkedArticles")
        }
        
        collectionView.reloadData()
    }
}
