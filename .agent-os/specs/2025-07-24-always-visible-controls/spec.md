# Spec Requirements Document

> Spec: Always Visible Controls
> Created: 2025-07-24
> Status: Planning

## Overview

Implement a split priority layout system that ensures critical drill controls are always accessible and timers are large enough for distance viewing during basketball training. This addresses the current issue where primary action buttons (like "FINISH DRILL") get pushed off-screen by long drill descriptions, especially on mobile browsers.

## User Stories

### Primary Action Always Accessible

As a basketball player performing make-target-timed drills, I want the "FINISH DRILL" button to always be visible on screen, so that I can complete my drill without scrolling or searching for the button when I reach my target makes.

**Detailed Workflow:**
1. User starts a make-target-timed drill with a long description
2. Timer counts up and user tracks their makes
3. User reaches target makes (e.g., 20 shots)
4. User immediately sees "FINISH DRILL" button at the top of screen
5. User taps button to complete drill and advance to next one
6. No scrolling or hunting for controls required

### Distance-Readable Timer Display

As a basketball player training alone, I want the timer to be very large and clearly visible, so that I can see the time remaining from across the court or gym while actively performing drills.

**Detailed Workflow:**
1. User places phone on gym floor, chair, or table several feet away
2. User starts timed drill and moves to basketball court area
3. User can clearly read timer display from 6+ feet away on mobile device
4. User performs drill while periodically glancing at timer
5. Timer remains legible throughout entire drill duration

### Consistent Control Layout

As a user performing various drill types, I want control buttons to be in predictable locations, so that I can quickly access pause, skip, or end workout functions without thinking about where they are.

**Detailed Workflow:**
1. User performs multiple different drill types in sequence
2. Primary drill actions (LOG, FINISH) always appear at top
3. Secondary controls (PAUSE, SKIP, END) always appear at bottom
4. User develops muscle memory for control locations
5. Training flow is never interrupted by hunting for controls

## Spec Scope

1. **Split Priority Layout System** - Primary actions at top, secondary controls at bottom, drill content in flexible middle area
2. **Large Timer Display** - Minimum 150px font size for distance readability on mobile devices
3. **Responsive Primary Action Bar** - Top bar adapts to show drill-specific primary actions (FINISH, LOG SET, etc.)
4. **Fixed Secondary Control Bar** - Bottom bar with consistent layout: END, PREV, PAUSE, SKIP
5. **Adaptive Content Area** - Middle section that flexibly adjusts height to accommodate both control bars
6. **Cross-Platform Optimization** - Special handling for mobile browsers with reduced viewport height

## Out of Scope

- Gesture-based controls or swipe actions
- Voice control integration  
- Custom control positioning by user
- Animation effects for control transitions
- Tablet-specific layouts (will use responsive mobile approach)

## Expected Deliverable

1. **Primary Actions Always Visible** - Drill-specific buttons (FINISH DRILL, LOG SET) always appear at top of screen regardless of content length
2. **Distance-Readable Timers** - Timer displays use minimum 150px font size and remain clearly visible from 6+ feet away
3. **Consistent Control Access** - Secondary controls (PAUSE, END, SKIP, PREV) always accessible at bottom of screen across all drill types
4. **Mobile Browser Compatibility** - Layout works correctly in mobile browsers with browser chrome reducing available viewport height

## Spec Documentation

- Tasks: @.agent-os/specs/2025-07-24-always-visible-controls/tasks.md
- Technical Specification: @.agent-os/specs/2025-07-24-always-visible-controls/sub-specs/technical-spec.md
- Tests Specification: @.agent-os/specs/2025-07-24-always-visible-controls/sub-specs/tests.md 