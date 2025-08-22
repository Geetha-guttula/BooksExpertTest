# BookExpert Assignment.

# News App (UIKit + MVVM)

## Project Description
The ** News App** fetches and displays the latest news articles from a public API. It supports **offline viewing**, **search**, **bookmarking**, and opens articles in **Safari**. The app follows a **clean MVVM architecture** with decoupled networking, persistence, and UI layers.

## Features

### 1. API Integration
- Integrated REST API using **URLSession** to fetch a list of articles.
- Displays **title**, **author**, and **thumbnail** .
- Uses **Kingfisher** for efficient image downloading and caching.

### 2. Offline Caching
- Implemented offline caching with **File Catche**.
- If the device is offline, the app shows **cached articles** automatically.

### 3. Pull-to-Refresh
- Added **UIRefreshControl** for refreshing the article list dynamically.

### 4. Search Articles
- Integrated **UISearchBar** to **filter articles by title** in real time.

### 5. Bookmark Articles (Bonus)
- Users can **bookmark** their favorite articles.
- Dedicated **Bookmarks** tab to view saved articles separately.

### 6. Open in Safari
- On selecting an article, the app opens the **article URL in Safari**.

## Architecture

### 1. Pattern
- **MVVM (Model–View–ViewModel)** for separation of concerns and testability.

### 2. Layered Design
- **Networking** (API clients, DTOs)
- **Persistence** (File catche, repositories)
- **UI** (UIKit views, view controllers, compositional layouts)
- **ViewModels** (business logic, state management)

## UI / UX

### 1. UIKit & Auto Layout
- Built with **UIKit** and **Auto Layout** for adaptive layouts across devices.

### 2. Appearance
- Supports **Light & Dark Mode**.

### 3. Layout
- Uses **UICollectionViewCompositionalLayout** for modern, list-style presentation.

## Libraries Used

### 1. Kingfisher
- For image downloading and caching.

*(File Catche, URLSession,  Apple frameworks.)*

## How It Works

### 1. Flow
- Fetch articles from the API.
- Display **title**, **author**, and **thumbnail**.
- Support **pull-to-refresh**, **search**, and **bookmarking**.
- Open the article in **Safari** when did select the cell.
- Persist data in **File Catche** for **offline access**.


## Core Components

### 1. Networking
- `ArticleService` using **URLSession** to fetch articles (decode JSON → models).

### 2. Offline Storage
- `file catche` with repositories for saving/fetching **Article** .

### 3. UI
- `UICollectionView` with **Compositional Layout**
- `UISearchBar` for **live filtering**.
- `UIRefreshControl` for **pull-to-refresh**.

### 4. Bookmarks
- Separate **Bookmarks** tab  backed by file catche






