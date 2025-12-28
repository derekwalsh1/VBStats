# Flutter VBStats Implementation Progress

## ✅ Completed

### Project Setup
- Flutter project initialized with clean architecture
- Folder structure created: data/, domain/, presentation/, core/utils/
- Dependencies added to pubspec.yaml: Riverpod, Drift, SQLite, JSON serialization, utilities

### Domain Layer
- **Enums** ([lib/domain/entities/enums.dart](lib/domain/entities/enums.dart)):
  - `ServeReceiveState`: serve/receive state enum
  - `RallyOutcome`: 13 outcomes (5 we scored, 8 we lost)
  
- **Entities** ([lib/domain/entities/match_entities.dart](lib/domain/entities/match_entities.dart)):
  - `Match`: opponent, event name, date
  - `Set`: match ref, index, rotation, serve/receive state, scores
  - `Rally`: set ref, rally index, rotation, outcome, winner, timestamp

### Data Layer
- **Database Schema** ([lib/data/datasources/database/tables.dart](lib/data/datasources/database/tables.dart)):
  - Drift ORM tables: Matches, Sets, Rallies
  - Proper keys and constraints
  
- **Drift Database** ([lib/data/datasources/database/vbstats_database.dart](lib/data/datasources/database/vbstats_database.dart)):
  - Database class with CRUD queries for matches, sets, rallies
  - Cascade delete logic
  - Code generation completed (vbstats_database.g.dart created)

- **Repository** ([lib/data/repositories/match_repository_impl.dart](lib/data/repositories/match_repository_impl.dart)):
  - Implements `MatchRepository` interface
  - Full CRUD operations for all entities
  - UUID-based IDs

### Core Utilities
- **Set Logic** ([lib/core/utils/set_logic.dart](lib/core/utils/set_logic.dart)):
  - `RotationManager`: rotation advancement (1-6 wrap), position names
  - `SetStateManager`: manages serve/receive and rotation state after each rally
  - `RotationStatsComputer`: rotation-specific sideout % and point-scoring %

- **Momentum Calculator** ([lib/core/utils/momentum_calculator.dart](lib/core/utils/momentum_calculator.dart)):
  - `MomentumComputer`: computes momentum chart points and detects runs
  - Run detection: 3+ consecutive points in same direction
  - Rally outcome labels and tracking

- **Stats Calculator** ([lib/core/utils/stats_calculator.dart](lib/core/utils/stats_calculator.dart)):
  - `SetStatsComputer`: aggregates all stats for a set
  - Outcome counts (aces, kills, blocks, errors)
  - Overall sideout %, point-scoring %, and ratios
  - Ace:Service Error and Ace:Receive Error ratios

### Presentation Layer
- **Database Providers** ([lib/presentation/providers/database_providers.dart](lib/presentation/providers/database_providers.dart)):
  - Riverpod providers for database and repository
  - SQLite database initialization with path_provider
  
- **Home Screen** ([lib/presentation/screens/home_screen.dart](lib/presentation/screens/home_screen.dart)):
  - Basic scaffold with "New Match" and "View Matches" buttons
  - Ready for navigation to detailed screens

- **Main App** ([lib/main.dart](lib/main.dart)):
  - ProviderScope setup
  - Material theme with deepOrange seed color
  - Home screen as root

## 🚀 Next Steps (Ready to Build)

### 1. Match Management Screens
- New Match form (opponent name, event name, date)
- Match list with per-set summaries
- Match detail view with sets

### 2. Set Management
- Add Set dialog (start rotation 1-6, serve/receive toggle)
- Set detail with live logging

### 3. Live Set Logging Screen (MVP Focus)
- **Two-pane layout (tablet-first)**:
  - **Left pane**: Score display, serve/receive state, current rotation, quick outcome buttons (Won via Ace/Kill/Block/Opp Error/Fault, Lost via SE/RE/BE/DE/CE/RV/FBE/AE), undo/redo
  - **Right pane**: Live stats panel (totals, ratios), rotation splits (sideout %, point-scoring %), momentum step chart with labeled reasons and run highlights
- Undo/redo stack management
- Edit rally dialog

### 4. Set & Match Review Screens
- Set summary: totals, rotation breakdown, momentum chart
- Match summary: aggregate stats across sets

### 5. Export/Import
- JSON export per match (metadata + rallies)
- JSON import to restore matches

### 6. Phone Optimization
- Collapse two-pane to single column layout
- Adjust font sizes and button layout for smaller screens

## 📊 Architecture Summary
- **Data**: Drift SQLite with proper schema, repository pattern for abstraction
- **Domain**: Entities and enums; business logic in core/utils
- **Presentation**: Riverpod state management, Material Design, tablet-optimized layouts
- **Offline**: All data stored locally; no cloud dependency in MVP
- **Tech Stack**: Flutter, Drift, Riverpod, SQLite, Material 3

## 🎯 Key Assumptions (Confirmed)
- Rotation on losing while serving: switch to receive, no rotation
- Rotation on losing while receiving: stay receiving, rotate
- Sideout %: rallies starting in receive that we win / all receive rallies
- Point-scoring %: rallies starting in serve that we win / all serve rallies
- Momentum runs: 3+ points in same direction
- Short outcome codes: Ace, Kill, Block, OE, SE, RE, BE, DE, CE, RV, FBE, AE
- Sets labeled 1, 2, 3... in creation order
- Tablet two-pane layout with mobile collapse
