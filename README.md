# MQ Fault Diagnosis Workshop (MATLAB + Arduino)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)
![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-blue)
![Arduino](https://img.shields.io/badge/Arduino-Mega2560-informational)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

Hands-on teaching kit for **fault detection & diagnosis** using **MQ gas sensors (MQ135, MQ2, MQ5)** and a **DHT11** with **MATLAB + Arduino**.  
Students collect real-time data, trigger LED alarms on threshold changes, and diagnose “faults” (step change, drift, sensor failure) with simple analytics.

> **Short description (for GitHub About):**  
> *Hands-on workshop for fault detection & diagnosis using MQ135/MQ2/MQ5 + DHT11 with MATLAB & Arduino.*

---

## ✨ What's Inside

- **Acquisition script**: real-time readout (3 min @ 2 s), LED alarm on ΔV threshold, guided pauses for Sample runs.
- **Lab manuals**: full instructor version + easy student version.
- **Workshop pack**: 3-hour agenda + printable student worksheet.
- **Post-lab analysis**: baseline/ΔV, **t90**, recovery time, **AUC** examples.
- **One-line setup**: `setup.m` adds subfolders to MATLAB path.

---

## 📁 Repository Layout

```
utils/                     # helper functions (on path via setup.m)
workshop/                  # workshop plan & student worksheet
dataset/                   # where .mat files are saved (empty in repo)
models/                    # where the trained models are saved (empty in repo)
main.mlx                   # main code
LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md, CITATION.cff
```

---

## 🔧 Prerequisites

**Hardware**
- Arduino **Mega 2560**
- MQ135 (A0), MQ2 (A1), MQ5 (A2)
- DHT11 (D7)
- LED + 220 Ω (D9 → GND)
- Breadboard, jumpers, USB cable

**Software**
- MATLAB (R2020b+ recommended)
- Arduino IDE
- MATLAB Support Package for Arduino Hardware
- Arduino libraries (install via Arduino IDE → Library Manager):
  - **Adafruit Unified Sensor**
  - **Adafruit DHT Sensor Library**

See **`docs/Appendix_Addons.md`** for a step-by-step install guide.

---

## ⚡ Quick Start

1. **Clone** this repo and open the repo **root** in MATLAB.
2. Run:
   ```matlab
   setup
   ```
3. Open **`matlab/main.m`** and set your serial port:
   ```matlab
   port = 'COM3';   % change to your actual port (e.g., 'COM4' or '/dev/tty.usbmodemXXXX')
   ```
4. **Wire the hardware** (table below).
5. **Run** the script. When prompted:
   - Enter `1` for **Blank** (ambient only), or
   - Enter `0` for **Sample** (guided pauses at **20 s** place / **120 s** remove).
6. At the end, save to `data/dataset/<name>.mat`.
7. Try the analysis examples:
   ```matlab
   open matlab/analysis_examples.m
   ```

---

## 🧷 Wiring (matches the code)

| Signal            | Arduino Mega | Sensor Pin        | Notes                                   |
|-------------------|--------------|-------------------|-----------------------------------------|
| MQ135 analog out  | A0           | AO                | VCC→5 V, GND→GND                        |
| MQ2 analog out    | A1           | AO                | VCC→5 V, GND→GND                        |
| MQ5 analog out    | A2           | AO                | VCC→5 V, GND→GND                        |
| DHT11 data        | D7           | DATA              | +5 V, GND (add 10 kΩ pull-up if needed) |
| LED (alarm)       | D9           | Anode via 220 Ω   | Cathode→GND                             |

> Tip: Let MQ sensors warm up **5–10 min** for better stability.

---

## 🧪 Running the Experiment

- **Blank test** (`1`): continuous ambient logging.
- **Sample test** (`0`):
  - **20 s** → *Place* sample near sensors (breath, sanitizer vapor, vinegar).
  - **120 s** → *Remove* sample.
- LED on **D9** blinks when any sensor deviates from its starting value by **> 0.15 V**  
  (change with `change_threshold` in `main.m`).

---

## 📊 Post-Lab Analysis (snippets)

Load and compute baseline & deltas:
```matlab
S = load('data/dataset/myrun.mat');
t = S.time_stamps(:);
V1 = S.sensor_data(1,:).'; % MQ135
V2 = S.sensor_data(2,:).'; % MQ2
V3 = S.sensor_data(3,:).'; % MQ5

i0 = t <= 10;
b1 = mean(V1(i0)); b2 = mean(V2(i0)); b3 = mean(V3(i0));
d1 = V1 - b1; d2 = V2 - b2; d3 = V3 - b3;
```

Find **t90** (time to 90% of peak) during exposure window (20–120 s):
```matlab
ts = 20; te = 120; idx = t >= ts & t <= te;
[pk2, ~] = max(d2(idx)); th = 0.9 * pk2;
iwin = find(idx); seg = iwin(1):iwin(end);
i90 = seg(find(d2(seg) >= th, 1));
t90_MQ2 = t(i90) - ts;
```

Area under curve (**AUC**) during exposure:
```matlab
AUC_MQ2 = trapz(t(idx), d2(idx));
```

---

## 🎓 Workshop in a Box (3-hour plan)

- **Intro (30 min):** fault detection → isolation → identification; industrial examples.
- **Setup (30 min):** wiring, Blank run.
- **Scenarios (60 min):**
  1) **Step change** (breath) → MQ135 & humidity spike  
  2) **Drift** (gradual sanitizer vapor) → MQ2/MQ5 slope  
  3) **Sensor failure** (unplug/cover) → flatline/bias
- **Analysis (40 min):** baseline, threshold, **t90**, recovery, AUC; discussion.
- **Wrap (20 min):** 1-slide per team; reflect on threshold limits vs ML.

Materials in **`workshop/`** and **`docs/`**.

---

## 🛡️ Safety

- Use benign samples (breath, hand-sanitizer vapor, vinegar).
- No open flames or hazardous gases; work in a ventilated room.
- MQ canisters get warm—avoid touching metal caps.

---

## 🧰 Troubleshooting

- **No connection** → check port:
  ```matlab
  serialportlist("available")
  ```
  Close Arduino Serial Monitor if open.  
- **Flat lines** → recheck AO→A0/A1/A2, GND, 5 V.  
- **DHT11 timeouts** → verify D7 wiring; some modules need a 10 kΩ pull-up.  
- **LED never blinks** → lower:
  ```matlab
  change_threshold = 0.05;
  ```

---

## ❓ FAQ

**How do I call functions in subfolders?**  
Run `setup` once per MATLAB session:
```matlab
setup
y = example_helper(3);   % works from matlab/utils/
```

**Can I use Live Scripts (`.mlx`)?**  
Yes—store them under `matlab/` (e.g., `matlab/live/`).  
For Git diffs, also **Save As… `.m`** when possible.

**Where do data files go?**  
Saved `.mat` files are written to **`data/dataset/`** (git-ignored by default).

---

## 🤝 Contributing

Issues and PRs are welcome! See **CONTRIBUTING.md** and use the templates in `.github/ISSUE_TEMPLATE/`.

---

## 📜 License

This project is licensed under the **MIT License**. See **[LICENSE](LICENSE)**.

---

## 📣 Citation

If you use this repository for teaching or research, please cite it (see **CITATION.cff**):

```
Nimmanterdwong, P., (2025). MQ Fault Diagnosis Workshop (MATLAB + Arduino). MIT License.
```

---

## 🙏 Acknowledgements

- Adafruit DHT libraries and Unified Sensor framework.  
- MATLAB Support Package for Arduino Hardware.  
- Students who piloted the workshop and contributed feedback.
