# WhatToEat

`WhatToEat` is an iOS app that helps users discover meals, filter by category/area/ingredient, view meal details, and save favorites.

This project is built as a **portfolio demonstration** to showcase SwiftUI, Clean Architecture, and modern Swift Concurrency in a production-style app structure.

## Screenshots

<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 36 08" src="https://github.com/user-attachments/assets/2a3ac80e-0467-4cf0-9449-ce9e4dff874b" />
<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 36 17" src="https://github.com/user-attachments/assets/7dd80ce5-8dc6-4bd3-a266-0ff31c4eef74" />
<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 37 00" src="https://github.com/user-attachments/assets/0d393587-a185-479f-b853-3d2b582e8163" />
<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 36 41" src="https://github.com/user-attachments/assets/c492d9ac-ba62-4bc0-8ad4-8ef738adae44" />
<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 36 29" src="https://github.com/user-attachments/assets/d1659866-29e3-47fe-a627-c56f3400bc28" />
<img width="200" height="2622" alt="Simulator Screenshot - iPhone 16 Pro - 2026-03-12 at 17 37 17" src="https://github.com/user-attachments/assets/3e44bbf0-bfd6-4af6-8bd8-406764bb8207" />

![demo](https://github.com/user-attachments/assets/e44fcb89-64b3-4548-9930-82cb03f842a4)

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
