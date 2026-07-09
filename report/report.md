# Acoustic-TTS-Analysis: Report

## 1. Overview

This project investigates which acoustic features are associated with the perceived naturalness (Mean Opinion Score, MOS) of Text-to-Speech (TTS) audio, using the VoiceMOS Challenge dataset. The workflow moves through three notebooks in `notebooks/`:

| Notebook | Purpose |
|---|---|
| `01_explore_dataset.ipynb` | Load and sanity-check the MOS and acoustic-feature tables in the SQLite database |
| `02_feature_extraction.ipynb` | Extract acoustic features (pitch, energy, spectral, silence) from raw `.wav` files with `librosa` and store them in SQLite |
| `03_analysis.ipynb` | Merge features with MOS, run EDA, correlation analysis, and a linear regression to answer the research questions |

(`00_work_plan_testing.ipynb` is a scratch/planning notebook used to prototype the pipeline before it was formalized into 01–03; it is not part of the final analysis and isn't covered in detail below.)

**Research questions:**
- **Main RQ:** Which acoustic features are associated with TTS naturalness?
- **RQ1:** How are MOS scores distributed across TTS systems?
- **RQ2:** Which acoustic features show the strongest relationship with naturalness?
- **RQ3:** Do high-MOS systems exhibit different acoustic characteristics than low-MOS systems?

---

## 2. Notebook 01 — Explore Dataset

**Goal:** understand the MOS data, check duplicates, verify that features and labels line up, and inspect the database schema.

Steps performed:
1. Connects to `../data/processed/system_data.db`.
2. Loads the `load_raw_mos` table (`file`, `MOS`) — e.g. files like `sys64e2f-utt491a78a.wav` with MOS scores such as 4.000, 3.625, 3.375.
3. Checks for duplicate `file` entries in the MOS table — **result: 0 duplicates**, so every audio file has exactly one MOS rating.
4. Loads the `wav_attribute` table, which holds the extracted acoustic features (duration, spectral rolloff, spectral contrast, silence ratio, pitch stats, energy stats, etc.).
5. Verifies that features and MOS labels can be joined on `file` (inner join count check).
6. Inspects the `wav_attribute` schema via `PRAGMA table_info`, confirming 13+ numeric feature columns are present.

**Takeaway:** the dataset is clean (no duplicate MOS entries) and the feature/label tables are join-compatible, so the pipeline can safely merge them in notebook 03.

---

## 3. Notebook 02 — Feature Extraction

**Goal:** extract acoustic features from every `.wav` file and persist them to SQLite.

A `Wav` class encapsulates the pipeline:
- `get_paths()` — pulls all audio file paths from the `wav_path` table.
- `extract_features()` — for each file, loads audio with `librosa.load` and computes:
  - **Duration** (`librosa.get_duration`)
  - **Pitch** via YIN pitch tracking (`librosa.yin`, 50–400 Hz range), reduced to mean/std/min/max/range (non-finite values filtered out)
  - **Energy (RMS)** via `librosa.feature.rms`
  - **Spectral features**: rolloff, centroid, bandwidth, contrast (mean)
  - **Silence ratio**: computed from `librosa.effects.split` (top_db=20) as the proportion of the clip that is non-speech
  - **Zero-crossing rate (ZCR)**

The main execution block loops over all audio paths, extracts features, and saves results to the database, printing progress every 100 files.

**Result:** the run processed **3,382 audio files successfully** (no errors reported in the notebook output) and confirmed with `Feature extraction completed.` This produces the `wav_attribute` table used by notebooks 01 and 03.

---

## 4. Notebook 03 — Analysis

**Goal:** merge features with MOS scores, perform exploratory data analysis, correlation analysis, and fit a linear regression model to identify which features best predict naturalness.

### 4.1 Data preparation
- Creates a `wav_analysis` table in SQLite as an inner join of `wav_attribute` and `load_raw_mos` on `file`, combining every extracted feature with its corresponding MOS score.
- Loads this table into a DataFrame `df` for analysis.

### 4.2 Exploratory Data Analysis (answers RQ1)
- **Figure 1 — MOS Distribution:** a histogram of MOS scores across the dataset, showing how naturalness ratings are spread across TTS systems.

### 4.3 Correlation Analysis (answers RQ2)
- **Figure 2 — Correlation Heatmap:** full correlation matrix across all numeric features and MOS.
- **Correlation of each feature with MOS** (sorted by strength):

  | Feature | Correlation with MOS |
  |---|---|
  | spectral_contrast | **0.313** |
  | zcr | 0.212 |
  | duration | 0.205 |
  | energy_mean | 0.203 |
  | spectral_centroid | 0.179 |
  | spectral_rolloff | 0.112 |
  | pitch_mean | 0.090 |
  | pitch_range | 0.088 |
  | pitch_max | 0.084 |
  | energy_range | 0.076 |
  | pitch_std | 0.067 |
  | spectral_bandwidth | 0.055 |
  | pitch_min | -0.035 |
  | energy_std | -0.185 |
  | silence_ratio | **-0.203** |

- **Figure 3 — Spectral Contrast vs MOS** (scatter plot): visualizes the strongest positive relationship in the dataset.
- **Figure 4 — Silence Ratio vs MOS** (scatter plot): visualizes the strongest negative relationship — clips with more silence tend to score lower on naturalness.

**Interpretation:** no single feature correlates strongly with MOS in isolation (all |r| < 0.35), but **spectral contrast** (positive) and **silence ratio** (negative) stand out as the most informative individual predictors, followed by ZCR, duration, and energy mean.

### 4.4 Linear Regression (answers RQ2/RQ3)
- Features (`X`) = all numeric columns except `file` and `MOS`; target (`y`) = `MOS`.
- 80/20 train-test split (`random_state=42`), features standardized with `StandardScaler`.
- A `LinearRegression` model is fit on the training set.

**Test-set performance:**
| Metric | Value |
|---|---|
| R² | 0.184 |
| MAE | 0.717 |
| RMSE | 0.869 |

The model explains only about **18% of the variance** in MOS scores — acoustic features alone are a weak-to-moderate predictor of perceived naturalness, consistent with the modest correlations seen above.

**Figure 5 — Feature Importance** (standardized regression coefficients, sorted by magnitude):

| Feature | Coefficient |
|---|---|
| spectral_rolloff | -1.067 |
| spectral_centroid | +0.860 |
| spectral_bandwidth | +0.286 |
| spectral_contrast | +0.256 |
| pitch_mean | -0.233 |
| pitch_std | +0.206 |
| energy_std | -0.182 |
| energy_range | +0.093 |
| silence_ratio | -0.073 |
| duration | +0.071 |
| zcr | +0.039 |
| energy_mean | -0.016 |
| pitch_min | +0.003 |
| pitch_max | +0.003 |
| pitch_range | +0.002 |

**Interpretation:** once all features are considered jointly, **spectral features dominate** — spectral rolloff (negative) and spectral centroid (positive) have by far the largest standardized effects on predicted MOS, even though spectral_contrast alone had the strongest simple correlation. This suggests spectral brightness/shape characteristics, not pitch or duration, carry the most (linear) predictive weight for naturalness. Pitch-range statistics (min/max/range) contribute almost nothing once other features are accounted for.

---

## 5. Answers to the Research Questions

- **RQ1 (MOS distribution):** MOS scores are visualized via a histogram (Figure 1) across all 3,382 rated audio samples; scores span the available MOS range with no duplicate ratings per file.
- **RQ2 (strongest feature relationships):** Individually, **spectral contrast** (+) and **silence ratio** (−) show the strongest simple correlations with MOS. In the joint linear model, **spectral rolloff** and **spectral centroid** have the largest standardized coefficients, indicating spectral shape features are the most predictive overall.
- **RQ3 (high- vs low-MOS systems):** The regression and correlation results imply that higher-MOS (more natural-sounding) systems tend to have **lower spectral rolloff/less silence** and **higher spectral centroid/contrast**, while pitch-related statistics show comparatively weak, near-negligible differences between high- and low-scoring systems.

## 6. Limitations

- The linear regression's R² of 0.184 indicates acoustic features explain only a modest share of MOS variance — human perception of naturalness likely depends on non-linear or higher-order interactions (e.g., prosody patterns, phoneme-level artifacts) not captured by simple summary statistics, or on linguistic/semantic factors outside the acoustic feature set entirely.
- All features are simple aggregate statistics (mean/std/min/max/range) computed over a whole clip, which may smooth over locally important acoustic events.
- No non-linear models (e.g., random forest, gradient boosting) were tested in this notebook; these might capture more of the variance and reveal different feature-importance rankings.

## 7. Future works

1. Try non-linear regression models (Random Forest, XGBoost) to see if they capture more MOS variance and to cross-check feature importance.
2. Break down the analysis per-TTS-system (per the README's RQ3 table idea) rather than per-utterance, to compare system-level acoustic profiles directly.
3. Investigate interaction effects between spectral and pitch features.
4. Consider additional acoustic descriptors (e.g., jitter, shimmer, formant-based measures) that are known in speech-quality literature to relate to naturalness.
