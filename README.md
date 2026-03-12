# WhatToEat

`WhatToEat` is an iOS app that helps users discover meals, filter by category/area/ingredient, view meal details, and save favorites.

This project is built as a **portfolio demonstration** to showcase SwiftUI, Clean Architecture, and modern Swift Concurrency in a production-style app structure.

## Demo Scope

This repository is intended for demonstration/portfolio purposes:
- clean layering and dependency injection
- async data flow with Swift Concurrency
- reusable SwiftUI components
- local persistence for favorites
- multilingual localization setup

## Features

- Meal of the day live-feed simulation
- Search meals by name
- Filter meals by:
  - category
  - area
  - ingredient
- Filtered result list with navigation to details
- Meal details (ingredients, instructions, YouTube link)
- Favorites:
  - add/remove
  - reorder
  - persistent storage via Core Data
- Localization in 5 languages:
  - English (`en`)
  - German (`de`)
  - Spanish (`es`)
  - French (`fr`)
  - Italian (`it`)

## Tech Stack

- **Language:** Swift 6
- **UI:** SwiftUI
- **State Management:** `@Observable` + `@State`
- **Architecture:** Clean Architecture + MVVM
- **Concurrency:** async/await, actors, AsyncSequence
- **Networking:** TheMealDB API (`https://www.themealdb.com`)
- **Persistence:** Core Data
- **Dependency Injection:** App container pattern (`AppContainer`)

## Architecture Overview

The app is organized into clear layers:

- `CleanArchitecture/Domain`
  - entities
  - repository/service protocols
  - use cases
- `CleanArchitecture/Data`
  - repository implementations
  - remote data source
  - core data favorites manager
  - persistence helpers
- `CleanArchitecture/Presentation`
  - SwiftUI views
  - view models
  - reusable UI components
  - alert and UI support models
- `CleanArchitecture/DI`
  - app composition root (`AppContainer`)
  - preview/mock composition
- `Networking`
  - endpoints
  - DTOs
  - response models
  - API service

## Build & Run

### Requirements

- Xcode 16+
- iOS 18.1+ Simulator/Device

Or open `WhatToEat.xcodeproj` in Xcode and run the `WhatToEat` scheme.

## Notes

- The live meal feed is a simulation (not a real push/live backend).
- Some app behavior and structure are intentionally designed to demonstrate architectural decisions for portfolio review.
