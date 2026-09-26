GENERAL GAME REQUIREMENTS DOCUMENT
Arrow Escape — Single-Player 2D Puzzle Game
5
ARROW ESCAPE

Find the Path. Tap to Escape. Clear the Board.

General Requirements Document (GRD) · Version 1.0

1. Document Overview

Attribute

	

Description




Product Name

	

Arrow Escape (Working Title)




Product Type

	

Casual Puzzle Game




Platform

	

Android (Primary)




Game Mode

	

Single-Player




Game Perspective

	

2D Top-Down




Genre

	

Logic / Spatial Reasoning / Casual Puzzle




Target Audience

	

Casual mobile gamers




Gameplay Style

	

Tap, Analyze, Escape, Clear




Connectivity

	

Offline-first




Game Engine

	

Godot Engine 4.x




Programming Language

	

GDScript




Monetization

	

Optional Ads / Rewarded Ads




Backend

	

Not required for initial release




Distribution

	

Google Play Store

2. Product Vision
2.1 Product Description

Arrow Escape is a relaxing yet engaging single-player puzzle game that transforms simple taps into rewarding logical challenges.

Players encounter a board filled with directional arrows. Each arrow must escape the board by following its direction, but other arrows may block its path.

The player's objective is to identify a clear path, determine the correct order of moves, and gradually remove every arrow from the board.

Each successful move brings the player closer to a clean, empty board and a satisfying level-completion experience.

The game combines:

Simple one-tap controls.

Spatial reasoning and logical planning.

Progressive difficulty.

Smooth animations and satisfying feedback.

A relaxing visual and audio experience.

Short, accessible gameplay sessions.

2.2 Core Product Promise

Simple to understand. Rewarding to solve. Relaxing to play.

The game should challenge the player's reasoning without creating unnecessary frustration or overwhelming complexity.

2.3 Product Objectives

Deliver intuitive gameplay that players can understand within seconds.

Create increasingly engaging puzzles through carefully designed level progression.

Make every successful arrow removal visually and emotionally rewarding.

Support offline single-player gameplay.

Maintain smooth performance across a broad range of Android devices.

Encourage continued play through progression, achievements, and optional challenges.

Provide a maintainable architecture for future content and feature expansion.

3. Game Concept & Core Gameplay
3.1 Gameplay Overview
6

The game presents a grid-based puzzle board containing multiple arrows pointing in different directions.

Each arrow occupies a position on the board and follows a defined movement direction.

When the player taps an arrow:

The game checks whether its path is clear.

If the path is unobstructed, the arrow moves out of the board.

If another arrow blocks the path, the move is rejected or the arrow provides a gentle blocked feedback.

Successfully removed arrows create new opportunities for other arrows to escape.

The player must determine the correct sequence of moves to clear the entire board.

3.2 Core Gameplay Loop

1. Observe the Puzzle

Analyze arrow directions and blocking relationships.

2. Select an Arrow

Tap an arrow that has a clear escape path.

3. Validate the Move

Check the path and determine whether the arrow can escape.

4. Execute the Move

Animate the arrow leaving the board and update the grid.

5. Re-evaluate the Board

Identify newly available escape paths.

6. Clear the Board

Complete the level and unlock the next challenge.
3.3 Game Rules

Rule

	

Requirement




Arrow Direction

	

Each arrow has one defined direction.




Arrow Movement

	

Arrows move along their direction.




Path Validation

	

An arrow cannot escape through an occupied path.




Successful Move

	

The arrow exits the board and is removed.




Blocked Move

	

The arrow remains on the board.




Board Update

	

Successful removal updates the occupancy grid.




Level Completion

	

All arrows must be removed.




Progression

	

Completing a level unlocks the next level.




Failure

	

No permanent failure state is required in the base game.

Important Gameplay Design Decision

The game should distinguish between:

Blocked arrow: The selected arrow cannot currently escape.

Available arrow: Its escape path is clear.

Completed board: No arrows remain.

The initial release should not punish players heavily for incorrect taps. Gentle feedback is preferred to preserve the relaxing gameplay experience.

4. Functional Requirements
FR-01: Main Menu

The main menu is the primary entry point into the game.

Required Features

Game logo and title.

Play / Continue button.

Level selection.

Settings.

Sound toggle.

Music toggle.

Progress display.

Optional daily challenge entry.

Privacy policy and credits access.

Acceptance Criteria

Player can start or continue a game from the main menu.

Previously unlocked progress is retained.

Menu navigation works correctly on supported Android screen sizes.

FR-02: Puzzle Board

The puzzle board is the central gameplay interface.

Required Features

Dynamic grid layout.

Directional arrows.

