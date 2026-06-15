# LaBarr Domain-Specific Guidance

Domain-specific methodology for four specialized application areas where LaBarr's approach
diverges meaningfully from general supervised ML. Each section documents the overrides,
additions, and domain-specific rules that apply beyond the universal workflow in `methodology.md`.

---

## Time Series Forecasting

### Fundamental Difference from Cross-Sectional ML

"Each observation depends on the previous one."

This single fact overrides several standard ML practices:
- **Random cross-validation is INVALID.** You cannot randomly shuffle a time series and
  validate subsets — you will leak future information into training. Always use
  walk-forward or rolling-origin validation.
- **The test set is never used to build a model.** "The test dataset is never used to
  build a model with until the final model is selected."
- Missing data impact propagates — missing time series observations affect surrounding
  observations, not just themselves.

### Universal Time Series Workflow

Unlike the linear 12-step supervised ML workflow, time series follows a **circular,
iterative** process:

```
Data Cleaning
     ↓
Propose Model
     ↓
Fit Model
     ↓
Diagnose: Are residuals white noise? (Ljung-Box p > 0.05)
     ↓
No → back to Propose Model
Yes ↓
Forecast / Explain
```

Residuals must behave as white noise before any model is finalized. If residuals show
pattern (autocorrelation, seasonality), the model has not captured the structure.

### Choose Your Objective Before Modeling

| Objective | What it means | Methods |
|---|---|---|
| **Explanation** | Why did this happen? What was the effect of an event? | Dynamic regression, intervention analysis |
| **Prediction** | What value should I expect in period t+h? | ARIMA, ETS, neural AR, Prophet |

Same data, same tools — but the framing and evaluation differ. Declare the objective
before selecting a method.

### Method Selection Guide

| Signal pattern in data | Recommended method |
|---|---|
| Trend only, no seasonality | Holt's exponential smoothing (trend-adjusted ETS) |
| Trend + seasonality | Holt-Winters (additive or multiplicative seasonality) |
| ACF decays slowly, PACF cuts off sharply at lag p | AR(p) |
| PACF decays slowly, ACF cuts off sharply at lag q | MA(q) |
| Both ACF and PACF decay gradually | ARMA(p,q) |
| Non-stationary (unit root present) | Difference first (d times), then ARMA → ARIMA(p,d,q) |
| Seasonal patterns present | SARIMA(p,d,q)(P,D,Q)s |
| External predictor variables + serial correlation | Dynamic regression with ARIMA errors |
| Multiple seasonalities, holidays, high volume | Prophet (with explicit caveats — see below) |
| When accuracy dominates interpretability | Autoregressive neural network |

### Exponential Smoothing Models

Use exponential smoothing as the **first model to build** with any time series dataset.
"Hard to beat, especially if you are only forecasting in the short term."

**Model selection by data pattern:**

| Data characteristics | Model |
|---|---|
| No trend, no seasonality | Simple (Single) Exponential Smoothing |
| Trend present, no seasonality | Holt's Linear Exponential Smoothing |
| Trend + seasonality | Holt-Winters |

**Additive vs. multiplicative seasonality:**
- Additive: seasonal swings are constant in absolute size across the series
- Multiplicative: seasonal swings grow or shrink proportionally with the level
- In practice: build both and let test-set MAE/MAPE decide — differences are often small

**Workflow:**
1. Split into training and test sets
2. Build multiple candidate variants (additive and multiplicative) simultaneously
3. Compare on training via AIC/AICc/BIC
4. Evaluate on test set via MAE and MAPE — this is the final arbiter
5. Visualize fitted values against actuals

**Parameter note:** Exponential smoothing parameters (θ, γ, φ, δ) are not derived from
statistical distributions — do not rely solely on significance tests for them. Optimize
by minimizing sum of squared one-step-ahead forecast errors.

---

### Stationarity

"Stationarity is where the distribution of the data depends **only** on the difference
in time, not on the location in time." Requires consistent mean, variance, and
autocorrelation throughout the series.

**Three causes of non-stationarity:**
1. Dependencies that do not dissipate over time
2. Trending patterns
3. Seasonal components

**Testing — ADF test with three variants:**
| Variant | Use when |
|---|---|
| Zero Mean | Data averages around zero |
| Single Mean | Data has a non-zero average |
| Trend | Data exhibits a trending pattern |

Null hypothesis = non-stationary (unit root present). Rejecting it → stationary.

