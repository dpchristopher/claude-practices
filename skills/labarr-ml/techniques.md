# LaBarr Techniques Reference

Algorithm and topic-by-topic guidance across all course modules. Each entry follows
the same structure: when to use, what to watch for, workflow, and explicit do/don't rules.

---

## 1. OLS / Linear Regression

**When to use:**
- Continuous target variable
- Interpretability is required or preferred
- As the mandatory baseline before any complex model

**Workflow:**
1. Run the regression
2. Test ALL five assumptions (in this order — later assumptions depend on earlier ones)
3. Transform or fix violations before advancing to complex models

**Assumptions to test (in order):**

| # | Assumption | Tool | Pass condition |
|---|---|---|---|
| 1 | Linearity | Residual vs. fitted plot | No curve or funnel pattern |
| 2 | Homoscedasticity | Breusch-Pagan test | p > 0.05 |
| 3 | Normality of residuals | Q-Q plot + Shapiro-Wilk or Anderson-Darling | Points hug the diagonal |
| 4 | Independence of errors | Durbin-Watson statistic | Value ~2.0 |
| 5 | No multicollinearity | VIF | No infinite VIF; investigate extreme values |

**Outlier and influence diagnostics:**
- Cook's D — overall influence of each observation on all coefficients
- Leverage — influence based on predictor values alone (hat matrix diagonal)
- Studentized residuals — standardized residuals; flag |z| > 3

**If assumptions are violated:**
- Right-skewed residuals → log-transform the target
- Heteroscedastic residuals → Box-Cox transformation or log of target
- Nonlinear relationship → bin the continuous predictor into categories
- **Do NOT jump to a complex model as a fix for violated assumptions.** Transform first.

**Metrics:**
- R² (report both training and test — gap reveals overfitting)
- MAE — primary prediction metric; interpretable in original units
- MAPE — useful for comparing across different scales

**Multicollinearity:**
- VIF = Variance Inflation Factor
- High VIF indicates two predictors are nearly collinear — one may be redundant
- Drop the variable with infinite VIF first; reassess iteratively

---

## 2. Categorical Data Analysis (Pre-Modeling)

**When to use:**
- Understanding relationships in the data BEFORE building models
- Informs variable selection, encoding decisions, and what transformations to apply

**This is exploration, not modeling.** Run these tests before Step 8 of the universal
workflow, not after.

**Tools:**

| Relationship | Test | Notes |
|---|---|---|
| Categorical predictor vs. categorical target | Chi-squared test | Check for low cell counts (< 5) |
| Continuous predictor vs. categorical target | ANOVA / F-test | Welch's T when comparing two groups |
| Continuous predictor vs. continuous target | Pearson correlation | Check linearity assumption |

**Outputs:** p-values feed directly into Step 6 (univariate screening at p < 0.009).

---

## 3. Binary Logistic Regression

**When to use:**
- Binary target variable (0/1, yes/no, default/no-default)
- Probability estimates are needed (not just class labels)
- Interpretability is required (regulatory, clinical, explainable AI contexts)
- As the mandatory interpretable baseline before tree ensembles

**Critical pre-check before modeling:**
**Quasi-complete separation:** If any categorical level has all 0s or all 1s for the
target, logistic regression will fail or produce infinite coefficients. Check
cross-tabulations before fitting. Remove offending variables before modeling — do not
attempt to model through this.

**Core assumption:**
Continuous predictor variables must be linearly related to the log-odds of the outcome.
Test this with a GAM or spline fit. If violated, the preferred fix is **binning** —
convert the continuous variable into ordered categories. This preserves interpretability.
Do NOT use polynomial terms or other continuous transforms as a first response.

**Workflow:**
1. Check for quasi-complete separation → remove offending variables
2. Univariate screening (chi-squared / ANOVA, p < 0.009)
3. Multivariate stepwise selection with cross-validation
4. Fit logistic regression
5. Interpret coefficients via odds ratios: OR = exp(coef)
   - Interpretation: "A one-unit increase in X is associated with 100×(OR−1)% higher/lower odds of Y"
