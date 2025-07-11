import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bball_app/services/game_timer_service.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  group('GameTimerService', () {
    late GameTimerService timerService;

    setUp(() {
      timerService = GameTimerService();
      timerService.clearCallbacks(); // Clear any callbacks from previous tests
    });

    tearDown(() {
      timerService.resetTimer(); // Reset to stop any running timers
    });

    test('should have default values', () {
      expect(timerService.getTimeRemaining(), 300);
      expect(timerService.isRunning(), false);
      expect(timerService.getTotalSeconds(), 300);
      expect(timerService.getElapsedSeconds(), 0);
    });

    test('startTimer should initialize timer with specified duration', () {
      timerService.startTimer(120); // 2 minutes
      
      expect(timerService.getTimeRemaining(), 120);
      expect(timerService.isRunning(), true);
      expect(timerService.getTotalSeconds(), 120);
    });

    test('startTimer should use default duration when no argument provided', () {
      timerService.startTimer();
      
      expect(timerService.getTimeRemaining(), 300);
      expect(timerService.isRunning(), true);
    });

    test('timer should count down each second', () {
      fakeAsync((async) {
        timerService.startTimer(5);
        
        expect(timerService.getTimeRemaining(), 5);
        
        async.elapse(const Duration(seconds: 1));
        expect(timerService.getTimeRemaining(), 4);
        
        async.elapse(const Duration(seconds: 1));
        expect(timerService.getTimeRemaining(), 3);
        
        async.elapse(const Duration(seconds: 3));
        expect(timerService.getTimeRemaining(), 0);
        expect(timerService.isRunning(), false);
      });
    });

    test('pauseTimer should stop the countdown', () {
      fakeAsync((async) {
        timerService.startTimer(10);
        
        async.elapse(const Duration(seconds: 2));
        expect(timerService.getTimeRemaining(), 8);
        
        timerService.pauseTimer();
        expect(timerService.isRunning(), false);
        
        // Time passes but timer shouldn't change
        async.elapse(const Duration(seconds: 3));
        expect(timerService.getTimeRemaining(), 8);
      });
    });

    test('resumeTimer should continue from where it left off', () {
      fakeAsync((async) {
        timerService.startTimer(10);
        
        async.elapse(const Duration(seconds: 3));
        timerService.pauseTimer();
        expect(timerService.getTimeRemaining(), 7);
        
        timerService.resumeTimer();
        expect(timerService.isRunning(), true);
        
        async.elapse(const Duration(seconds: 2));
        expect(timerService.getTimeRemaining(), 5);
      });
    });

    test('resetTimer should reset to specified duration', () {
      fakeAsync((async) {
        timerService.startTimer(60);
        
        async.elapse(const Duration(seconds: 10));
        expect(timerService.getTimeRemaining(), 50);
        
        timerService.resetTimer(180); // Reset to 3 minutes
        expect(timerService.getTimeRemaining(), 180);
        expect(timerService.isRunning(), false);
        expect(timerService.getTotalSeconds(), 180);
      });
    });

    test('resetTimer should use default duration when no argument provided', () {
      timerService.startTimer(60);
      timerService.resetTimer();
      
      expect(timerService.getTimeRemaining(), 300);
    });

    test('onTimerComplete callback should be called when timer reaches zero', () {
      fakeAsync((async) {
        bool callbackCalled = false;
        
        timerService.onTimerComplete(() {
          callbackCalled = true;
        });
        
        timerService.startTimer(2);
        
        async.elapse(const Duration(seconds: 2));
        
        expect(callbackCalled, true);
        expect(timerService.getTimeRemaining(), 0);
        expect(timerService.isRunning(), false);
      });
    });

    test('multiple callbacks should all be called when timer completes', () {
      fakeAsync((async) {
        int callbackCount = 0;
        
        timerService.onTimerComplete(() => callbackCount++);
        timerService.onTimerComplete(() => callbackCount++);
        timerService.onTimerComplete(() => callbackCount++);
        
        timerService.startTimer(1);
        async.elapse(const Duration(seconds: 1));
        
        expect(callbackCount, 3);
      });
    });

    test('should notify listeners when state changes', () {
      int notificationCount = 0;
      
      timerService.addListener(() {
        notificationCount++;
      });
      
      timerService.startTimer(5);
      expect(notificationCount, 1);
      
      timerService.pauseTimer();
      expect(notificationCount, 2);
      
      timerService.resumeTimer();
      expect(notificationCount, 3);
      
      timerService.resetTimer();
      expect(notificationCount, 4);
    });

    test('timer stream should emit remaining seconds', () {
      fakeAsync((async) {
        final List<int> emittedValues = [];
        
        timerService.timerStream.listen((seconds) {
          emittedValues.add(seconds);
        });
        
        timerService.startTimer(3);
        
        async.elapse(const Duration(seconds: 3));
        
        // Should emit 2, 1, 0 (not 3 because stream emits after decrement)
        expect(emittedValues, [2, 1, 0]);
      });
    });

    test('getElapsedSeconds should return correct elapsed time', () {
      fakeAsync((async) {
        timerService.startTimer(60);
        
        expect(timerService.getElapsedSeconds(), 0);
        
        async.elapse(const Duration(seconds: 15));
        expect(timerService.getElapsedSeconds(), 15);
        
        async.elapse(const Duration(seconds: 10));
        expect(timerService.getElapsedSeconds(), 25);
      });
    });

    test('starting a new timer should cancel previous timer', () {
      fakeAsync((async) {
        timerService.startTimer(10);
        
        async.elapse(const Duration(seconds: 3));
        expect(timerService.getTimeRemaining(), 7);
        
        // Start a new timer
        timerService.startTimer(20);
        expect(timerService.getTimeRemaining(), 20);
        
        async.elapse(const Duration(seconds: 2));
        expect(timerService.getTimeRemaining(), 18);
      });
    });

    test('clearCallbacks should remove all callbacks', () {
      fakeAsync((async) {
        int callbackCount = 0;
        
        timerService.onTimerComplete(() => callbackCount++);
        timerService.onTimerComplete(() => callbackCount++);
        
        timerService.clearCallbacks();
        
        timerService.startTimer(1);
        async.elapse(const Duration(seconds: 1));
        
        expect(callbackCount, 0);
      });
    });

    test('removeCallback should remove specific callback', () {
      fakeAsync((async) {
        bool callback1Called = false;
        bool callback2Called = false;
        
        void callback1() => callback1Called = true;
        void callback2() => callback2Called = true;
        
        timerService.onTimerComplete(callback1);
        timerService.onTimerComplete(callback2);
        
        timerService.removeCallback(callback1);
        
        timerService.startTimer(1);
        async.elapse(const Duration(seconds: 1));
        
        expect(callback1Called, false);
        expect(callback2Called, true);
      });
    });

    test('timer should not count down when not running', () {
      fakeAsync((async) {
        timerService.resetTimer(10); // Reset without starting
        
        expect(timerService.isRunning(), false);
        expect(timerService.getTimeRemaining(), 10);
        
        async.elapse(const Duration(seconds: 5));
        expect(timerService.getTimeRemaining(), 10); // Should not change
      });
    });

    test('resumeTimer should not start if timer is at zero', () {
      fakeAsync((async) {
        timerService.startTimer(1);
        
        async.elapse(const Duration(seconds: 1));
        expect(timerService.getTimeRemaining(), 0);
        expect(timerService.isRunning(), false);
        
        timerService.resumeTimer();
        expect(timerService.isRunning(), false);
      });
    });

    test('pause should be idempotent', () {
      timerService.startTimer(10);
      expect(timerService.isRunning(), true);
      
      timerService.pauseTimer();
      expect(timerService.isRunning(), false);
      
      // Pausing again should not cause issues
      timerService.pauseTimer();
      expect(timerService.isRunning(), false);
    });

    test('resume should be idempotent when already running', () {
      timerService.startTimer(10);
      expect(timerService.isRunning(), true);
      
      // Resuming when already running should not cause issues
      timerService.resumeTimer();
      expect(timerService.isRunning(), true);
    });
  });
}