<!-- Workspace-specific instructions for GitHub Copilot -->

# VBStats Flutter Project

## Project Overview
Flutter app for volleyball team stats tracking. Tablet-optimized for iOS/Android with offline-first SQLite storage.

## Architecture
- Clean architecture: data/, domain/, presentation/ layers
- State management: Provider or Riverpod
- Database: SQLite via Drift ORM
- Offline-first with JSON export/import

## Key Features
- Team-level rally outcome logging
- Rotation and serve/receive tracking
- Live stats with momentum step chart
- Sideout % and point-scoring % per rotation
- Match and set review screens

## Development Guidelines
- Use Drift for all database operations
- Follow Material Design for tablet layouts
- Implement undo/redo for rally logging
- All features must work offline
- Export/import via JSON
