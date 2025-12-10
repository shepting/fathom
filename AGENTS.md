**Before doing any planning or making any lists, run `bd onboard` and follow the instructions.**

## Building and Testing

After making changes to the app, build and run it in the simulator:

```bash
./run.sh
```

This will also start logging simulator output to `simulator.log` in the repo.

To verify UI changes, take a screenshot of the simulator:

```bash
./screenshot.sh
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
