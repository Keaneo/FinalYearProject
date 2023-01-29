#Imports
import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tarfile
from causalty import *
import itertools


#Utility to expand all the tar files in a subdirectory
#For extracting the data in the Steinmetz et al. dataset
def extract_data():
    for zip in os.listdir("./allData"):
        if zip.endswith(".tar"):
            tar = tarfile.open("./allData/" + zip, "r:")
            tar.extractall("./allData/" + (zip[:-4]))
            tar.close()

#Mouse: Stores utility methods & data for neural data
#Makes for easy access to many functions for processing the data
#All data is an attribute of the class, eg. Mouse.spikes.times
class Mouse:
    def __init__(self, mouse_name) -> None:
        self.mouse_name = mouse_name
        self.channels = Channels(self).setup()
        self.clusters = Clusters(self).setup()
        self.eye = Eye(self).setup()
        self.face = Face(self).setup()
        self.lick = Lick(self).setup()
        self.passive = Passive(self).setup()
        self.probes = Probes(self).setup()
        self.sparse_noise = SparseNoise(self).setup()
        self.spikes = Spikes(self).setup()
        self.trials = Trials(self).setup()
        self.wheel = Wheel(self).setup()

    #Load info from numpy files
    def read(self, path, prop_type_class, prop_type, file_type = '.npy'):
        for npy in os.listdir(path):
            if npy.endswith(file_type) and npy.startswith(prop_type):
                prop = npy.split('.')[1]
                setattr(prop_type_class, prop, np.load(path + '/' + npy))
        return prop_type_class

    #NOT ACCURATE - DO NOT USE
    #Average values over a sample size, bin_size in milliseconds
    #x is the time values
    #y is the actual values to be binned
    def bin_values(self, bin_size, x, y, rangeMin, rangeMax):
        time_elapsed = 0 #milliseconds
        current_bin = []
        binned_values = []
        counter = 0
        for i in range(rangeMin, rangeMax):
            time_elapsed += float(x[i] - (x[i-1] if i-1 >= 0 else 0))
            current_bin.append((x[i][0], y[i][0]))
            if time_elapsed >= bin_size:
                xBin = sum(list(zip(*current_bin))[0]) / len(current_bin)
                yBin = sum(list(zip(*current_bin))[1]) / len(current_bin)
                binned_values.append((xBin, yBin))
                time_elapsed = 0
                current_bin.clear()
            counter += 1
        return binned_values

    #Bin time series data using pandas
    # def bin_time_series(self, bin_size, time_series, const_array_scale = 1):
    #     bin_size = int(bin_size * const_array_scale)
    #     time_series = list(itertools.chain(*(time_series * const_array_scale).astype(int)))
    #     print(bin_size)
    #     print(time_series[:10])
    #     bins = pd.cut(time_series, bins=range(0, np.max(time_series) + bin_size, bin_size))
    #     return bins
    def count_timestamps_in_bins(self, timestamps, bin_size):
        timestamp_counts = {}
        for timestamp in np.nditer(timestamps):
            bin_start = timestamp - (timestamp % bin_size)
            if bin_start not in timestamp_counts:
                timestamp_counts[bin_start] = 0
            timestamp_counts[bin_start] += 1
        return timestamp_counts

    
#Below are the individual classes for each type of data
#Each class has a setup method that returns an instance of the class
#The setup method loads the data from the numpy files
#The data is stored as an attribute of the class
#eg. Mouse.spikes.times

class Channels:
    def __init__(self, mouse) -> None:
        self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'channels')

class Clusters:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'clusters')

class Eye:
    def __init__(self, mouse) -> None:
           self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'eye')

class Face:
    def __init__(self, mouse) -> None:
        self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'face')

class Lick:
    def __init__(self, mouse) -> None:
           self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'lick')

class Passive:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'passive')

class Probes:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'probes')
class SparseNoise:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'sparseNoise')

class Spikes:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'spikes')
class Trials:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
        return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'trials')

class Wheel:
    def __init__(self, mouse) -> None:
            self.mouse = mouse

    def setup(self):
       return self.mouse.read('./allData/' + self.mouse.mouse_name, self, 'wheel')


#Example usage

#Create a mouse object, input the name of the mouse
mouse_name = "Moniz_2017-05-15"
mouse = Mouse(mouse_name)

#Create a dictionary of the time range to plot for easy syncing of data timestamps
time_range = {
    "start": 0,
     "end": 100,
     }

#Timestamps not synced yet, so we take the first x values instead
num_values = 2000

fig, ax = plt.subplots()

#Print the first 100 trial intervals,
#This tells us how long each trial was in seconds
#print(mouse.trials.intervals[:100])

#Count the timestamps in each bin of 0.005 seconds
fr = mouse.count_timestamps_in_bins(mouse.spikes.times[:num_values], 0.005)
keys, values = np.array(list(fr.keys())), np.array(list(fr.values()))
#print(values, keys)

#Setup bar chart
ax.bar(keys, values, width=0.005, edgecolor='black', linewidth=0.5)
ax.plot(keys, values, color='red', linewidth=0.5)

#Make bar chart look nice
ax.grid(visible=True, linestyle='--')
ax.set_xlabel('Time (s)')
ax.set_ylabel('Firing Rate (mHz)')

#Set plot title
ax.set_title("Firing Rate of " + mouse_name + "'s first "+ str(num_values) +" spikes")
plt.xticks(rotation=45)
plt.style.use('ggplot')

#Old attempt
# firing_rates = mouse.bin_time_series(0.005, mouse.spikes.times, 100000)
# print(firing_rates.value_counts())
# print(firing_rates[:50])
# plt.plot(firing_rates)

#Show the plot
plt.show()

