# 🌍 CountriesApp

SwiftUI iOS app for the **REST Countries API** — search, view details, and pin up to 5 countries.  
On first launch, the app automatically pins your **current country** from GPS (or **Brazil** if permission is denied).  
Supports **offline caching** with **SwiftData**, built using **Clean Architecture + MVVM**,  
and includes a robust **retrying network layer** with a focused **unit test suite (≥85% coverage)**.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Platform](https://img.shields.io/badge/Platform-iOS_16+-lightgrey)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20MVVM-blue)
![Coverage](https://img.shields.io/badge/Test%20Coverage-85%25-brightgreen)

---

## ⚙️ Tech Stack

- **Language:** Swift 5+
- **UI:** SwiftUI
- **Architecture:** Clean Architecture + MVVM
- **Networking:** URLSession with custom `APIClient` (exponential backoff retries)
- **Persistence:** SwiftData (`CountrySD`, `PinnedSD`)
- **Location:** CoreLocation (auto-detect user country on first load)
- **Testing:** XCTest + Test Plan with fakes, stubs, and mocks

---

## ✨ Features

- 🔎 Search countries by name (case-insensitive)
- 📍 Auto-pin user country on first load (fallback: **Brazil**)
- 📌 Pin up to 5 countries; swipe to remove
- 🏙 Detailed view with country name, code, capital, and currency
- 📶 Offline caching using **SwiftData** (instant preload → background refresh)
- ♻️ Resilient networking with **idempotent request retries** (`GET`: 5xx / 429 / transient URLErrors)
- 🧭 Custom **App Icon** via asset catalog

---

## 🧱 Project Structure

```bash
CountriesApp/
├─ App/
│  └─ CountriesAppApp.swift               # BootstrapView creates VM; attaches modelContainer
├─ Domain/
│  ├─ Models/
│  │  ├─ Country.swift                    # Pure domain
│  │  └─ Currency.swift
│  ├─ Errors/
│  │  └─ DomainError.swift
│  └─ UseCases/
│     └─ GetAllCountries.swift
├─ Features/
│  └─ Countries/
│     ├─ Data/
│     │  ├─ DTOs/ (CountryDTO.swift, CurrencyDTO.swift)
│     │  ├─ Mapping/ (CountryMapper.swift)
│     │  └─ RepositoryImpl/ (CountriesRepositoryImpl.swift)
│     └─ Presentation/
│        ├─ View/ (CountriesListView.swift, CountryDetailView.swift)
│        └─ ViewModel/
│           ├─ CountriesListViewModel.swift
│           └─ Protocols/ (CountriesListViewModelingProtocol.swift)
├─ Infrastructure/
│  ├─ Network/
│  │  ├─ NetworkConfig.swift
│  │  ├─ APIRequest.swift
│  │  ├─ APIClient.swift
│  │  └─ APIError.swift
│  ├─ Location/
│  │  ├─ LocationProvidingProtocol.swift
│  │  └─ LocationProvider.swift
│  └─ SwiftData/
│     ├─ Models/ (CountrySD.swift, PinnedSD.swift)
│     ├─ Mapping/ (SwiftData+Mapping.swift)
│     ├─ Protocols/ (CountriesPersistence.swift)
│     └─ SwiftDataCountriesStore.swift
└─ Assets.xcassets/ (AppIcon, etc.)

---

## 🧩 Why This Layout?

- 🧠 Domain: framework-independent → fully testable
- 🔗 Data: isolates remote DTOs + mapping logic
- ⚙️ Infrastructure: framework integrations (Networking, SwiftData, CoreLocation)
- 🖥 Presentation: SwiftUI with a reactive ViewModel coordinating use cases and persistence



---

## 🌐 Networking

- APIRequest builds a fully configured URLRequest (path, method, query, body).
- APIClient.perform<T: Decodable>:
  • Accepts only 2xx success codes.
  • Maps all others to APIError:
      - .network(URLError.Code): Transport issues (no internet, timeout, etc.)
      - .http(Int): Server errors
      - .decoding: JSON decoding failure
  • Retries idempotent methods (GET, HEAD, PUT, DELETE)
    with exponential backoff on:
      - HTTP 5xx / 429
      - Transient URLErrors (timedOut, notConnectedToInternet, etc.)
      
      
      
---

## 💾 Persistence & Offline Mode

- SwiftData Models:
    • CountrySD → cache for countries (alpha2Code, name, capital, currencyCode)
    • PinnedSD  → stores pinned list order (max 5)
- Flow:
    1. ViewModel preloads cached data (instant UI)
    2. Fetches new data from network
    3. Upserts into SwiftData store
- Pinned list persists locally and syncs automatically on pin/unpin.

---

## 📍 Location Auto-Pin

- Uses CLLocationManager + reverse geocoding to detect user’s country.
- If access denied or lookup fails → defaults to Brazil (BR).
- Guarantees a non-empty “My Countries” section on first launch.

---

## 🧪 Testing & Coverage (≥85%)

Run Tests:
  • ⌘U (Product → Test)
  • Uses CountriesApp.xctestplan with Code Coverage = All Targets

Coverage:
  • Achieved ~85% total coverage
  • Validated via Report Navigator → Coverage Tab
  • Tested layers:
      - APIClient (success, error, retry)
      - Repository mapping
      - Domain UseCase
      - ViewModel logic (pinning, fallback, offline)
      
      
---

## ⚖️ License

MIT License — free to use, modify, and distribute.


---
© 2025 Haitham Gado. Built with ❤️ using SwiftUI.
