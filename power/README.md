# Power tuning

WiFi and audio-codec power save.

| Setting | After |
|---|---|
| WiFi power save (`wlan0`) | on |
| Audio codec power save (`snd_hda_intel`) | on, 1s idle timeout |

## Install
```bash
sudo ./install.sh
```

## Re-measuring
```bash
sudo powertop --html=report.html --time=15
```