**Fixing non-stationarity:**
- Take first differences; retest; take second differences if needed
- Track the number of differences taken — this is the d in ARIMA(p,d,q)
- For seasonal non-stationarity: take seasonal differences (Yₜ − Yₜ₋ₛ)
- **SARIMA ordering rule:** When data has both trend AND seasonality, address
  seasonality first, then trend — "seasonality should be the first problem you
  try and correct to make stationary"

### ACF / PACF Interpretation

```
Sharp cutoff in ACF, decaying PACF  →  MA(q) where q = lag of cutoff
Sharp cutoff in PACF, decaying ACF  →  AR(p) where p = lag of cutoff
Both decay gradually                →  ARMA; select p,q via AIC/BIC
```

For seasonal models, look for the same patterns **at seasonal lags** (12, 24, 36 for
monthly data) — spikes at seasonal lags in PACF → seasonal AR (P); in ACF → seasonal MA (Q).

Validation: Ljung-Box test on residuals. p > 0.05 suggests residuals are white noise.

### SARIMA — Seasonal ARIMA

**When:** Data has a repeating pattern over a fixed period (weekly, monthly, quarterly).

**Key ordering rule:** "When your data has both trend and seasonality, seasonality should
be the first problem you try and correct to make stationary." Fix seasonal non-stationarity
before addressing trend.

**Identifying seasonal differencing need:**
- Calculate seasonal strength metric (Fₛ)
- Fₛ < 0.64 → no seasonal differencing needed
- Fₛ ≥ 0.64 → take one seasonal difference: Yₜ − Yₜ₋ₛ

**Limitation:** Seasonal differencing becomes unreliable for season lengths > 24.

**Deterministic vs. stochastic approach:**
"In practice, model with **both** deterministic (trend fitting) and stochastic (differencing)
solutions and compare the forecasts to see which was more accurate." Do not commit to one
approach theoretically — let empirical test performance decide.

**Auto-selection caveat:**
"Automatic selection techniques are good starting points, but you should not be afraid to
adjust them." Review ACF/PACF at seasonal lags manually and override if the automated
order selection misses obvious seasonal structure.

### Prophet Caveats (Explicit from Course)

> "Be careful putting all your trust in the Prophet algorithm."

- Prophet does **not** use lag values of the target — it is curve-fitting to
  trend + seasonality + holiday components, not statistical time series decomposition
- Underperformed ARIMA-family models in LaBarr's empirical testing
- Use Prophet for: exploratory analysis, when holiday and calendar effects dominate,
  multiple seasonalities at scale
- Do NOT rely solely on Prophet as a production forecasting method
- Always compare to ARIMA baseline before accepting Prophet's forecast

### Neural Networks for Time Series

When prediction accuracy dominates interpretability, autoregressive neural networks
are appropriate. Key differences from standard neural networks:

- Must make data **stationary first** (same requirement as ARIMA)
- Inputs are **lags of the target variable** — the NN is not receiving raw time index
- Lag selection: trial and error mirroring ARIMA lag identification
- **Critical warning:** Differencing to achieve stationarity does not automatically
  return forecasts to the original scale. You must manually backtransform predictions
  (undo the differencing) before evaluating forecast accuracy in original units.
- Accept the black-box tradeoff explicitly; interpretability is limited

### Weighted and Combined Forecasts

"The combination of forecast methods tends to outperform most single forecast methods"
because biases across different methodologies offset each other. Especially valuable
for long-range forecasts where uncertainty is high.

**Two approaches:**

| Method | How | When |
|---|---|---|
| Simple average | Arithmetic mean of all model forecasts | Default — "very hard to beat in practice" |
| Weighted (regression-based) | Regress actuals on forecasts; coefficients become weights (constrained to sum to 1) | When models have meaningfully different accuracy |

**LaBarr's empirical finding:**
Simple averaging of three models (ESM + seasonal ARIMAX + Prophet) achieved MAPE of
1.09% vs. individual model MAPEs of 1.57–2.30%. Simple averaging won over optimized
weighting in his testing.

**Critical warning:** "Just because we have the minimum variance weights on the training
data doesn't mean that we are good on the test dataset." Optimal weights from training
frequently fail to transfer — another reason the simple average is often best.

**Do:** Test different model subsets — "different combinations might be better than others."
**Don't:** Assume regression-based weighting will outperform simple averaging.

---

## Simulation

### Core Philosophy

> "The best way to learn simulation is through an example."

> "We don't need complicated mathematics when we use simulations to approximate
> distributional assumptions."

