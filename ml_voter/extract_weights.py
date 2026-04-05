import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.preprocessing import StandardScaler

# Retrain the model
np.random.seed(42)
X = []
y = []

for _ in range(3000):
    correct_pc = np.random.randint(0, 1024) * 4
    case = np.random.choice(['no_fault', 'single_fault', 'double_fault'])

    if case == 'no_fault':
        sample = [correct_pc, correct_pc, correct_pc]
        label = 0

    elif case == 'single_fault':
        faulty = np.random.randint(0, 0xFFFFFF)
        which = np.random.choice([0, 1, 2])
        sample = [correct_pc, correct_pc, correct_pc]
        sample[which] = faulty
        label = next(i for i in [0, 1, 2] if i != which)

    else:
        faulty1 = np.random.randint(0, 0xFFFFFF)
        faulty2 = np.random.randint(0, 0xFFFFFF)
        which = [[0,1],[0,2],[1,2]][np.random.randint(0,3)]
        sample = [correct_pc, correct_pc, correct_pc]
        sample[which[0]] = faulty1
        sample[which[1]] = faulty2
        label = next(i for i in [0, 1, 2] if i not in which)

    X.append(sample)
    y.append(label)

X = np.array(X)
y = np.array(y)

split = int(0.8 * len(X))
X_train = X[:split]
y_train = y[:split]

scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)

model = MLPClassifier(
    hidden_layer_sizes=(16, 8),
    activation='relu',
    max_iter=500,
    random_state=42
)
model.fit(X_train, y_train)

print('=== SCALER ===')
print('Mean:', scaler.mean_)
print('Scale:', scaler.scale_)

print('=== LAYER 0 WEIGHTS ===')
print(model.coefs_[0])
print('=== LAYER 0 BIAS ===')
print(model.intercepts_[0])

print('=== LAYER 1 WEIGHTS ===')
print(model.coefs_[1])
print('=== LAYER 1 BIAS ===')
print(model.intercepts_[1])

print('=== LAYER 2 WEIGHTS ===')
print(model.coefs_[2])
print('=== LAYER 2 BIAS ===')
print(model.intercepts_[2])