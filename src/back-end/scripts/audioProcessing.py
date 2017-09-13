import os
import sys
import numpy as np
import scipy
from pyaudio_analysis import audioTrainTest as aT
from pyaudio_analysis import audioBasicIO
from pyaudio_analysis import audioFeatureExtraction

def findMostProbableClass(P, C):
	index = np.argmax(P)
	return C[index]

def most_common(arr):
	return max(set(arr), key=arr.count)

if len(sys.argv) == 2: 
    filepath = "/Users/apinilla/Sites" + sys.argv[1][1:]
    if os.path.exists(filepath):
    	svm_classifier, svm_probabilities, svm_classes = aT.fileClassification(filepath, "/Users/apinilla/Sites/scripts/svmMusicGenre3","svm")
    	knn_classifier, knn_probabilities, knn_classes = aT.fileClassification(filepath, "/Users/apinilla/Sites/scripts/knnMusicGenre3","knn")
    	et_classifier, et_probabilities, et_classes = aT.fileClassification(filepath, "/Users/apinilla/Sites/scripts/etMusicGenre3","extratrees")
    	gb_classifier, gb_probabilities, gb_classes = aT.fileClassification(filepath, "/Users/apinilla/Sites/scripts/gbMusicGenre3","gradientboosting")
    	rf_classifier, rf_probabilities, rf_classes = aT.fileClassification(filepath, "/Users/apinilla/Sites/scripts/rfMusicGenre3","randomforest")
    	classifications = []
    	classifications.append(findMostProbableClass(svm_probabilities, svm_classes))
    	classifications.append(findMostProbableClass(knn_probabilities, knn_classes))
    	classifications.append(findMostProbableClass(et_probabilities, et_classes))
    	classifications.append(findMostProbableClass(gb_probabilities, gb_classes))
    	classifications.append(findMostProbableClass(rf_probabilities, rf_classes))
    	print(most_common(classifications))


