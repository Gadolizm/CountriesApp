# 🌍 CountriesApp

SwiftUI iOS app for the **REST Countries API** — search, view details, and pin up to 5 favorite countries.  
On first launch, the app automatically pins your **current country** using GPS (or defaults to **Brazil** if permission is denied).  
Supports **offline caching** via **SwiftData**, follows **Clean Architecture + MVVM**,  
and includes a robust **retrying network layer** with a focused **unit test suite (≥85% coverage)**.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Platform](https://img.shields.io/badge/Platform-iOS_16+-lightgrey)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20MVVM-blue)
![Coverage](https://img.shields.io/badge/Test%20Coverage-85%25-brightgreen)

---

## ⚙️ Tech Stack

- **Language:** Swift 5+
- **UI:** SwiftUI
- **Architecture:** Clean Architecture + MVVM (Domain + Service + Repository)
- **Networking:** Custom `APIClient` built on `URLSession` (with exponential backoff)
- **Persistence:** SwiftData (`CountrySD`, `PinnedSD`)
- **Location:** CoreLocation (reverse geocoding)
- **Testing:** XCTest + Test Plan + Mocks/Stubs/Fakes (`MockURLProtocol`, `FakeCountriesRemoteService`)

---

## ✨ Core Features

- 🔎 Search countries by name (case-insensitive)
- 📍 Auto-pin user’s country on first launch (fallback: Brazil)
- 📌 Pin up to 5 countries; swipe to remove
- 🏙 Country detail shows name, code, capital, and currency
- 📶 Offline mode (instant preload from cache → background refresh)
- ♻️ Robust networking with safe retries for idempotent requests (`GET`)
- 🧭 Custom app icon and adaptive dark mode support

---

## 🧱 Project Structure

```bash
CountriesApp/
├─ App/
│  └─ CountriesAppApp.swift                  # Entry point, builds dependencies & ViewModel
│
├─ Core/
│  ├─ Caching/
│  │  └─ SwiftData/ (CountrySD.swift, PinnedSD.swift, SwiftDataCountriesStore.swift)
│  ├─ Errors/ (AppError.swift)
│  ├─ Location/ (LocationProvider.swift, LocationProvidingProtocol.swift)
│  └─ Network/
│     ├─ APIClient.swift
│     ├─ APIRequest.swift
│     ├─ NetworkConfig.swift
│     └─ APIError.swift
│
├─ Features/
│  └─ Countries/
│     ├─ Data/
│     │  ├─ DTOs/ (CountryDTO.swift, CurrencyDTO.swift)
│     │  ├─ CountryMapper/ (CountryMapper.swift)
│     │  ├─ RepositoryImpl/
│     │  │  ├─ CountriesRepositoryImpl.swift
│     │  │  └─ PinnedRepositoryImpl.swift
│     │  └─ Service/
│     │     └─ CountriesRemoteServiceImpl.swift
│     │
│     ├─ Domain/
│     │  ├─ Models/ (Country.swift, Currency.swift)
│     │  ├─ Protocols/ (CountriesRepository.swift)
│     │  └─ UseCases/
│     │     ├─ GetAllCountriesUseCase.swift
│     │     ├─ LoadPinnedCodesUseCase.swift
│     │     └─ SavePinnedCodesUseCase.swift
│     │
│     ├─ Presentation/
│     │  ├─ View/
│     │  │  ├─ CountriesListView.swift
│     │  │  └─ CountryDetailView.swift
│     │  └─ ViewModel/
│     │     ├─ CountriesListViewModel.swift
│     │     └─ Protocols/ (CountriesListViewModelingProtocol.swift)
│     │
│     └─ CountryDetail/
│        └─ Presentation/ (CountryDetailView.swift)
│
├─ CountriesAppTests/
│  ├─ Countries/
│  │  ├─ Data/ (CountriesRepositoryImplTests.swift)
│  │  ├─ Domain/ (GetAllCountriesUseCaseTests.swift)
│  │  └─ Presentation/
│  │     └─ ViewModel/ (CountriesListViewModelTests.swift)
│  ├─ Networking/ (APIClientTests.swift)
│  └─ Support/ (FakeCountriesRemoteService.swift, InMemoryCountriesStore.swift)
│
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

## 💾 Persistence & Offline Caching (SwiftData)
    

- SwiftData Models:
    • CountrySD → cache for countries (alpha2Code, name, capital, currencyCode)
    • PinnedSD  → stores pinned list order (max 5)
- Flow:
    1.    Load cached countries instantly.
    2.    Fetch network updates → persist.
    3.    Sync pinned codes automatically.
- Offline-first design ensures a fast and consistent UX.

---

## 📍 Location Auto-Pin

- Uses CLLocationManager + reverse geocoding to detect user’s country.
- If access denied or lookup fails → defaults to Brazil (BR).
- Guarantees a non-empty “My Countries” section on first launch.

---

## 🧭 Highlights
    •    ✅ No force unwraps — all URLs and decoders handled safely.
    •    ✅ Resilient retries via exponential backoff.
    •    ✅ Offline-first ViewModel with cache preload.
    •    ✅ Test-first refactor to fully decoupled layers.
    •    ✅ Stable coverage ≥85%.
    
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
