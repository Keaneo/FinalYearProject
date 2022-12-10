import os
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import tarfile
from causalty import *


#Expand all the tar files in a subdirectory
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

    #Load 
    def read(self, path, prop_type_class, prop_type, file_type = '.npy'):
        for npy in os.listdir(path):
            if npy.endswith(file_type) and npy.startswith(prop_type):
                prop = npy.split('.')[1]
                setattr(prop_type_class, prop, np.load(path + '/' + npy))
        return prop_type_class

    #Average values over a sample size, bin_size in milliseconds
    #x is the time values
    #y is the actual values to be binned
    def bin_values(self, bin_size, x, y, rangeMin, rangeMax):
        time_elapsed = 0 #milliseconds
        current_bin = []
        binned_values = []
        counter = 0
        for i in range(rangeMin, rangeMax):
            time_elapsed += x[i] - (x[i-1] if i-1 >= 0 else 0)
            current_bin.append((x[i][0], y[i][0]))
            if time_elapsed >= bin_size:
                xBin = sum(list(zip(*current_bin))[0]) / len(current_bin)
                yBin = sum(list(zip(*current_bin))[1]) / len(current_bin)
                binned_values.append((xBin, yBin))
                time_elapsed = 0
                current_bin.clear()
            counter += 1
        return binned_values

    

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

#channel1 = Channels('Cori_2016-12-14')


mouse_name = "Moniz_2017-05-15"
mouse = Mouse(mouse_name)

binned = mouse.bin_values(0.005, mouse.spikes.times, mouse.spikes.amps, 1, 1000)

fig = plt.figure()
#plt.plot(list(zip(*binned))[0], list(zip(*binned))[1])
#plt.scatter(mouse.spikes.times[0:1000][0], mouse.spikes.times[0:1000][1])
#plt.show()

time_range = {
    "start": 0,
     "end": 100,
     }

ax = plt.subplot(111)
#print(mouse.trials.intervals[:10])
#Spike times as a vertical lines
#for i in range(len(mouse.trials.intervals)):
plt.vlines(mouse.spikes.times[0:100], 0, 1)

#Shade background for stimulus timings - timing doesn't line up as I expected
plt.axvspan(mouse.trials.visualStim_times[0], mouse.trials.visualStim_times[1], alpha=0.1, color='g')

#print(mouse.lick.times[0:50])
#print(len(mouse.lick.times))
print(mouse.clusters.peakChannel)

plt.plot(mouse.spikes.times)
#Show plot
#plt.show()

