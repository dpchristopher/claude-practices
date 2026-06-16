# ML Discipline Rules

> Auto-loaded at session start. Apply to any ML, forecasting, analytics, or modeling work.

---

## Invoke labarr-ml First

Before designing any ML pipeline, invoke `/labarr-ml`.

It covers the 12-step ML workflow, 11 algorithm families, time series methodology, credit modeling, and risk analysis. Do not start building until you've run through it.

---

## Experiment Tracking

Every training run gets its own directory under `experiments/`:

```
experiments/
  ├── 001-baseline/
  │   ├── hparams.json        ← ALL hyperparams (learning rate, batch size, epochs, random seed, etc.)
  │   ├── metrics.csv         ← eval results (accuracy, F1, precision, recall, AUC, loss)
  │   ├── train_log.txt       ← loss per epoch, warnings, timing
  │   ├── model.pkl           ← trained model artifact
  │   ├── data_manifest.json  ← { "dataset": "...", "hash": "...", "date": "...", "rows": N }
  │   └── README.md           ← what was different from prior run, findings, next steps
  └── manifest.json           ← { "experiments": [...], "best_model": "002-name", "best_metric": "F1=0.87" }
```

- Number runs sequentially: 001, 002, 003
- `manifest.json` is the single source of truth for which run is best and why
- Never scatter artifacts — hparams, metrics, and model always live together in one run dir
- Compare runs: `diff experiments/001-baseline/metrics.csv experiments/002-name/metrics.csv`

---

## Reproducibility Checklist

Before any model goes to production or is shared:

- [ ] Random seeds set and documented in hparams.json (`random_state`, `np.random.seed`, `torch.manual_seed`)
- [ ] `requirements.txt` pinned to exact versions (`pip freeze > requirements.txt`)
- [ ] Dataset hash recorded in `data_manifest.json`
- [ ] Training script is deterministic (same inputs → same outputs)
- [ ] Model artifact saved with version info
- [ ] README.md in experiment dir explains how to reproduce

---

## Common ML Pitfalls — Prevent These

| Pitfall | How to prevent |
|---|---|
| **Data leakage** | Split train/val/test BEFORE any feature engineering or scaling |
| **Distribution shift** | Compare train vs. production data distributions before deploying |
| **Target leakage** | Audit features — does any feature use information from the future or from the target? |
| **Overfitting** | Use holdout test set not touched during tuning; cross-validate on train |
| **Improper scaling** | Fit scaler on train only; transform val/test with fitted scaler |
| **Class imbalance** | Check class distribution before training; use stratified splits |
| **Lookahead in time series** | Sort by time before splitting; never shuffle time series data |
| **Metric mismatch** | Agree on eval metric before training — business metric vs. ML metric |

---

## TDD for ML

1. Define the eval metric and acceptance threshold **before** training (e.g., "F1 > 0.82 on holdout")
2. Write the evaluation code first
3. Train the model
4. Run evaluation — pass/fail against threshold
5. Only tune if you failed — don't tune until you have a baseline

Holdout test set is **never touched** during development. It is used once: final evaluation before production.

---

## Verification Before Shipping

Before any model goes to production:

1. Evaluate on holdout test set (not validation)
2. Check metrics against acceptance threshold
3. Sanity check predictions manually (do they make sense?)
4. Document performance in experiment README.md
5. Update `experiments/manifest.json` with final results
