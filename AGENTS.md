## Building and Testing

After making changes to the app, build and run it in the simulator:

```bash
./scripts/run.sh
```

This will also start logging simulator output to `simulator.log` in the repo.

To verify UI changes, take a screenshot of the simulator:

```bash
./scripts/screenshot.sh
```

Then read the screenshot to see how the app looks:

```bash
# Use the Read tool on /tmp/simulator-screenshot.png
```

To check app logs for debugging:

```bash
# Use the Read tool on simulator.log
```

To follow logs in real-time (in a separate terminal):

```bash
tail -f simulator.log
```

To stage App Store screenshots, run the helper (it automatically sets `APPSTORE_SCREENSHOT_MODE=1` so the app launches preloaded with Airbnb, Instagram, Spotify, and Uber):

```bash
./scripts/save_appstore_screenshots.sh
```

Images land in `fastlane/screenshots/en-US/` (gitignored).
