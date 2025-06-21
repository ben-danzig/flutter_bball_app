# AI-Assisted Development Workflow (The TDD-AI Loop)

This document outlines a structured workflow for building the MVP using VS Code and an AI coding agent like `cline`. The goal is to leverage the AI as an efficient "pair programmer," where it handles the boilerplate and implementation details, while you provide the architectural direction and quality validation.

## The Core Philosophy: Test-Driven, AI-Assisted

We will use a variation of Test-Driven Development (TDD). The cycle is simple but powerful:

1.  **Think & Plan (Human):** Select the next un-checked task from `PLAN.md`. Read the description, inputs, outputs, and validation criteria.
2.  **Write the Test (Human):** Before writing any implementation code, open the relevant `_test.dart` file and write the automated test described in the task's `Validation` section. **Run the test and watch it fail.** This is expected and confirms your test is working correctly.
3.  **Prompt the AI (Human -> AI):** Open the `cline` chat window. Craft a clear, specific prompt based on the task description.
4.  **Generate the Code (AI):** Let the AI generate the necessary Dart/Flutter code. `cline` will suggest changes directly in your editor.
5.  **Validate & Refine (Human & AI):**
    * Accept the code changes suggested by the AI.
    * Run the test you wrote in Step 2.
    * If the test passes, the task is complete! Review the code for style and logic.
    * If the test fails, **copy the error message from the test output and paste it into `cline`**. Ask the AI to fix the bug. Repeat until the test passes.
6.  **Commit (Human):** Once the test passes and you are happy with the code, commit the changes to Git with a message referencing the task ID (e.g., `git commit -m "feat(T2.2): Implement navigation to detail screen"`).
7.  **Check it off!** Go back to `PLAN.md` and mark the task as complete: `- [x] T2.2: ...`

## How to Write Effective Prompts for `cline`

`cline` is file-aware, so you can reference files directly. The key to good results is providing clear context.

**Bad Prompt (Vague):**
> "make the workout card tappable"

**Good Prompt (Specific & Contextual):**
> "In `lib/screens/library/workout_library_screen.dart`, I need to modify the `_WorkoutCard` widget.
>
> 1. Wrap the `Container` of the card with a `GestureDetector` to make it tappable.
> 2. For the `onTap` property, use `Navigator.push()` to navigate to a new screen.
> 3. The new screen should be a simple placeholder `Scaffold` for now called `WorkoutDetailScreen`, which we will create in the next task."

## Example Walkthrough: Task T2.2

Here’s how you would apply the workflow to the next task in your plan.

**1. Think & Plan (Human):**
> "Okay, next up is **T2.2: Implement Navigation to Detail Screen**. I need to make the workout card from T2.1 navigate to a new screen when I tap it."

**2. Write the Test (Human):**
> Open `test/screens/library_screen_test.dart`. Add a new `testWidgets` block:
> ```dart
> testWidgets('tapping workout card navigates to detail screen', (WidgetTester tester) async {
>   await tester.pumpWidget(const MaterialApp(home: WorkoutLibraryScreen()));
>   await tester.pumpAndSettle(); // Wait for data to load
>
>   // Find the card and tap it
>   final cardFinder = find.byType(_WorkoutCard); // Assuming _WorkoutCard is accessible
>   expect(cardFinder, findsOneWidget);
>   await tester.tap(cardFinder);
>   await tester.pumpAndSettle(); // Wait for navigation animation
>
>   // Verify the new screen is shown
>   expect(find.byType(WorkoutDetailScreen), findsOneWidget); // This will fail initially
> });
> ```
> *You'd need to create a dummy `WorkoutDetailScreen` class first for this test to compile.* Run the test and watch it fail.

**3. Prompt the AI (Human -> AI):**
> Open `cline` and use the "Good Prompt" example from above. You would also tell it to create the dummy `WorkoutDetailScreen` file if needed.

**4. Generate the Code (AI):**
> `cline` suggests changes to `workout_library_screen.dart`, wrapping your `_WorkoutCard`'s `Container` in a `GestureDetector` or `InkWell` and adding the `onTap` callback with the `Navigator.push()` logic.

**5. Validate & Refine (Human & AI):**
> Run the test again. It should now pass. You can also run the app on your emulator and manually tap the card to see it navigate.

**6. Commit (Human):**
> In the terminal:
> ```bash
> git add .
> git commit -m "feat(T2.2): Make workout card navigable"
> ```

**7. Check it off!**
> Open `PLAN.md` and change the line for T2.2 to `- [x]`.

This structured process makes development fast, reliable, and keeps you in complete control, using the AI as a tool to execute your well-defined plan.