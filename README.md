# Acoustic-TTS-Analysis
## Analysis of Acoustic Features and TTS Naturalness

This project investigates how acoustic features influence the perceived naturalness of AI-generated speech. Using publicly available Text-to-Speech (TTS) audio samples and their Mean Opinion Score (MOS) ratings, the project extracts features such as pitch variability, energy variation, and speech duration to analyze their relationship with human perception.

The goal is to identify which acoustic characteristics make synthetic speech sound more human-like and natural. The project uses Python, Pandas, Librosa, and data visualization techniques to perform feature extraction and statistical analysis.

### Objectives

* Extract acoustic features from TTS audio samples.
* Analyze the distribution of naturalness scores.
* Examine relationships between acoustic features and perceived speech quality.
* Identify factors associated with more human-like synthetic voices.

### Research Question

* Main-RQ: Which acoustic features are associated with TTS naturalness?
* RQ1 How are naturalness (MOS) scores distributed across the TTS systems in the dataset?
* RQ2 Which acoustic features show the strongest relationship with TTS naturalness?
* RQ3 Do TTS systems with higher naturalness scores exhibit different acoustic characteristics than lower-scoring systems?

### Technologies

* Python
* Pandas
* NumPy
* sqlite3
* Librosa
* Matplotlib
* Jupyter Notebook

### Expected Outcome

The project provides insights into how measurable audio characteristics affect the naturalness of AI-generated speech and helps explain why some synthetic voices sound more human-like than others.

### work flow
```
.wav
  ↓
Feature Extraction
  ↓
pitch
energy
duration
  ↓
Merge with MOS
  ↓
Correlation Analysis
  ↓
Conclusion
```

### Dataset

VoiceMOS Challenge Dataset:
[Click Here](https://zenodo.org/records/10691660?utm_source=chatgpt.com)

### Features

- Duration
- Pitch Variability
- Energy Variability

### To show file structure
```tree -L 3```

### Understand file structure

```
.
├── data/
│   ├── processed/                      # Store generated datasets.
│   └── raw/
│       ├── audio
│       ├── mydata_system.csv
│       └── sets
├── figures/                            # Store all graphs.
├── LICENSE
├── notebooks/                          # This is where most of the work happens.
│   ├── 01_explore_dataset.ipynb        # Understand the dataset.
│   ├── 02_feature_extraction.ipynb     # Extract acoustic features from audio.
│   └── 03_analysis.ipynb               # Answer the research question.
├── README.md                           # Explain the project.
├── report/                             # Store your proposal and final report.
├── requirements.txt                    # List dependencies.
└── src/
    ├── analysis.py                     # Reusable analysis functions.
    └── extract_features.py             # Reusable feature extraction functions.
```

### Answer to RQ1:
&ensp; Answer this using: <br>

* Dataset exploration
* MOS histogram
* Summary statistics

### Answer to RQ2:
&ensp; Answer this using: <br>

* Correlation analysis
* Scatter plots
* Correlation heatmap

&ensp; Features: <br>

* Pitch variability
* Energy variability
* Duration

### Answer to RQ3:
&ensp; Answer this using: <br>

* High-MOS systems
* Low-MOS systems

| System | MOS    | Pitch Std |
| ------ | ------ | --------- |
|   A	 |  4.5	  |   30      | 
|   B	 |  2.0	  |   10      |

### My study map
``` 
Dataset (.wav + MOS)
          │
          ▼
Q1: Understand the Dataset
          │
          ▼
Q2: Extract Acoustic Features
          │
          ▼
Create Final Dataset
          │
          ▼
Q3: Analyze Relationships
          │
          ▼
Answer Research Questions
          │
          ▼
Write Report
```

### Environment
```Python 3.14.0```

### Installation dependencies
* window
```bash
pip install -r requirements.txt
```

* mac/linux
```bash
pip3 install -r requirements.txt
```

### Create virtual environment
```bash
python -m venv venv
```

### Activate
```bash
source venv/bin/activate
```