6. Likelihood ratio test for multi-level categorical predictors (not individual z-tests)
7. Assess with ranked metrics (AUC, Somer's D, KS) — not accuracy
8. Select threshold based on business cost function (not 0.5)
9. Calibration curve — use on larger samples only; extrapolation risk on small datasets

**Metrics (in priority order):**

| Metric | What it measures | Notes |
|---|---|---|
| AUC / C-statistic | Overall rank-order discrimination | 0.5 = random, 0.7+ = functional, 1.0 = perfect |
| Somer's D | Concordance vs. discordance | = 2×AUC − 1; ranges −1 to 1 |
| KS statistic | Max vertical distance between TPR and FPR curves | Standard in finance/banking |
| F1 score | Harmonic mean of precision and recall | Threshold-dependent |
| Accuracy | Proportion correctly classified | "Easily fooled" — not primary metric |
| Lift / Gains | Improvement over random selection by decile | Top-decile lift most actionable |

**McFadden R²:** Bounded 0–1 but does NOT have the same interpretation as linear R².
Report it for reference but do not treat it as the primary goodness-of-fit measure.

**Threshold selection:**
- Youden's Index: maximizes (Sensitivity + Specificity − 1); balanced approach
- KS maximization: maximum separation; popular in finance
- F1 maximization: balances precision/recall; good with class imbalance
- Business override: if false positives cost 10× more than false negatives, tune the
  threshold to minimize the total cost function — this is the correct framing

---

## 4. Subset Selection and Feature Selection Diagnostics

**When to use:** After univariate screening (Step 6), before fitting complex models.

**Methods in order of preference:**

| Method | Description | Use when |
|---|---|---|
| Stepwise selection | Forward selection + drops insignificant variables at each step | Default choice — most parsimonious |
| Forward selection | Adds one variable at a time by best CV performance | Acceptable; keeps variables stepwise would drop |
| RFE (Recursive Feature Elimination) | Iteratively removes weakest features | **Standardize first** — magnitude-sensitive |

**Why stepwise > forward-only:**
"Stepwise does the same as forward selection with the added benefit of dropping
insignificant variables." More parsimonious models generalize better.

**The p < 0.009 threshold:**
LaBarr uses p < 0.009 as his univariate screening cutoff, not the conventional 0.05.
This is more conservative and reduces the number of variables carried into multivariate
selection, where multiple testing compounds false discovery.

**Parsimony criterion:**
Select the model within **one standard error** of the best cross-validation performance.
This is the 1-SE rule: prefer the simpler model unless the complex one is clearly better.

**Post-selection diagnostics (logistic regression context):**
- Cook's D: observations with Cook's D > 4/n warrant investigation
- DFBetas: change in each coefficient when that observation is removed; > 1 flagged
- Calibration curves: predicted probability vs. observed event rate

---

## 5. Regularized Regression (Ridge, Lasso, Elastic Net)

**When to use:**
- Many predictor variables (p approaches or exceeds n)
- Multicollinearity is present
- Automatic shrinkage or variable selection is desired
- As an alternative to stepwise when the number of variables is very large

**The three methods:**

| Method | What it does | Best for |
|---|---|---|
| Ridge (L2 penalty) | Shrinks all coefficients toward zero; keeps all variables | Multicollinearity; when all predictors contribute |
| Lasso (L1 penalty) | Shrinks some coefficients to exactly zero; performs variable selection | Sparse models; when many predictors are irrelevant |
| Elastic Net (L1 + L2) | Hybrid; groups correlated variables | When p >> n; when correlated predictors should be kept together |

**Tuning parameters:**
- `alpha` (regularization strength) — tune via cross-validated grid search
- `l1_ratio` (Elastic Net only) — proportion of Lasso vs. Ridge penalty; tune via CV

**Required:** Feature scaling before fitting. Regularization penalizes coefficient
magnitude — if variables are on different scales, the penalty is unfair. Use StandardScaler.

**Still follow the universal workflow:** Regularized regression does not replace
exploratory analysis, train/test discipline, or diagnostic checks. It is a modeling
technique, not a preprocessing shortcut.

---

## 6. Tree-Based Methods (Decision Trees, Random Forest, XGBoost)

**When to use:**
- Complex nonlinear relationships
- Feature interactions are important (they are captured automatically)
- No need to engineer interaction terms manually
- Continuous and categorical features mixed
- When interpretable baseline (OLS/Logistic) has been built and benchmarked

**No feature scaling required** — tree-based methods split on thresholds, not distances.

### Decision Tree

**Role:** Building block for understanding; not a production model
- Interpretable if shallow (depth 2–4 is visualizable)
- Deep trees overfit badly — prune aggressively
- Use to understand which variables matter and where splits occur
- Key parameters: `max_depth`, `min_samples_leaf`, `min_samples_split`

### Random Forest

**Philosophy:** Ensemble of decorrelated trees via bootstrap sampling + random feature
subsampling. Decorrelation is the key innovation — it reduces variance without increasing bias.

**Free validation:** `oob_score_` (out-of-bag score) provides a validation estimate
without using the test set. Use it during development; don't mistake it for the final test.

**Key parameters:**
- `n_estimators`: more trees = more stable; 100–500 is typical
- `max_depth`: controls individual tree depth
- `min_samples_leaf`: minimum observations per leaf; higher = more conservative
- `max_features`: number of features considered per split; controls decorrelation

**Feature importance caveat:**
Add a random noise variable and check its rank in feature importance. If it ranks
comparably to real predictors, the importance scores are unreliable for this dataset.
Feature importance is a directional guide, not a causal explanation.

### XGBoost (Gradient Boosting)

**Philosophy:** Sequential ensemble — each tree corrects the residuals of all previous trees.

**Key parameters:**
- `eta` (learning rate): smaller = more conservative; pair with more `n_estimators`
- `subsample`: fraction of training data per tree; < 1.0 adds stochastic regularization
- `max_depth`: controls each tree's depth; 3–6 is typical
- `n_estimators`: number of boosting rounds

**Generally outperforms Random Forest** on structured tabular data in head-to-head comparisons.
Less interpretable than Random Forest because the sequential structure makes contributions harder
to attribute.

**Hyperparameter tuning protocol (both RF and XGBoost):**
1. GridSearchCV first — map the parameter space, find promising regions
2. Optuna / Bayesian optimization second — efficient search within those regions
3. Always 10-fold cross-validation throughout
4. Never use the test set during tuning

**Interpretability bridge:**
Partial dependence plots show the marginal effect of one or two features on the prediction
after averaging over all other features. Directional, not causal — but useful for
communicating model behavior to stakeholders.

**Empirical benchmark from course (housing data):**
- Linear regression MAE: ~baseline
- Decision Tree MAE: ~25,422
- Random Forest MAE: ~16,974
- XGBoost MAE: ~17,825
- Neural Network MAE: ~21,302

Random Forest won on held-out MAE in this example. Complexity (XGBoost, NN) did not win.
**Always compare before declaring a winner.**

---

## 7. Neural Networks (MLPClassifier / MLPRegressor)

**When to use:**
- Very large datasets with complex, high-dimensional patterns
- Prediction accuracy is the dominant objective and interpretability is secondary
- After tree ensembles have been tried and benchmarked

**WARNING:** Do NOT jump to neural networks without first trying tree ensembles.
In LaBarr's empirical examples, neural networks underperformed random forests on tabular
data. Complexity must earn its place.

**Required preprocessing:**
- `StandardScaler` on continuous features — mandatory. Gradient descent is
  magnitude-sensitive; unscaled inputs will cause unstable or slow training.
- Binary/dummy-encoded features: standardize separately or keep unscaled (test both)

**Architecture:**
- `hidden_layer_sizes`: start with a single hidden layer (e.g., `(100,)`); add depth
  only if a shallow network is clearly insufficient
- `activation`: `relu` is default; `tanh` sometimes better for smaller networks
- `alpha`: L2 regularization strength — tune via cross-validation
- `solver`: `adam` is standard; always pair with `early_stopping=True`

**Training discipline:**
- `early_stopping=True`: stops training when validation performance plateaus
- Grid search architecture parameters and regularization together

**Interpretability:**
- Hinton diagrams: visualize weight matrices as colored squares — shows structure,
  not explanation
- Partial dependence plots: limited utility; directional only
- Accept the interpretability tradeoff explicitly when recommending neural networks

---

## 8. Naive Bayes

**When to use:**
- Text classification or NLP tasks
- High-dimensional categorical features
- Small training datasets (strong prior helps)
- When a fast, probabilistic baseline classifier is needed

**The "naive" assumption:**
Features are assumed conditionally independent given the class. This assumption is
almost always violated in practice — but Naive Bayes often performs well despite this,
especially on text and sparse categorical data.

**Variants:**

| Variant | Input type | Use case |
|---|---|---|
| Gaussian NB | Continuous features | Assumes Gaussian distribution per class |
| Multinomial NB | Count/frequency features | Text classification, word counts |
| Bernoulli NB | Binary features | Document classification with 0/1 presence |

**Key watch-out:** Zero-frequency problem — if a feature value never appears with a
class in training data, the posterior probability is zeroed out entirely. Fix with
Laplace smoothing (`alpha > 0`, typically `alpha = 1`).

**Strengths:** Very fast to train and score; works well with high-dimensional sparse
features; interpretable probability outputs.

**Limitation:** Assumes feature independence — cannot model interactions. If interactions
matter, tree-based methods or logistic regression with interaction terms will outperform.

---

## 9. Model-Agnostic Interpretability

**When to use:**
- A complex model (tree ensemble or neural network) has been selected for production
- Explanation of individual predictions or global model behavior is required
- Regulatory, compliance, or stakeholder communication needs

**LaBarr's stance:** These tools describe what the model learned — they do not replace
building an interpretable baseline. SHAP and LIME are supplements to transparency,
not substitutes for starting with interpretable models.

### Partial Dependence Plots (PDP)

**What:** Marginal effect of one or two features on the model's prediction, averaged
across all other features in the dataset.

**Reads as:** "As X increases from low to high, the model's average prediction moves from Y₁ to Y₂."

**Limitation:** Averaging can mask heterogeneous effects. If the relationship varies
substantially across subgroups, PDP shows you the average and hides the variation.

### Individual Conditional Expectation (ICE)

**What:** PDP per observation — one line per row in the dataset.

**Reads as:** Shows variation in the X→prediction relationship across individual cases.
Complement to PDP; reveals heterogeneity that PDP averages away.

### SHAP (SHapley Additive Explanations)

**What:** Feature attribution per prediction. For each observation, SHAP decomposes
the model's output into the contribution of each feature, using Shapley values from
cooperative game theory.

**Why it's the gold standard:**
- Consistent: same feature always gets the same attribution direction
- Locally accurate: SHAP values sum to the model's actual prediction
- Works across all model types

**Use cases:** Explaining individual predictions, identifying which features drove a
specific outcome, global feature importance (mean |SHAP|).

### LIME (Local Interpretable Model-agnostic Explanations)

**What:** Fits a simple linear model in the neighborhood of a specific prediction.
Explains that one prediction using the local linear approximation.

**Trade-off vs. SHAP:** Faster but less stable — perturbing the same observation
slightly can yield different LIME explanations. SHAP is generally preferred when
consistency matters.

### Permutation Importance

**What:** Shuffle one feature's values, measure the drop in model performance. The
magnitude of the drop = that feature's importance.

**Why it's more reliable than tree-native importance:** Tree-native importance is
biased toward high-cardinality features. Permutation importance is algorithm-agnostic
and measures actual predictive contribution.

---

## 10. Generalized Additive Models (GAM)

**When to use:**
- Nonlinear relationships exist between predictors and the target, but manual feature
  engineering (log transforms, binning) hasn't resolved them
- Interpretability is still required — you want to see the shape of each predictor's effect
- As an alternative to tree ensembles when stakeholders need to understand individual variable curves

**Position on the complexity spectrum:**
GAMs sit between regularized regression and tree-based methods. They maintain additive
structure (each predictor contributes a separate smooth function) while capturing nonlinearity.
"Allows nonlinear relationships without trying out many transformations manually" — but
interactions between variables are "computationally intensive" and limited.

**Workflow:**
1. Apply same data preparation as standard regression (missingness, dummy coding)
2. **Pre-screen variables first** — GAMs do not scale well with many predictors; run
   univariate screening before model specification
3. Specify which variables get smoothing splines vs. linear terms
4. Fit — smoothing parameters are optimized automatically via generalized cross-validation (GCV)
5. Review effective degrees of freedom (edf) per smooth term: edf near 1 = near-linear relationship
6. Review p-values; use `select = TRUE` to automatically penalize and remove weak variables
7. Plot fitted relationships against observed data to check reasonableness
8. Compare test set MAE/MAPE against OLS baseline

**What to watch for:**
- **MARS/EARTH variant:** Initially overfits; pruning via GCV mitigates this; knot positions
  shift when additional variables enter the model
- **Multicollinearity:** Still a problem in GAMs — same issue as linear regression
- **Variable importance instability:** Adding or removing variables shifts knot positions
- **Complexity doesn't guarantee gain:** In LaBarr's Ames housing example, OLS MAE ($18,160)
  and GAM MAE ($18,154) were essentially equal — the simpler model won on parsimony grounds

**Explicit rules:**
- DO: Pre-screen variables before GAM fitting
- DO: Compare against OLS baseline before concluding GAM is worth the complexity
- DO NOT: Use GAMs with large variable sets without prior selection
- DO NOT: Iterate using the test set after initial scoring

---

## 11. Explainable Boosting Machine (EBM)

**When to use:**
- You need near-XGBoost prediction performance but cannot sacrifice interpretability
- Regulatory or stakeholder context requires explanation of individual variable effects
- GAM-level transparency is needed but with higher predictive power than GAM

**Position on the complexity spectrum:**
EBMs sit between GAMs and Random Forest. Core innovation: "EBMs aim to have the predictive
power seen in XGBoost models but maintain the kind of interpretability that GAM models have."
Each variable's contribution is estimated separately (GAM structure), but through a
gradient-boosting process rather than spline fitting.

**How it works:**
EBMs build each variable's effect one at a time using small trees, cycling through all
variables in round-robin fashion for thousands of iterations. Small learning rates ensure
the ordering of variables does not matter — all variables converge to stable estimates.

**Workflow:**
1. Same data preparation as any supervised model
2. Fit EBM (Python: `interpret` library; R support is limited)
3. Use variable importance scores to guide feature selection
4. **Sanity check:** Add a random noise variable; any variable ranking below it should be
   considered for removal
5. Interpret via individual variable plots (nonlinear curves, same visual as GAM)
6. Compare test set performance against Random Forest and logistic regression baselines

**Interpretation:**
- Continuous targets: importance score = average dollar/unit impact on prediction
- Binary targets: importance score = change in log-odds (logit scale)
- Individual plots show each variable's full nonlinear effect — same transparency as GAM

**Performance context (LaBarr's Ames housing data):**
- EBM MAE: $18,774
- Random Forest MAE: $16,974
- GAM MAE: $18,154

EBM outperforms GAM but does not close the gap to Random Forest. The tradeoff: full
interpretability at ~10% performance cost vs. Random Forest.

**Explicit rules:**
- DO: Use the random variable sanity check for feature selection
- DO: Treat EBM as the interpretable alternative to tree ensembles, not as a replacement for GAM
- DO NOT: Rebuild the model after scoring the test set — this compromises validation integrity
- DO NOT: Assume EBM is available across all software environments (R support is constrained)

---

## Do/Don't Summary Table

| Decision point | Do | Don't |
|---|---|---|
| Starting a project | Frame the problem; define target; apply business logic | Jump to algorithm selection |
| Missing values (categorical) | Create "Missing" category | Impute with mode |
| Missing values (continuous) | Impute with training median + create flag variable | Impute before train/test split |
| Imputation complexity | Use simple mean/median | Use predictive imputation models (no empirical benefit) |
| Train/test split timing | Split before any imputation statistics | Split after calculating medians/means on full data |
| Univariate screening threshold | p < 0.009 | Default to p < 0.05 |
| Feature selection with RFE | Standardize features first | Run RFE on unscaled features |
| Model sequencing | Build interpretable baseline first | Jump to XGBoost or neural networks first |
| Diagnostic violations (OLS) | Transform (log, Box-Cox, bin) and refit | Bypass to complex model |
| Quasi-complete separation | Remove the offending variable before fitting | Attempt to model through it |
| Logistic nonlinearity | Bin the continuous predictor | Use polynomial terms |
| Feature importance | Run sanity check with random noise variable | Accept feature importance at face value |
| Threshold selection | Use business cost function | Default to 0.5 |
| Accuracy metric | Use as context, not primary criterion | Use as primary metric with imbalanced classes |
| Neural networks | Standardize inputs; use early stopping; benchmark vs. RF first | Use as first model tried |
| Model complexity | Earn it with demonstrated held-out performance gain | Accept by default |
| GAM variable count | Pre-screen variables before fitting | Feed all variables into a GAM without selection |
| GAM vs. OLS | Compare test MAE before concluding GAM adds value | Assume nonlinear modeling beats linear |
| EBM availability | Use Python `interpret` library; verify R support before committing | Assume EBM works identically across all platforms |
| EBM feature selection | Add random noise variable; drop anything ranking below it | Accept default variable importance without sanity check |
| EBM validation | Score test set once; stop | Rebuild after seeing test results |