Consistent spacing and alignment.

Visual distinction between available and blocked arrows.

Touch-responsive arrow selection.

Board resizing for different screen dimensions.

Smooth arrow exit animations.

Acceptance Criteria

Every arrow occupies a valid grid position.

No two arrows occupy the same cell unless a future mechanic explicitly permits it.

Arrow direction is visually identifiable.

The board remains usable on small Android displays.

FR-03: Arrow Movement & Path Validation

This is the primary game mechanic.

Required Features

Detect selected arrow.

Identify arrow direction.

Calculate its escape path.

Check all relevant occupied cells.

Determine whether the path is clear.

Animate successful movement.

Reject blocked movement.

Update grid occupancy after successful escape.

Acceptance Criteria

An arrow exits only when its path is clear.

Blocked arrows do not disappear.

Grid state updates correctly after each successful move.

Rapid repeated taps cannot execute duplicate moves.

Movement validation remains deterministic.

FR-04: Level Management
Required Features

Level loading.

Level configuration.

Level completion detection.

Next-level unlocking.

Replay completed levels.

Level progress persistence.

Level difficulty metadata.

Acceptance Criteria

Each level loads its configured arrow arrangement.

Completion unlocks the appropriate next level.

Restarting a level restores its original board state.

Progress survives app closure and reopening.

FR-05: Level Completion
Required Features

Detect when all arrows have exited.

Play completion animation.

Display a success message.

Show move count and optional performance rating.

Provide Next Level and Replay actions.

Save completion progress.

Acceptance Criteria

Completion triggers exactly once per level session.

The player cannot accidentally trigger multiple completion rewards.

The next level becomes accessible after completion.

FR-06: Hint System

Hints should support players without removing the core challenge.

Required Features

Hint button.

Identify one valid arrow.

Visually highlight the suggested arrow.

Optional hint animation.

Optional limited rewarded hints in future versions.

Acceptance Criteria

A hint identifies an arrow that is actually removable.

Hint usage does not corrupt the board state.

The game remains playable after using a hint.

FR-07: Undo and Restart

Feature

	

Behavior




Undo

	

Restore the previous board state, if enabled




Restart

	

Restore the original level configuration




Pause

	

Stop gameplay interactions and show pause menu




Resume

	

Return to the active puzzle




Exit

	

Return to main menu with progress preserved

Recommended MVP decision: Include Restart and Pause in the first release. Undo can be introduced as an optional enhancement.

FR-08: Progression & Rewards
Required Features

Level completion tracking.

Unlocked level tracking.

Total levels completed.

Optional stars or performance ratings.

Achievement milestones.

Daily challenge support as a future feature.

Reward Philosophy

Rewards should reinforce progress and satisfaction rather than pressure players into continuous engagement.

5. User Interface & User Experience Requirements
5.1 Design Direction

The visual experience should feel:

Minimal.

Calm.

Modern.

Colorful without excessive visual noise.

Easy to understand.

Comfortable for extended casual sessions.

Suggested Visual Style
5
Suggested Color Palette

Element

	

Suggested Color




Background

	

Soft cream #F7F5EF




Board

	

Light gray #E9E8E2




Primary Arrow

	

Blue #5596E6




Secondary Arrow

	

Coral #F28B82




Accent

	

Soft yellow #F6D365




Success

	

Mint #7BCFA6




Text

	

Dark slate #30343B

Colors should remain configurable through a centralized theme system.

5.2 Required Screens

Screen 1 — Main Menu

Game branding, Play, Continue, Level Selection, Settings and optional Daily Challenge.

Screen 2 — Gameplay

Puzzle board, level number, move counter, hint, restart and pause controls.

Screen 3 — Pause Menu

Resume, Restart, Settings and Main Menu.

Screen 4 — Level Complete

Success animation, move count, optional stars, Next Level and Replay.

Screen 5 — Settings

Sound, music, haptics, accessibility and privacy options.

6. Non-Functional Requirements
NFR-01: Performance

Target 60 FPS on supported devices where feasible.

Minimize unnecessary node updates and rendering work.

Use lightweight 2D assets.

Avoid expensive per-frame calculations for static puzzle elements.

Maintain responsive touch interactions.

Avoid noticeable input latency.

NFR-02: Compatibility

Android smartphone support.

Responsive portrait layouts.

Support a defined minimum Android version based on the release build configuration.

Handle different aspect ratios and screen densities.

Support system navigation and safe areas.

NFR-03: Reliability

Prevent duplicate movement execution.

Preserve player progress.

Handle interruptions and app lifecycle changes.

Recover safely from incomplete save operations.

Avoid losing progress during ordinary app closure.

