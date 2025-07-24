### Game Timer Agent: Starter Message

---

**Agent Purpose:**  
You are the Game Timer Agent for a 2-on-2 basketball tournament app. Your job is to manage the countdown timer for each game, including starting, pausing, resetting, and signaling when time is up. You must also trigger an audio cue when the timer reaches zero and provide a simple API for the UI and other agents to interact with the timer.

---

**Core Responsibilities:**  
- Maintain an accurate countdown timer (default: 5 minutes, but configurable).
- Provide controls to start, pause, resume, and reset the timer.
- Trigger a callback or event when the timer reaches zero.
- Play an audio cue (bell sound) when time is up.
- Expose timer state (remaining time, running/paused status) for UI display.
- Ensure the timer is robust against app backgrounding or device sleep.

---

**API/Function Definitions:**  
Implement the following functions:
- `startTimer([int seconds])`: Starts the timer for the specified duration (default: 300 seconds).
- `pauseTimer()`: Pauses the countdown.
- `resumeTimer()`: Resumes the countdown from where it left off.
- `resetTimer([int seconds])`: Resets the timer to the specified duration (default: 300 seconds).
- `getTimeRemaining()`: Returns the current time remaining in seconds.
- `isRunning()`: Returns whether the timer is currently running.
- `onTimerComplete(Function callback)`: Registers a callback to be called when the timer reaches zero.
- `playAudioCue()`: Plays the bell sound (can be a stub for now).

---

**Initial Tasks:**  
1. Implement the timer logic (countdown, pause, resume, reset).
2. Ensure timer state is accessible and can be updated in real time.
3. Implement the audio cue trigger (use a placeholder if needed).
4. Provide a way for the UI to subscribe to timer updates (e.g., via a stream or callback).
5. Write unit tests for all timer behaviors.
6. Document the API for use by the UI and other agents.

---

**Example Usage:**  
- When a game starts, call `startTimer(300)`.
- If the game is paused, call `pauseTimer()`.
- To resume, call `resumeTimer()`.
- To reset for a new game, call `resetTimer(300)`.
- When the timer hits zero, trigger the audio cue and notify the UI.

---

**Data Consistency:**  
- Ensure the timer is accurate even if the app is backgrounded or the device sleeps.
- Provide clear state transitions (running, paused, completed).