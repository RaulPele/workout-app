# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WorkoutApp is a native iOS + watchOS fitness tracking application built with Swift 5 and SwiftUI. It allows users to build workout templates, track workout sessions via HealthKit, and sync data between iPhone and Apple Watch. Targets iOS 26.0+ and watchOS 26.0+.

## Build & Run

The project uses Xcode with no third-party dependencies (no CocoaPods, SPM, or Carthage).

```bash
# Open in Xcode
open WorkoutApp/WorkoutApp.xcodeproj

# Build iOS app from CLI
xcodebuild -project WorkoutApp/WorkoutApp.xcodeproj -scheme WorkoutApp -configuration Debug build

# Build watchOS app from CLI
xcodebuild -project WorkoutApp/WorkoutApp.xcodeproj -scheme "WatchWorkoutApp Watch App" -configuration Debug build
```

There are no test targets, linters, or CI pipelines configured.

## Architecture

### Layer Structure

**Coordinator → ViewModel → Repository → SwiftData/HealthKit**

- **Coordinators** manage navigation flows using `NavigationStack(path:)`. `RootCoordinator` → `MainCoordinator` (tabs) → per-tab `NavigationManager` instances.
- **ViewModels** use `@Observable` (never `ObservableObject`) and hold business logic for views. Combine publishers (`CurrentValueSubject`, `AnyPublisher`) handle reactive data flow.
- **Repositories** are protocol-based abstractions over data sources. `WorkoutLocalRepository` uses SwiftData; `WorkoutSessionAPIRepository` uses HealthKit. Mock implementations exist for previews/testing.
- **DTOs** (`WorkoutDTO`, `ExerciseDTO`) are `@Model` classes for SwiftData persistence. `SwiftDataConvertible` and `DomainConvertible` protocols handle domain↔DTO conversion.

### Dependency Injection

`DependencyContainer` (in `Utils/`) is the IoC container. All repositories and managers are registered at app startup and injected into coordinators/view models. `MockedDependencyContainer` provides test doubles.

### Key Source Locations

| Area | Path |
|------|------|
| iOS app source | `WorkoutApp/WorkoutApp/` |
| watchOS app source | `WorkoutApp/WatchWorkoutApp Watch App/` |
| Domain models | `WorkoutApp/WorkoutApp/Model/` |
| Repositories | `WorkoutApp/WorkoutApp/DataLayer/Repositories/` |
| SwiftData DTOs & manager | `WorkoutApp/WorkoutApp/DataLayer/` |
| Screen flows | `WorkoutApp/WorkoutApp/Flows/` |
| Shared UI components | `WorkoutApp/WorkoutApp/Reusables/` |
| Navigation infrastructure | `WorkoutApp/WorkoutApp/Utils/Navigation/` |

### iPhone ↔ Watch Communication

`WatchCommunicator` (iOS) and `PhoneCommunicator` (watchOS) handle cross-device sync using WatchConnectivity. The watch app has its own `WorkoutManager` for live session management with HealthKit workout sessions.

## Swift & SwiftUI Conventions

These conventions are enforced in this project (from `.cursor/rules/`):

- **Concurrency:** Mark `@Observable` classes with `@MainActor`. Use modern Swift concurrency (async/await) — never GCD (`DispatchQueue`). `SwiftDataManager` is an actor for thread safety.
- **SwiftUI:** Use `foregroundStyle()` not `foregroundColor()`. Use `clipShape(.rect(cornerRadius:))` not `cornerRadius()`. Use Tab API not `tabItem()`. Use `NavigationStack` not `NavigationView`. Use `Button` instead of `onTapGesture()` unless tap location/count is needed.
- **SwiftData with CloudKit:** No `@Attribute(.unique)`. Properties need defaults or optionality. Relationships must be optional.
- **General Swift:** Avoid force unwraps/try. Use `localizedStandardContains()` for text filtering. Prefer static member lookup (`.circle` not `Circle()`). Use `Task.sleep(for:)` not `Task.sleep(nanoseconds:)`.
- **View structure:** Extract subviews into separate `View` structs — do not use computed properties for view decomposition. Each type goes in its own Swift file.
- **No third-party frameworks** without asking first. Avoid UIKit unless explicitly requested.