NFR-04: Accessibility

Clear visual direction indicators.

Sufficient contrast.

Large touch targets.

Optional sound and haptic controls.

Avoid relying exclusively on color to communicate arrow status.

Respect Android system accessibility settings where feasible.

NFR-05: Security & Privacy

No unnecessary collection of personal data.

Store local progress safely within application storage.

Use official Google Play billing APIs for purchases.

Provide a privacy policy if ads, analytics or third-party SDKs collect data.

Clearly disclose data collection practices.

7. Technical Architecture
7.1 Recommended Technology Stack
Arrow Escape — Technical Stack

Godot Engine 4.x

Primary game engine and 2D rendering
Language	GDScript
Platform	Android
Rendering	Godot 2D Renderer
UI	Godot Control Nodes
Animation	AnimationPlayer / Tween
Level Data	JSON / Godot Resources
Local Storage	ConfigFile / JSON
Audio	Godot Audio Buses
Version Control	Git + GitHub
Build	Android APK / AAB
Backend	Not required for MVP
7.2 High-Level Architecture
7.3 Core Systems
GameManager

Responsible for:

Current game state.

Active level.

Game initialization.

Pause and resume.

Completion detection.

Coordination between gameplay systems.

GridManager

Responsible for:

Grid dimensions.

Cell coordinates.

Arrow placement.

Occupancy tracking.

Board updates after arrow removal.

ArrowController

Responsible for:

Arrow direction.

Touch selection.

Movement animation.

Exit behavior.

Interaction state.

PathValidator

Responsible for:

Checking the arrow's escape direction.

Detecting occupied cells.

Returning valid or blocked movement results.

Supporting hint calculations.

LevelManager

Responsible for:

Loading level configurations.

Validating level data.

Tracking completion.

Unlocking levels.

Restarting puzzles.

SaveManager

Responsible for:

Saving unlocked levels.

Saving completed levels.

Persisting settings.

Restoring progress at startup.

8. Level Design & Difficulty Strategy

Level design is one of the most important parts of this product.

The game should introduce new challenges gradually rather than increasing difficulty only by adding more arrows.

8.1 Difficulty Progression

Stage

	

Level Range

	

Design Strategy




Tutorial

	

1–5

	

Introduce basic arrow movement




Easy

	

6–20

	

Simple blocking relationships




Intermediate

	

21–50

	

Multiple dependencies




Advanced

	

51–100

	

Longer chains and constrained moves




Expert

	

101+

	

Complex arrangements and strategic planning

These are initial planning ranges and should be adjusted through playtesting.

8.2 Puzzle Design Principles

Every puzzle should have at least one valid solution.

The intended solution should be verified before release.

Difficulty should increase progressively.

Early levels should teach mechanics through play.

Avoid arbitrary difficulty spikes.

Provide occasional easier levels after challenging sequences.

Keep puzzle layouts readable on mobile screens.

8.3 Recommended Level Data Structure

Example JSON configuration:

{
  "level_id": 1,
  "grid_size": {
    "rows": 4,
    "columns": 4
  },
  "arrows": [
    {
      "id": "arrow_001",
      "row": 0,
      "column": 0,
      "direction": "right"
    },
    {
      "id": "arrow_002",
      "row": 0,
      "column": 1,
      "direction": "down"
    },
    {
      "id": "arrow_003",
      "row": 2,
      "column": 2,
      "direction": "left"
    }
  ],
  "difficulty": "easy"
}

This is a conceptual data format. Production levels should be validated for coordinate correctness, duplicate occupancy, valid directions and solvability.

8.4 Puzzle Solvability Validation

A dedicated validation system should be developed to verify that each level can be completed.

Recommended strategy:

Represent the board as a logical grid.

Identify all currently removable arrows.

Simulate removing one available arrow.

Recursively explore resulting board states.

Determine whether an empty board is reachable.

Store a verified solution sequence for hints and QA.

For large levels, use memoization and state hashing to avoid repeatedly evaluating identical board states.

9. Monetization Strategy

The first release should prioritize gameplay quality and retention rather than aggressive monetization.

9.1 Suggested Monetization Model

Feature

	

Strategy

	

Priority




Core Gameplay

	

Free

	

Mandatory




Rewarded Hint

	

Optional rewarded ad

	

Post-MVP




Rewarded Continue

	

Optional

	

Post-MVP




Remove Ads

	

One-time purchase

	

Optional




Cosmetic Themes

	

Optional purchase

	

Future




Daily Challenge

	

Free engagement feature

	

Future

Advertising Principles

Never interrupt an active arrow movement.

Avoid forced ads during the initial tutorial.

