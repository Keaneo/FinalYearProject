#Link to datasets
#Synth-data, random: https://www.kaggle.com/datasets/passwordclassified/synthesised-time-series-data

#Weather data: https://www.kaggle.com/datasets/sumanthvrao/daily-climate-time-series-data
#Using this one to predict temp based on the other inputs

#Imports
from causalty.mvar import *
from statsmodels.tsa.stattools import grangercausalitytests
from statsmodels.stats.stattools import durbin_watson
from statsmodels.tsa.api import VAR
import statsmodels.tsa.stattools as ts
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np


#Read the data from the toy dataset csv file
data = pd.read_csv('./r1r2.csv', index_col='index')

#Drop the rows with missing data
data = data.dropna()

#Display some information on the data
print(data.shape)
print(data.columns)
print(data.head(5))

#Ensure the index is an integer
#Can be changed for other types
data.index = data.index.astype(int)
print(data.index)



#Temporary variable to hold column names that we want to process
#Can be used to reduce the number of variables we want to test in a large dataset
variables = data.columns

#Create a dataframe to hold the p-values
df = pd.DataFrame(np.zeros((len(variables), len(variables))), columns=variables, index=variables)

#Traverse the dataframe, test each pair of variables for Granger Causality and save the p-value
for c in df.columns:
    for r in df.index:
        test_result = grangercausalitytests(data[[r, c]], maxlag=3, verbose=False)
        p_values = [round(test_result[i+1][0]['ssr_chi2test'][1],4) for i in range(3)]
        min_p_value = np.min(p_values)
        df.loc[r, c] = min_p_value
#Label the columns and rows of the dataframe
df.columns = [var + '_x' for var in variables]
df.index = [var + '_y' for var in variables]

#Fit a Variable Auto Regressive Model to the data
model = VAR(data)
model_fitted = model.fit(3)

#Check for autocorrelation in the model
#i.e ensure we get meaningful results, not correlating to itself
out = durbin_watson(model_fitted.resid)

#Print the Durbin-Watson result for each variable
#It should be close to 2 for no autocorrelation
for col, val in zip(data.columns, out):
    print(col, ':', round(val, 2))

#Save the dataframe as a csv file for analysis in Excel
#Disabled for demo purposes
#df.to_csv('output.csv')