Simulation replaces intractable analytical derivations with empirical distributions.
When a closed-form solution does not exist, simulation builds the distribution
computationally from thousands of draws.

### When to Use Simulation

- Analytical solution is intractable (e.g., portfolio of non-normal assets compounded over time)
- Need to quantify uncertainty around a point estimate (point estimates hide the distribution)
- Portfolio/risk scenarios with correlated inputs
- Sensitivity analysis across thousands of parameter combinations
- Validating model performance against random chance (target shuffling)

### Distribution Selection Framework

| Situation | Distribution choice |
|---|---|
| Well-understood data-generating process | Parametric distribution (normal, lognormal, etc.) |
| Empirical data available, shape unknown | Kernel density estimation (KDE) |
| Regime change or structural shift anticipated | Hypothesized future distribution |

**KDE note:** Bandwidth selection balances fit vs. smoothness. Narrow bandwidth → overfits
to sample noise. Wide bandwidth → smooths out real features. Test sensitivity.

### Correlated Variables

Use **Cholesky decomposition** to generate correlated draws from multiple distributions.
- Works best when inputs are normally distributed
- Acceptable when inputs are symmetric and approximately unimodal
- Avoid with highly skewed or bimodal inputs — correlation structure may not be preserved

Financial context: stock-bond negative correlation (~−0.2) reflects flight-to-safety dynamics.
This must be modeled explicitly; assuming independence will underestimate joint tail risk.

### Sample Size and Precision

Margin of error scales with **1/√n**.
- Quadrupling the number of simulations doubles the precision
- Start at 10,000 simulations
- Increase if tail estimates are unstable (re-run and check if tail quantiles shift)
- For rare-event tails (< 1%), 100,000+ draws may be needed for stable estimates

### Financial Domain Realities

- Multi-year compounding produces **right-skewed distributions**, not normal distributions.
  Always visualize the output distribution; never assume normality for compounded returns.
- Typical calibration values from LaBarr's examples: mean annual return 9.75%, annual
  volatility 18%
- Point estimates (expected value) miss the story — the distribution is the product

### Target Shuffling (Model Validation via Simulation)

Use when you need to test whether a model's performance is better than random chance.

**Method:**
1. Fit the model, record the performance metric
2. Shuffle the target variable randomly and refit the model (destroys all real signal)
3. Repeat thousands of times to build the null distribution of performance
4. Compare the real model's metric to the null distribution
5. p-value = fraction of shuffled models that outperformed the real model

| Feature set size | Method |
|---|---|
| Small (< 40 predictors) | Exhaustive permutation analysis if computationally feasible |
| Large (40+ predictors) | Simulated sampling (40! = 8.16×10⁴⁷ — exhaustive is impossible) |

**Explicit caution:** At 5% significance level, you accept a 5% Type I error rate. State
this explicitly in any analysis using target shuffling.

---

## Risk Management

### Foundational Distinction

> "Just because there is uncertainty doesn't mean there is risk."