Do not make puzzle completion dependent on advertisements.

Provide optional rewarded ads with clear player consent.

Respect platform advertising and privacy requirements.

10. Development Strategy & Implementation Roadmap

Recommended development approach: Agile, milestone-based development with playable builds at each milestone.

Development Milestones

M1 — Product Planning & Technical Design

Foundation

Finalize GDD and gameplay rules.

Define game states and screen flows.

Design initial grid mechanics.

Establish Godot project architecture.

Define level data format.

M2 — Gameplay Prototype

Core Mechanics

Create grid rendering.

Implement arrow placement.

Implement touch selection.

Build path validation.

Implement arrow exit behavior.

Verify basic puzzle completion.

M3 — MVP Gameplay

Playable Build

Main menu.

Level loading.

Restart and pause.

Completion screen.

Local progress saving.

Initial tutorial levels.

M4 — Game Feel & UI Polish

User Experience

Smooth arrow animations.

Audio feedback.

Visual effects.

Responsive UI.

Settings.

Hint functionality.

M5 — Content & Progression

Content

Create and validate level library.

Implement difficulty progression.

Add level selection.

Add move counter and optional stars.

Test level solvability.

M6 — QA & Optimization

Release Preparation

Test low-end Android devices.

Validate save/load reliability.

Profile rendering and memory.

Test touch interactions.

Fix gameplay and UI bugs.

Validate release build.

M7 — Android Release

Launch

Configure app identity.

Prepare signed AAB.

Create store assets.

Complete privacy disclosures.

Test release candidate.

Publish through Google Play Console.

11. Quality Assurance & Testing Strategy
11.1 Functional Testing
Arrow moves only when its path is clear.
Blocked arrow remains in place.
Board occupancy updates correctly.
Completion triggers when all arrows are removed.
Restart restores the original board.
Pause and resume work correctly.
Level progression works.
Hints identify valid moves.
Save/load preserves progress.
11.2 Gameplay Testing
All tutorial levels are understandable.
Every level has a valid solution.
No unintended dead-end puzzles.
Difficulty progression feels consistent.
Incorrect taps provide clear feedback.
Animations do not interfere with input.
Players can understand the game without lengthy instructions.
11.3 Android Testing
Small-screen devices.
Different aspect ratios.
Low-memory devices.
App background and resume.
Screen rotation behavior.
Audio interruption handling.
Installation and update behavior.
Offline functionality.
Release build stability.
12. MVP Scope vs Future Enhancements

A controlled MVP is important to avoid unnecessary development complexity.

MVP — Version 1.0
Core Playable Game

Single-player offline gameplay.

2D arrow grid.

Tap-to-escape mechanics.

Path validation.

Initial level library.

Progressive difficulty.

Main menu and gameplay UI.

Restart and pause.

Level completion.

Local save system.

Basic animations and audio.

Android release build.

Version 1.1 — Engagement

Hint system.

Undo functionality.

Daily puzzle.

Achievements.

Optional rewarded hints.

Additional themes.

Version 2.0 — Expansion

Procedural level generation.

Advanced puzzle mechanics.

New arrow types.

Cloud progress synchronization.

Global leaderboard (optional).

Additional language support.

iOS release.

13. Risks & Mitigation Strategies

Risk

	

Mitigation




Unsolvable generated puzzles

	

Automated solvability validation




Difficulty spikes

	

Playtesting and progression tuning




Incorrect path detection

	

Unit tests for path validation




Repeated touch input

	

Input locking during animations




Lost player progress

	

Reliable save/load and recovery




Poor low-end performance

	

Early Android profiling




Confusing gameplay

	

Interactive tutorial




Excessive monetization friction

	

Optional, non-intrusive ads




Growing code complexity

	

Modular systems and documented interfaces

14. Definition of Done

The initial release will be considered ready when:

Core gameplay works reliably.
All included levels are solvable.
The complete player journey is implemented.
Game progress persists after app closure.
Touch controls work consistently.
Animations are smooth on target devices.
No critical gameplay bugs remain.
Android release build is tested.
Store assets and required disclosures are prepared.
The game meets the agreed performance and compatibility requirements.
15. Final Product Definition

Arrow Escape is a single-player, offline-first 2D Android puzzle game built with Godot Engine and GDScript.

Its core experience revolves around identifying unobstructed paths, tapping directional arrows in the correct order, and gradually clearing the board.

The product prioritizes intuitive controls, satisfying movement, thoughtful level progression, lightweight performance and a relaxing visual experience.

Its architecture will support future additions such as hints, daily puzzles, additional level packs, rewarded ads and procedural puzzle generation without requiring a complete redesign of the core gameplay system.