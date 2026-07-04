# PathSaathi AI 🚀

PathSaathi AI is a next-generation, premium educational application designed to empower students through an AI-driven learning experience. Built with Flutter, this app features a production-grade Feature-First architecture, modern glassmorphism design, and an intuitive user experience.

## ✨ Features
- **Premium Design System:** Built with custom themes, glassmorphism overlays, Micro-animations, and fluid transitions.
- **AI Chat Assistant:** A fully functional Chat AI that helps students answer questions, formatted with markdown support and typing indicators.
- **Smart Dashboard:** Track your daily goals, current streak, and XP with an interactive ring progress indicator.
- **Lessons & Quizzes:** Gamified learning experience with dynamic quiz states and a confetti celebration upon passing.
- **Camera OCR Tool:** A sleek scanning overlay mimicking a laser scanner, intended for AI-based homework help.
- **Feature-First Architecture:** Highly scalable and decoupled codebase, grouping screens, widgets, and logic by their respective domains.

## 🛠 Tech Stack
- **Framework:** Flutter (v3.30+) & Dart
- **Architecture:** Feature-First (Domain Driven)
- **State Management:** Provider
- **Navigation:** GoRouter with ShellRoute (Persistent Bottom Nav)
- **Styling:** Custom AppTheme (Inter & Poppins Typography), Flutter Animate

## 📂 Project Structure
```
lib/
├── core/                  # Core design tokens, global themes, and routing
├── features/              # Feature-driven modules (auth, dashboard, ai_chat, etc.)
│   ├── ai_chat/           
│   ├── auth/              
│   ├── dashboard/         
│   ├── lessons/           
│   ├── profile/           
│   ├── quizzes/           
│   └── splash/            
├── models/                # Data models
├── providers/             # Global Providers (Re-exported logic)
├── services/              # API and backend integrations
└── main.dart              # App Entry Point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Chrome (for web testing) or an Android/iOS Emulator

### Running the App
Since this is a Hackathon demo, the app is configured to use mock data and local storage by default to bypass Firebase configurations. 

1. Clone the repository.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on Chrome (Recommended for quick testing):
   ```bash
   flutter run -d chrome
   ```

## 🎨 Design Philosophy
Every screen was crafted with **aesthetics and accessibility** in mind. We avoided generic Material widgets in favor of customized `AppRadius`, `AppSpacing`, and `AppShadows` to give PathSaathi AI a premium, "Silicon Valley" feel, comparable to top-tier ed-tech products like Duolingo or Notion.

---
*Built with ❤️ for the Hackathon*
