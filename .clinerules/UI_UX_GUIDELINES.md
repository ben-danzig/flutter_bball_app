# UI/UX Style Guide

This document defines the visual design language and user experience principles for the app to ensure a consistent and high-quality feel.

## 1. Design Philosophy

- **"At-a-Glance Clarity":** The user will be physically active and often several feet away from their phone. All in-workout interfaces must be instantly readable with large fonts, high contrast, and minimal clutter. The focus is on the essential information needed for the current task.

## 2. Color Palette

The app uses a dark theme to enhance focus and reduce eye strain in various lighting conditions.

- **Primary Background:** Dark Gray (`#111827`)
- **Card/Element Background:** Medium Gray (`#1f2937`)
- **Primary Text:** Off-White (`#f9fafb`)
- **Secondary/Muted Text:** Light Gray (`#9ca3af`)
- **Primary Accent:** Bright Blue (`#3b82f6`) - Used for buttons, progress bars, and interactive elements.
- **Destructive Action:** Red (`#ef4444`) - Used for "End Workout" buttons.
- **AI/Special Accent:** Purple/Violet (`#8B5CF6`) - Used to signify features powered by Gemini AI.

## 3. Typography

- **Font Family:** Inter (via Google Fonts).
- **Headings (H1):** 34pt, Black (900) weight.
- **Subheadings (H2):** 22pt, Bold (700) weight.
- **Body Text:** 16pt, Regular (400) weight.
- **In-Workout Numbers (Timers/Counters):** 72-96pt, Black (900) weight. Designed to be the focal point of the screen.

## 4. Component Styles

- **Buttons (Primary Action):** Full-width, bold white text, blue background (`#3b82f6`), large corner radius (`rounded-full`), significant vertical padding. Should have a subtle "pulse" animation when it's the primary call to action (e.g., "LOG SET").
- **Cards (e.g., Workout Library):** Dark gray background (`#1f2937`), large corner radius (`rounded-xl`), subtle border (`#4b5563`), and generous internal padding.
- **Input Fields:** Dark background (`#1f2937`), subtle border, and clear placeholder text.
- **Active Drill Screen Layout:** Follows a consistent 3-part structure:
    1.  **Top Context Bar:** Small text indicating the "Up Next" drill.
    2.  **Center Main Display:** The largest area, dedicated to the current drill's primary metric (timer or rep count).
    3.  **Bottom Control Bar:** Buttons for pausing, skipping, or logging the set.