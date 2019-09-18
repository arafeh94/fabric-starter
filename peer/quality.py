import sys
import os.path
import json
from sklearn.mixture import GaussianMixture, BayesianGaussianMixture
import numpy as np

def is_json(myjson):
  try:
    json_object = json.loads(myjson)
  except ValueError as e:
    return False
  return True

def normalise(data):
    result = []
    for element in data:
        cal = (element - min(data)) / (max(data) - min(data))
        result.append(cal)
    return result


if len(sys.argv) != 2:
    print("The arguments are: ", str(sys.argv))
    sys.exit('must have one argument which is the data in json format')

if not is_json(sys.argv[1]):
    print("The arguments are: ", str(sys.argv))
    sys.exit("the input data " + sys.argv[1] + " is not json")

try:
    data = json.loads(sys.argv[1])
    gmm = GaussianMixture(n_components=1).fit(data)
    w, means, covs = gmm.weights_, gmm.means_, gmm.covariances_
    score = gmm.score_samples(data)
    print(json.dumps(score.tolist()))
except Exception as ex:
    print("exception processing the data", ex)

