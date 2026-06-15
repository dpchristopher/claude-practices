# LaBarr Core Methodology

## Core Maxims

These are verbatim or near-verbatim statements from Dr. LaBarr's course materials.
They are not heuristics — they are load-bearing principles that govern every decision.

> "Better variables will always beat fancier modeling techniques. No amount of
> complicated algorithms can make up for variables that are not predictive."

> "The quality of our data drives the quality of our results."
> *(The "rotten eggs" principle: garbage in, garbage out, no matter how sophisticated
> the model.)*

> "A model is only 'good' in context with another model."
> *(There is no absolute threshold for a good model. Every metric is comparative.)*

> "Just because there is uncertainty doesn't mean there is risk."
> *(Particularly for risk management — distinguish between uncertainty and exposure.)*

> "Be careful putting all your trust in any single algorithm."
> *(Applies explicitly to Prophet in time series, but generalizes everywhere.)*

---

## Universal Workflow Sequencing

This 12-step sequence applies to all supervised learning problems. Steps are gates,
not suggestions — each step must be completed before the next begins.

### Step 1 — Problem Framing
- Define the target variable precisely
- Define the decision point: what information exists at prediction time?
- Apply business logic first:
  - Remove variables that would not be available at prediction time
  - Remove individual identifiers (SSN, address, customer ID)
  - Remove protected/private variables that are legally prohibited
- Document what is removed and why

### Step 2 — Data Preparation (before train/test split)
- Audit missingness across all variables
  - > 50–80% missing → consider deleting the variable entirely
  - Categorical missing → create a "Missing" category (do NOT impute with mode)
  - Note: missing values are not automatically bad; they may be predictive
- Do NOT calculate imputation statistics (means, medians) yet — that would contaminate
  training data with information from the test set

### Step 3 — Train/Test Split
**This happens here — before any imputation statistics are calculated.**
- Standard split: 75% train / 25% test, or use a time-based split for temporal data
- All subsequent steps operate on the training set only until final evaluation

### Step 4 — Imputation (training set only)
- Continuous missing → impute with training-set median
- **MANDATORY:** Create a binary missing flag variable for every imputed column
  (e.g., `var_was_missing`). Never skip this.
- Empirical finding: complex predictive imputation does not outperform simple
  mean/median imputation. Use simple.
- Apply the same median (fit on training) to the test set later — do not refit

### Step 5 — Low-Variability Removal
- Continuous: variance < 0.01 → consider removal
- Categorical: one category > 95–99.5% of observations → consider removal
- **Override rule:** Business logic can keep a low-variability variable if domain
  context justifies it

### Step 6 — Univariate Feature Screening
- Continuous predictors vs. target → F-test / ANOVA
- Categorical predictors vs. target → chi-squared test
- Threshold: **p < 0.009** (not the conventional 0.05)
- This is a filter pass, not a final selection — variables that pass proceed to Step 7

### Step 7 — Multivariate Feature Selection
- **Preferred:** Sequential Feature Selector (stepwise) — forward selection plus drops
  insignificant variables at each step; more parsimonious than forward-only
- Forward selection: acceptable but keeps variables stepwise would drop
- RFE: use with caution — **must standardize features first** because magnitude
  affects selection, not just predictive relationship quality
- **Parsimony criterion:** Select the model within one standard error of the best
  cross-validation performance, not the absolute best-performing model

### Step 8 — Build Simple Model First
- Always build OLS (continuous target) or logistic regression (binary target) before
  any complex model
- This serves as the interpretable baseline all complex models must beat
- Document the baseline performance metrics before advancing

### Step 9 — Diagnostic Gate
Must pass diagnostics on the simple model before advancing to complex models.

**For continuous targets (OLS):**
| Diagnostic | Tool | Pass condition |
|---|---|---|
| Linearity | Residual vs. fitted plot | No systematic pattern |
| Homoscedasticity | Breusch-Pagan test | p > 0.05 |
| Normality of residuals | Q-Q plot + Shapiro-Wilk / Anderson-Darling | Q-Q near diagonal |
| Independence | Durbin-Watson statistic | ~2.0 |
| Multicollinearity | VIF | No infinite VIF; extreme VIF → investigate |
| Outliers / influence | Cook's D, leverage, studentized residuals | No single observation dominating |

**If assumptions are violated:**
- Log-transform the target (right-skewed residuals)
- Box-Cox transformation
- Bin continuous predictors for severe nonlinearity
- DO NOT jump to complex models as an escape from assumption violations

**For binary targets (logistic regression):**
| Diagnostic | Tool | Action |
|---|---|---|
| Quasi-complete separation | Cross-tabulate categories vs. target | Remove offending variable before modeling |
| Log-odds linearity | GAM / spline test on continuous predictors | If nonlinear → bin the predictor |
| Calibration | Calibration curve (larger samples only) | Predicted probabilities match observed rates |
| Influential observations | Cook's D, DFBetas | Investigate; consider removal if data error |

### Step 10 — Complex Model Phase
Only after Step 9 passes. Build complex models in parallel against the interpretable baseline.

