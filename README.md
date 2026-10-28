# Chicago Transit Ridership: Time-Series Forecast

An R project analyzing daily Chicago Transit Authority ridership. It examines total, bus, and rail rides, decomposes post-2021 ridership into trend and seasonal components, compares ARIMA-family models, and produces a 31-day forecast for March 2026.

## Analytical workflow

1. **Prepare the time series.** Read the CTA CSV, parse service dates, and create a COVID-era indicator.
2. **Explore ridership patterns.** Plot total, bus, and rail series, then focus on the later period and use robust STL decomposition to inspect trend and weekly seasonality.
3. **Check time-series properties.** Apply Augmented Dickey–Fuller and KPSS tests and inspect ACF/PACF plots to inform model assessment.
4. **Fit and compare models.** Estimate several ARIMA specifications and a weekly seasonal model, compare information criteria, and inspect residuals with diagnostic plots and a Ljung–Box test.
5. **Forecast and compare.** Generate a 31-day forecast and compare the March 2026 projection with actual March 2025 ridership.

## Tools and language

- **R** for data processing, statistical testing, time-series modeling, and plots.
- `readr` and `dplyr` for data import and transformation.
- `forecast` and `tseries` for forecasting methods and time-series diagnostics.
- `ggplot2` and `gridExtra` for forecast visualization and plot layout.

## Project files

- `ridership_forecasting.R` — complete analysis script.

## Data and running the analysis

The script expects `CTA_-_Ridership_-_Daily_Boarding_Totals_2026.csv` in its working directory. Put the CSV beside the script, set the working directory to this project folder, install the packages above, and run the script.

## Interpretation

The forecast depends on the chosen training window, seasonal specification, and model assumptions. The March 2025 comparison is a historical reference, not a substitute for a proper out-of-sample evaluation across multiple forecast origins.
