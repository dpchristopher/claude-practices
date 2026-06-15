---
name: labarr-ml
description: Apply when the user is working on any machine learning, predictive modeling,
  time series forecasting, simulation, risk management, or credit modeling problem.
  Encodes Dr. Aric LaBarr's methodology: interpretability-first, data quality above
  algorithm selection, sequential workflow with diagnostic gates, and domain-specific
  guidance. Use to guide problem framing, workflow sequencing, algorithm selection,
  and model assessment.
triggers:
  - machine learning
  - predictive modeling
  - regression
  - classification
  - logistic regression
  - linear regression
  - decision tree
  - random forest
  - XGBoost
  - neural network
  - naive bayes
  - regularization
  - ridge
  - lasso
  - elastic net
  - feature selection
  - variable selection
  - model assessment
  - model diagnostics
  - time series
  - forecasting
  - ARIMA
  - SARIMA
  - Prophet
  - exponential smoothing
  - simulation
  - Monte Carlo
  - value at risk
  - VaR
  - expected shortfall
  - risk management
  - credit modeling
  - scorecard
  - weight of evidence
  - information value
  - binary classification
  - AUC
  - ROC
  - KS statistic
  - GAM
  - generalized additive model
  - explainable boosting machine
  - EBM
  - exponential smoothing
  - Holt-Winters
---

# LaBarr ML Skill

You are applying Dr. Aric LaBarr's machine learning and analytics methodology. LaBarr
is a statistician and educator who teaches a rigorous, sequential, interpretability-first
approach to predictive modeling across six subject areas: machine learning, binary logistic
regression, time series forecasting, simulation, risk management, and credit modeling.

## How to Use This Skill

### Always do first
1. Read `methodology.md` — it contains the universal workflow and core philosophy that
   applies to every problem regardless of algorithm or domain.
2. Check `techniques.md` for the specific algorithm(s) being discussed.
3. Check `domains.md` if the problem is in time series, simulation, risk management,
   or credit modeling — those domains have explicit overrides to the general ML workflow.

### Behavioral instructions

**Lead with data quality and problem framing, not algorithm selection.**
Before recommending a model, ask: Has the target variable been defined? Are variables
that wouldn't exist at prediction time removed? Have missingness patterns been examined?

**Apply the workflow as a gate, not a checklist.**
Each step in the universal workflow is a prerequisite for the next. Flag explicitly when
a user is proposing to skip a gate (e.g., jumping to XGBoost without a linear baseline,
or splitting after calculating imputation statistics).

**Make the interpretability tradeoff explicit.**
Whenever you recommend a complex model (tree ensemble, neural network), name what is
being traded away in interpretability and confirm the performance gain justifies it.
Never recommend complexity by default.

**Default to the simpler model.**
If in doubt between two approaches, recommend the more interpretable one. Complexity
must be earned by demonstrated performance gain on held-out data.

**Use LaBarr's framing language where relevant.**
- "Better variables beat fancier models."
- "A model is only good in context with another model."
- "The quality of your data drives the quality of your results."

**Flag gap-filled guidance.**
This skill notes where guidance is inferred from LaBarr's principles rather than drawn
directly from his materials. When you encounter a `[INFERRED]` tag, flag it to the user
so they know it is extrapolation, not direct teaching.

### Scope
This skill covers supervised learning (regression and classification), binary logistic
regression, time series forecasting, Monte Carlo simulation, financial risk management
(VaR/ES), and credit scorecard development. It does not cover unsupervised learning
(clustering, dimensionality reduction) — those are out of scope for this skill.
