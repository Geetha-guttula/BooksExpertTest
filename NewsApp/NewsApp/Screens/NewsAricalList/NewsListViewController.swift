////
////  NewsListViewController.swift
////  NewsApp
////
////  Created by Geetha Sai Durga on 20/08/25.


import UIKit
import UIKit

class NewsListViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Original articles list
    private var articles: [Article] = []
    
    /// Filtered articles (for search results)
    private var filteredArticles: [Article] = []
    
    /// Outlets
    @IBOutlet var newsCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    /// Pull-to-refresh
    private let refreshControl = UIRefreshControl()
    
    /// Loader when fetching news
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    
    // MARK: - Lifecycle
    
    class func instance() -> NewsListViewController? {
        return UIStoryboard(name: "News", bundle: .main)
            .instantiateViewController(withIdentifier: "NewsListViewController") as? NewsListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "News Articles"
        searchBar.placeholder = "Search By Title"
        
        setupCollectionView()
        setupLoadingIndicator()
        setupNavigationBar()
        
        // Load cached or fetch new articles
        loadCachedRepos()
        
        // Initially filtered = full list
        filteredArticles = articles
        
        // Set search delegate
        searchBar.delegate = self
        
        // Observe bookmark changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: .bookmarkUpdated,
            object: nil
        )
    }
    
    
    // MARK: - UI Setup
    
    /// Setup navigation bar with bookmark button
    private func setupNavigationBar() {
        let bookmarkButton = UIBarButtonItem(
            image: UIImage(systemName: "bookmark.fill"),
            style: .plain,
            target: self,
            action: #selector(openBookmarks)
        )
        bookmarkButton.tintColor = .label
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    /// Setup collection view
    private func setupCollectionView() {
        newsCollectionView.backgroundColor = .systemBackground
        newsCollectionView.register(
            ArticalsCollectionViewCell.nib,
            forCellWithReuseIdentifier: ArticalsCollectionViewCell.id
        )
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        newsCollectionView.collectionViewLayout = CollectionViewLayout.share.setUpCollectionViewLayout()
        
        // Pull-to-refresh
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        newsCollectionView.refreshControl = refreshControl
    }
    
    /// Setup loading indicator
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    // MARK: - Data Handling
    
    /// Reload articles when bookmark changes
    @objc private func reloadData() {
        articles = Cacher.shared.getCachedResponse() ?? []
        
        // Apply search filter if text is present
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredArticles = articles.filter { $0.title?.localizedCaseInsensitiveContains(searchText) == true }
        } else {
            filteredArticles = articles
        }
        
        newsCollectionView.reloadData()
    }
    
    /// Load cached repos if available, otherwise fetch new
    private func loadCachedRepos() {
        if let cached = Cacher.shared.getCachedResponse(), !cached.isEmpty {
            self.articles = cached
            filteredArticles = articles
            self.newsCollectionView.reloadData()
        } else {
            fetchNewsArticals()
        }
    }
    
    /// Pull-to-refresh action
    @objc private func refreshPulled() {
        fetchNewsArticals()
    }
    
    /// Fetch from API
    private func fetchNewsArticals() {
        loadingIndicator.startAnimating()
        NetworkService.shared.fetchSwiftRepositories { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let repos):
                    self.articles = repos
                    self.filteredArticles = repos
                    Cacher.shared.cacheResponse(repos)
                    self.newsCollectionView.reloadData()
                case .failure(let error):
                    print("❌ Failed to fetch:", error)
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    
    /// Open bookmarks screen
    @objc private func openBookmarks() {
        if let bookmarksVC = BookmarksViewController.instance() {
            navigationController?.pushViewController(bookmarksVC, animated: true)
        }
    }
}


// MARK: - UICollectionViewDataSource

extension NewsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredArticles.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArticalsCollectionViewCell.id,
            for: indexPath
        ) as? ArticalsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: filteredArticles[indexPath.item])
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let article = filteredArticles[indexPath.item]
        
        // Open in Safari
        if let urlString = article.url, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}


// MARK: - UISearchBarDelegate

extension NewsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredArticles = articles
        } else {
            filteredArticles = articles.filter {
                $0.title?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        newsCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // dismiss keyboard
    }
}
