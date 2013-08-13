import platt

[a, b] = platt.SigmoidTrain([0.5, 0.6, 0.7], [1, -1, 1])
print a, b
predictor = platt.PredictorGenerator([a, b])
s = predictor(0.5)
print s
