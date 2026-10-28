library(readr)
library(dplyr)
library(tseries)
library(forecast)
library(ggplot2)
library(gridExtra)
data = read_csv("CTA_-_Ridership_-_Daily_Boarding_Totals_2026.csv")
data$service_date = as.Date(data$service_date, format="%m/%d/%Y")
data$covid_dummy = ifelse(data$service_date >= as.Date("2020-03-01"), 1, 0)
ts_data = ts(data$total_rides, start = c(2001, 1), frequency = 365)
ts_bus  = ts(data$bus, start = c(2001, 1), frequency = 365)
ts_rail = ts(data$rail_boardings, start = c(2001, 1), frequency = 365)
par(mfrow = c(3,1))
plot(ts_data, main = "Daily Ridership Time Series", xlab = "Year", ylab = "Total Rides", xaxt = "n")
axis(1, at = seq(2001, 2026, by = 1), labels = seq(2001, 2026, by = 1))
plot(ts_bus, main = "Daily Bus Ridership Time Series", xlab = "Year", ylab = "Bus Rides", xaxt = "n")
axis(1, at = seq(2001, 2026, by = 1), labels = seq(2001, 2026, by = 1))
plot(ts_rail, main = "Daily Rail Ridership Time Series", xlab = "Year", ylab = "Rail Rides", xaxt = "n")
axis(1, at = seq(2001, 2026, by = 1), labels = seq(2001, 2026, by = 1))
par(mfrow = c(1,1))
after_Covid = data %>% 
  filter(service_date >= as.Date("2021-09-01"))
ts_Covid = ts(after_Covid$total_rides, start = c(2021, 9), frequency = 365)
stl_Covid = stl(ts_Covid, s.window = "periodic", robust = TRUE)
plot(stl_Covid, main = "STL Decomposition")
sa_stl_Covid = seasadj(stl_Covid)
adf.test(sa_stl_Covid)
kpss.test(sa_stl_Covid)
par(mfrow = c(2,1))
acf(sa_stl_Covid, main = "ACF of Seasonally Adjusted Series")
pacf(sa_stl_Covid, main = "PACF of Seasonally Adjusted Series")
par(mfrow = c(1,1))
model_111 = arima(sa_stl_Covid, order = c(1,1,1))
model_211 = arima(sa_stl_Covid, order = c(2,1,1))
model_311 = arima(sa_stl_Covid, order = c(3,1,1))
model_212 = arima(sa_stl_Covid, order = c(2,1,2))
model_312 = arima(sa_stl_Covid, order = c(3,1,2))
model_313 = arima(sa_stl_Covid, order = c(3,1,3))
AIC(model_111, model_211, model_311, model_212, model_312, model_313)
best_model = model_313
checkresiduals(best_model)
adf.test(residuals(best_model))
kpss.test(residuals(best_model))
par(mfrow = c(2,1))
acf(residuals(best_model), main = "ACF of Residuals")
pacf(residuals(best_model), main = "PACF of Residuals")
par(mfrow = c(1,1))
Box.test(residuals(best_model), lag = 30, type = "Ljung")
sarima= arima(sa_stl_Covid,
                    order = c(3,1,3),
                    seasonal = list(order = c(0,0,1), period = 7))
checkresiduals(sarima)
adf.test(residuals(sarima))
kpss.test(residuals(sarima))
acf(residuals(sarima), main = "ACF of SARIMA Residuals")
pacf(residuals(sarima), main = "PACF of SARIMA Residuals")
Box.test(residuals(sarima), lag = 30, type = "Ljung")
sarimax_model = arima(data$total_rides,
                      order = c(3,1,2),
                      seasonal = list(order = c(1,0,1), period = 7),
                      xreg = data$covid_dummy)
res_sarimax = na.omit(residuals(sarimax_model))
adf.test(res_sarimax)
kpss.test(res_sarimax)
AIC(sarimax_model,
    sarima,
    best_model)
forecast= forecast(sarima, h = 31)
seasonality_march = stl_Covid$time.series[, "seasonal"][
  (after_Covid$service_date >= as.Date("2025-03-01") &
  after_Covid$service_date <= as.Date("2025-03-31"))]
forecast_final = as.numeric(forecast$mean) + as.numeric(seasonality_march)
mean(forecast_final)
sum(forecast_final)
forecast_ts = ts(forecast_final, start = c(2026, 3), frequency = 365)
p1 = autoplot(forecast_ts) +
  xlab("Date") +
  ylab("Ridership") +
  ggtitle("Time Series Forecast for March 2026")
march_2025 = data %>% 
  filter(service_date >= as.Date("2025-03-01") & service_date <= as.Date("2025-03-31"))
mean(march_2025$total_rides)
sum(march_2025$total_rides)
p2 = autoplot(ts(march_2025$total_rides, start = c(2025, 3), frequency = 365)) +
  xlab("Date") +
  ylab("Ridership") +
  ggtitle("Actual Ridership for March 2025")
grid.arrange(p1, p2, ncol = 1)