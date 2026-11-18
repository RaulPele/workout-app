# On-device tests

UI tests that drive the real iPhone and Apple Watch, for fixes that only show up on hardware: HealthKit
sessions, WatchConnectivity transfers, crash recovery, rest timers.

`DeviceTests.xcodeproj` is separate from the app project on purpose. Its two UI test targets launch the
**installed** apps by bundle ID, so the same tests run against any branch's build. Branches don't need any
test code merged in.

| Folder | What's in it |
|---|---|
| `PhoneUITests/` | iPhone tests (History) |
| `WatchUITests/` | Watch tests: `RedesignedWatchWorkoutTests` for the redesigned watch UI, `ClassicWatchWorkoutTests` for `main`'s |
| `Shared/` | Helpers compiled into both targets |
| `run-device-tests.sh` | Builds a branch, installs it on both devices, runs a suite, writes a report |

## Before a run

These need a person once; the tests never do them:

- **iPhone:** unlocked, on the same Wi-Fi as the Mac or plugged in. Set Auto-Lock to Never for long runs.
- **Watch:** off the charger and unlocked. Either wear it, or turn off Wrist Detection while testing. A locked watch fails the test runner with "Authentication canceled by user"; the script waits up to 5 minutes for you to unlock it, then retries once.
- **Signed in and Health access:** the iPhone app is signed in, and both apps have Health access.
- **Templates:** the watch has at least one workout template. Pick one with `TEMPLATE=<name>`; it needs 2+ sets in its first exercise.
- **No real workout open:** don't run while a real workout is open in the watch app.

## Running

```bash
DeviceTests/run-device-tests.sh --list
DeviceTests/run-device-tests.sh <suite> --app <checkout of the branch to test>
```

- `--app` defaults to this checkout.
- `--no-install` tests whatever is already installed.
- `TEMPLATE`, `IPHONE_ID` and `WATCH_ID` in the environment pick the template and the devices.
- A suite takes 10–30 minutes, mostly watch round trips over Wi-Fi.

| Suite | Branch it was written for | What it checks |
|---|---|---|
| `smoke` | any | Devices, signing and both test runners work |
| `watch-redesign` | `worktree-refactor+watch-app` | Ending from Controls keeps logged sets, and the summary opens on End. Rest countdown freezes while paused and ends by itself. A crash (SIGKILL) mid-workout keeps the logged sets. |
| `sessions-without-healthkit` | `fix/sessions-without-healthkit` | A watch session shows in History without waiting for a Health match. The detail always shows the heart-rate and calorie tiles. |
| `sync-reliability` | `fix/watch-sync-reliability` | The watch's template list survives the iPhone app starting. A workout sent while the iPhone app isn't running goes through the inbox into History. |

To get a baseline that shows a test can catch the bug, run the same suite with `--app` pointing at a
`main` checkout.

## Results

Each run writes `DeviceTests/.results/<timestamp>-<suite>/` (gitignored):

- `report.md`: one row per step, the notes the tests printed, and the workouts the run saved to Apple Health. **The tests never delete anything**, so delete those workouts yourself in the Fitness or Health app.
- `NN-<device>-<test>.xcresult` and `NN-...-attachments/`: screenshots, plus the element tree for every failure. When a label in a test doesn't match the app, the element tree shows what the app actually exposes.
- `NN-phone-files/`: files copied out of the iPhone app's container, for example the workout inbox.
- `app-build.log`, `tests-build-*.log`, `install-*.log`.

## Not covered

- **Switching to another Apple Watch:** needs a second paired watch.
- **Saving to Health failing:** a run would have to revoke Health access, which the tests won't do.
- **Rest ending with the screen off, and its haptic:** the test can't sense either.
- **A user force-quit:** the crash test uses SIGKILL, so the system can treat it as a crash.
- **The inbox's crash-mid-save race:** the test checks the path works end to end, not that the race is gone.
- **A session reaching History before its Health workout:** Health usually syncs the watch's workout to the iPhone within seconds, before the History check opens, so the History tests pass on `main`'s iPhone app too. They catch a session not arriving, not the wait for Health.
- **Whether a session went through the inbox file:** the iPhone app is woken in the background and empties the inbox within the 30 s wait, so the run sees the session saved, not the file it came through.

## Writing more tests

- **Launching:** launch apps with `XCUIApplication(bundleIdentifier:)`. Use `activate()` instead of `launch()` when the test must not kill a running instance.
- **Reading the screen:** read it with `app.screen()`, one snapshot per check; every query on the watch is a slow round trip. Icon buttons on the watch have their caption in a separate `Text`; use `app.button(above: "End")`.
- **Failing:** throw `failure("…", app:)`, which attaches a screenshot and the element tree.
- **Passing values:** pass values between steps by printing `RunReport.note(key, value)` in one test and reading `note_value key` in the suite. Note every workout a test saves with `RunReport.savedWorkout`.
