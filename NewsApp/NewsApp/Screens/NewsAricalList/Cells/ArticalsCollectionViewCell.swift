//
//  ArticalsCollectionViewCell.swift
//  NewsApp
//
//  Created by Geetha Sai Durga on 20/08/25.
//

import UIKit
import Kingfisher

class ArticalsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let id: String = "ArticalsCollectionViewCell"
    static let nib: UINib = UINib(nibName: id, bundle: nil)
    
    // MARK: - Outlets
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var autherLabel: UILabel!
    @IBOutlet var articalImage: UIImageView!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    // MARK: - Private
    private var article: Article?
    private let loader = UIActivityIndicatorView(style: .medium)
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
        setupImageView()
        setupCardStyle()
    }
    
    
    // MARK: - UI Setup
    private func setupLabels() {
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        autherLabel.numberOfLines = 0
        autherLabel.font = UIFont.systemFont(ofSize: 14)
        autherLabel.textColor = .secondaryLabel
    }
    
    private func setupImageView() {
        articalImage.contentMode = .scaleToFill
        articalImage.layer.cornerRadius = 10
    }
    
    private func setupCardStyle() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        
        // Shadow for card effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
    
    
    // MARK: - Configure Cell
    func configure(with article: Article) {
        self.article = article
        
        // Title & Author
        nameLabel.text = article.title ?? "Untitled"
        autherLabel.text = article.author ?? "Unknown Author"
        
        // Article Image
        articalImage.isHidden = false
        loader.startAnimating()
        
        DispatchQueue.main.async {
            guard let urlString = article.urlToImage,
                  let url = URL(string: urlString) else {
                self.loader.stopAnimating()
                return
            }
            
            self.articalImage.kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(0.2))],
                completionHandler: { [weak self] result in
                    DispatchQueue.main.async {
                        self?.loader.stopAnimating()
                    }
                    if case .failure = result {
                        print("⚠️ Failed to load image")
                    }
                }
            )
        }
        
        // Bookmark Button State
        let bookmarkImage = article.isBookmarked == "1" ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: bookmarkImage), for: .normal)
    }
    
    
    // MARK: - Actions
    @IBAction func bookmarkTapped(_ sender: UIButton) {
        guard let article = article else { return }
        
        // Toggle in cache
        Cacher.shared.toggleBookmark(for: article)
        
        // Notify observers
        NotificationCenter.default.post(name: .bookmarkUpdated, object: nil)
    }
    
    
    // MARK: - Dynamic Height Handling
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
