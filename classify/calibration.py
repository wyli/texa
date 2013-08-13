import platt

[a, b] = platt.SigmoidTrain([0.5, 0.6, 0.7], [1, -1, 1])
print a, b
s = platt.SigmoidPredict(0.5, [a, b])
print s