- Tree-based: Decision Tree, Random Forest, XGBoost
- Neural networks: MLP
- Each model gets full hyperparameter optimization:
  1. GridSearchCV first — understand the parameter space, identify promising regions
  2. Optuna / Bayesian search second — efficient search in promising regions
  3. **10-fold cross-validation is standard** throughout optimization
  4. Metric: `neg_mean_squared_error` (regression), `roc_auc` (classification)
- Never tune hyperparameters using the test set

### Step 11 — Final Model Comparison on Held-Out Test Set
- Apply each model to the test set exactly once
- Report metrics side-by-side

**Regression metrics (in order of priority):**
1. MAE (Mean Absolute Error) — primary; interpretable in original units
2. MAPE (Mean Absolute Percentage Error) — secondary; useful across different scales

**Classification metrics (in order of priority):**
1. AUC / C-statistic — overall rank-order discrimination (0.5 = random, 1.0 = perfect)
2. Somer's D — concordance-discordance (= 2×AUC − 1; ranges −1 to 1)
3. KS statistic — maximum separation between TPR and FPR curves; standard in finance/banking
4. F1 score — harmonic mean of precision and recall
5. Precision-Recall curve — especially informative with class imbalance
6. Lift / Gains charts — shows improvement over random; top-decile lift most actionable

**Accuracy:** Do not use as primary metric. "Easily fooled" — a model predicting the
majority class always achieves high accuracy with imbalanced data.

- Selection is based on **interpretability + performance tradeoff**, not performance alone
- A marginal performance gain in MAE does not justify choosing a black-box model over
  a logistic regression

### Step 12 — Threshold Selection (Classification Only)
- 0.5 is not a default — it is an arbitrary choice that may not serve the business
- Different optimization criteria give different thresholds:
  - Youden's Index: maximizes TPR + TNR simultaneously
  - KS maximization: maximizes separation between good and bad score distributions
  - F1 maximization: balances precision and recall
- **Correct framing:** threshold selection is a business decision driven by the
  relative cost of false positives vs. false negatives — not a statistical optimization

---

## Interpretability Framework

### The Complexity Spectrum

```
Most interpretable                                                          Least interpretable
OLS / Logistic → Regularized Regression → GAM → EBM → Decision Tree → Random Forest → XGBoost → Neural Network
```

### Interpretability Tools by Algorithm

| Algorithm | Native tools | Model-agnostic tools |
|---|---|---|
| OLS | Coefficients, confidence intervals, p-values | — |
| Logistic regression | Odds ratios (exp(coef)), p-values | — |
| Decision tree | Tree visualization (shallow), feature importance | PDP |
| Random forest | Feature importance (with caveats) | PDP, ICE, SHAP |
| XGBoost | Feature importance (gain/cover/freq) | PDP, ICE, SHAP |
| Neural network | Hinton weight diagrams | PDP (limited), SHAP, LIME |

**Feature importance caveat:** Tree-based feature importance can be misleading.
Sanity check: add a random noise variable and see how it ranks. If it ranks highly,
the importance scores are unreliable for that dataset.

**Key distinction:** "Partial dependence shows you what the model learned, but it is
not the same as understanding causality."

### When to Accept Complexity

Accept a more complex model when ALL of the following are true:
- Prediction accuracy is the explicit, primary objective
- The performance gain over the interpretable baseline is meaningful, not marginal
- Domain or regulatory context does NOT require explanation of individual predictions
- The interpretable model has already been built and benchmarked

### When NOT to Accept Complexity

- Credit/lending decisions — borrowers have a legal right to explanation
- Clinical or high-stakes individual decisions
- Regulatory environments requiring audit trails
- When the interpretable model's performance is adequate for the use case

---

## Missing Data Philosophy

Missing values are **not automatically problems** — they may be predictive signals.
Example: in fraud detection, a missing phone number field may itself indicate suspicious
activity.

| Variable type | Treatment |
|---|---|
| Categorical | Create "Missing" as its own category — never impute with mode |
| Continuous | Impute with training-set median + create binary missing flag variable |

**Train/test discipline:** Never fit imputation statistics (mean, median) before the
train/test split. Fitting on the full dataset leaks test-set information into training.

**Complexity vs. simplicity:** Empirical research consistently shows predictive imputation
models do not outperform simple median imputation. Use the simple approach.

---

## Feature Engineering Philosophy

"Better features > fancier modeling" is the operating principle.

LaBarr's framework for engineering features from transaction data:
- **Tabulations:** counts, sums by category
- **Distributions:** mean, median, SD, IQR, min, max, quantiles
- **Stratifications:** time-windowed versions of the above (last 7 days, last 30 days)
- **Profiles:** counts/sums across multiple category combinations
- **Time Series:** trends, slopes, moving averages from sequential data

Concrete examples:
- Mean of last five transactions
- Standard deviation of transactions in last 14 days
- Slope of a line fit to transaction frequency per week (is it increasing or decreasing?)

Domain knowledge is a more powerful feature engineering tool than algorithm selection.