Coin-flip example: there is uncertainty (you don't know the outcome) but no financial
risk unless money is wagered. This distinction governs how risk measurement is framed.

**Three levels of uncertainty:**

| Level | Description | Strategy |
|---|---|---|
| Known | Outcomes and probabilities are known | Insurance, hedging |
| Unknown | Outcomes known, probabilities uncertain | Diversification, stress testing, reduce over time |
| Unknowable | Outcomes themselves are unforeseeable | Tail risk management, EVT, stress scenarios |

### Methodological Principle

Match method complexity to problem structure. Do not default to sophisticated methods
when simpler ones are sufficient.

### VaR Estimation — Three Methods

Value at Risk: the loss at a given confidence level (e.g., 99% 1-day VaR = "we expect
to lose no more than $X on 99% of days").

**Fundamental limitation of VaR:** "VaR ignores the distribution of a portfolio's return
beyond its VaR value." It tells you the loss at the threshold, not how bad losses get
beyond it.

| Method | When to use | Limitation |
|---|---|---|
| **Delta-Normal** | Large portfolio, linear instruments, computational speed required | Assumes normality; underestimates fat tails; inappropriate for options/non-linear instruments |
| **Historical Simulation** | Distribution-free; want tail events from actual history | Limited by what happened historically; blind to unobserved extreme events |
| **Monte Carlo Simulation** | Non-linear instruments; non-normal distributions; complex portfolio | Computationally intensive; model risk (depends on assumed distributions) |

All three methods extend naturally to **multi-day VaR** (e.g., 10-day VaR from 1-day VaR
via √time scaling under Delta-Normal; direct simulation for others).

### Expected Shortfall (ES)

Also called Conditional VaR (CVaR). Addresses VaR's two key weaknesses:
1. VaR ignores the distribution of losses beyond the threshold
2. VaR can fail subadditivity (portfolio VaR can exceed sum of component VaRs — violates
   diversification logic)

ES = average of all losses exceeding the VaR threshold.

- "Less stable than VaR" due to fewer observations in the tail — requires larger datasets
- Preferred for regulatory purposes (Basel III/IV)
- All three VaR estimation methods extend to ES

### Extreme Value Theory (EVT)

Use when ES is unstable due to insufficient tail observations.
- Specifically parameterizes the tail of the loss distribution (Generalized Pareto, GEV)
- Requires parameter estimation — use software (Python: `scipy.stats.genpareto`,
  R: `evd` package)
- Comparative visualization (EVT tail vs. empirical tail) confirms fit

### Returns Calculation — Critical Rule

> "It is NOT 0%!"

A +50% return followed by a −50% return is a **net loss of 25%**, not zero.
Arithmetic returns do not compound correctly across periods.

| Context | Use | Why |
|---|---|---|
| Multi-period compounding | **Geometric returns** | Multiplicative; compounding-correct |
| Within a single period | Arithmetic returns | Additive within period |
| Cross-asset comparison (annualized) | Geometric | Ensures comparability |

### Stressed VaR

Rather than using the most recent n days of data:
> "Look for the worst collection of n consecutive days in the historical data."

This forces the model to consider historically bad conditions, not just recent calm periods.
Regulatory (Basel II.5+) requires reporting stressed VaR alongside standard VaR.

### Explicit Do/Don't Table

| Decision | Do | Don't |
|---|---|---|
| Multi-period returns | Geometric | Sum arithmetic returns across periods |
| Method selection | Match to problem structure | Default to Monte Carlo because it's sophisticated |
| Linear instruments, large portfolio | Delta-Normal (fast and sufficient) | Unnecessarily complex simulation |
| Non-linear or non-normal | Simulation | Force Delta-Normal assumptions |
| Tail behavior | ES or EVT when stability matters | Stop at VaR |
| Historical periods | Stressed VaR (worst historical window) | Use only recent calm-period data |
| Variable interdependence | Model correlation explicitly | Assume independence of assets |

---

## Credit Modeling / Scorecard Development

### Foundational Principle

> "When it comes to complicated machine learning models, model interpretation is still key."

In credit modeling, interpretability is a **regulatory and legal requirement**, not a preference:
- Borrowers have the right to know why they were rejected (FCRA, ECOA)
- Regulators (FDIC, OCC, Basel) require models to be auditable and explainable
- Consumer protection law mandates adverse action notices in plain language

> "Empirical examples have shown WoE-based logistic regression models perform very well
> in comparison to more complicated approaches."

### Why Scorecards Over Black-Box Models

- Translates regression coefficients into point values "people at all levels generally
  find easy to understand and use"
- Regulators and compliance teams can audit every point assignment
- Decision-makers can apply the scorecard without data science infrastructure
- Empirically competitive with complex models when features are well-engineered (WoE binning)

### Scorecard Development Workflow

```
1.  Train/test split FIRST
    — Before any binning (binning evaluates target relationships; do it only on training)

2.  Prebinning: segment each continuous variable into initial fine bins

3.  Chi-square merging: combine adjacent bins with similar WoE until bins are meaningful
    — Produces optimal bins per variable

4.  Calculate WoE (Weight of Evidence) per bin:
    WoE = ln(Distribution of Goods / Distribution of Bads)
    Positive WoE = bin has more goods than average; negative = more bads

5.  Calculate IV (Information Value) per variable:
    IV = Σ (Distribution of Goods − Distribution of Bads) × WoE

6.  Variable selection using IV thresholds (see table below)

7.  Override bins if business rules require
    — Accept R² reduction (e.g., 0.80 → 0.78) for regulatory compliance
    — "Sub-optimal bins are acceptable if they conform to business rules"

8.  Build logistic regression on WoE-transformed variables

9.  Convert to scorecard points using PDO (Points to Double the Odds)
    — PDO defines the scale: a 20-point increase doubles the odds of being a good borrower

10. Validate: decile plots, KS statistic, AUC/C-statistic, score distribution overlay

11. Reject inference (if applicable) → rebuild as application scorecard
```

### Information Value (IV) Thresholds

Standard thresholds for credit modeling (not general ML):

| IV value | Interpretation |
|---|---|
| < 0.02 | Not predictive — exclude |
| 0.02–0.1 | Weak predictor — include if domain logic supports |
| 0.1–0.3 | Medium predictor — include |
| 0.3–0.5 | Strong predictor — include |
| > 0.5 | Suspicious — investigate for data leakage or overfitting before including |

### WoE Monotonicity

Ideal: WoE values increase (or decrease) monotonically across ordered bins.
This means higher scores in the variable consistently correspond to better (or worse) risk.

**However:** "We don't need strict monotonicity as long as the WoE pattern in the bins
makes business sense." Never force artificial monotonicity that contradicts the underlying
risk relationship.

Watch for: "If a variable's bins go back and forth between positive and negative WoE values
across bins, the variable typically has trouble separating goods and bads." This is a signal
to drop the variable or re-examine the binning.

### Missing Values in Credit Context

- Missing credit history or application fields get their **own separate bin**
- Do NOT impute missing values in credit modeling — missingness is itself informative
  (sparse credit history is a risk signal)
- The missing bin participates in WoE calculation and IV like any other bin

### Reject Inference

**Why it's required:**
A behavioral scorecard built on accepted applicants only has selection bias. Accepted
applicants are systematically better risks than the full applicant population. Applying
this model to all applicants (including likely-rejects) will underestimate default risk.

**When to apply:**
- When the scorecard will be used for the full applicant population (not just current customers)
- When rejection rate is non-trivial (> ~5–10%)

**Methods in order of preference:**

| Method | How it works | When appropriate |
|---|---|---|
| Parceling | Split rejected applicants into good/bad proportionally based on score distribution; create fractional records | Standard method; most common |
| Fuzzy augmentation | Assign each rejected applicant a probability of being good/bad; create weighted records | When avoiding hard cutoffs |
| Simple cutoff | Assign all rejects below a threshold to defaulters | **Only acceptable when rejection rate is minimal** |

**Workflow after reject inference:**
1. Score rejected applicants using the behavioral scorecard
2. Apply inference method to infer good/bad labels for rejects
3. Combine accepted + inferred-reject dataset, **maintaining population proportions**
   (typically ~70% accepted, ~30% rejected)
4. Rebuild logistic regression on combined dataset → this is the **application scorecard**

### Rare Event Handling (Class Imbalance)

Defaults are rare events — typical portfolios have 3–15% default rates.

- Oversample minority class (defaults) using weights (e.g., 4.75× weight on defaults)
- **Track weights explicitly through ALL stages** — through reject inference, through
  the rebuild, and through validation metrics
- Decile plots must account for weights; raw count comparisons will mislead
- Weighted KS and weighted AUC reflect true model performance on the actual population

### Validation

| Tool | What it checks |
|---|---|
| **Decile plots** | Default rate should decrease monotonically from worst-score decile to best-score decile |
| **KS statistic** | Maximum separation between good and bad score distributions; higher = better discrimination |
| **AUC / C-statistic** | Overall rank-order discrimination across all thresholds |
| **Score distribution overlay** | Good and bad populations plotted together; visual separation |
| **Population Stability Index (PSI)** | Monitors whether new applicant population has shifted from development population; PSI > 0.25 = model needs review |

**[INFERRED]** PSI is industry-standard credit model monitoring but not explicitly
demonstrated in LaBarr's materials. Consistent with his validation philosophy.

### Explicit Do/Don't Table

| Decision | Do | Don't |
|---|---|---|
| Interpretability | Use WoE logistic regression as foundation | Default to gradient boosting because it scores higher on training metrics |
| Variable selection | Use IV thresholds (credit-specific) | Use standard ML feature importance rankings without domain translation |
| Missing values | Create separate bin | Impute (missingness is informative in credit) |
| High IV (> 0.5) | Investigate for data leakage | Accept at face value |
| Bin overrides | Accept R² reduction for business/regulatory compliance | Force statistical optimization over compliance |
| WoE monotonicity | Accept if business logic supports non-monotonicity | Force artificial monotonicity |
| Reject inference method | Parceling or fuzzy | Simple cutoff (unless rejection rate is negligible) |
| Population proportions | Maintain accept/reject ratio in combined dataset | Overweight rejects unrealistically |
| Validation metric | Decile plots with monotonic default rate | Raw count comparisons that ignore sample weights |
| Strong predictor + weak alternative | Build separate sub-models and ensemble | Force single model to capture all relationships |
