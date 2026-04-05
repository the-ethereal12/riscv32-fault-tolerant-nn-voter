import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import joblib

# ================================
# Generate Better Training Data
# Including DOUBLE fault cases
# where majority voter FAILS!
# ================================
def generate_data(samples=10000):
    X = []
    y = []  # 0=CPU1 correct, 1=CPU2 correct, 2=CPU3 correct

    for _ in range(samples):
        correct_pc = np.random.randint(0, 1000) * 4
        fault_type = np.random.randint(0, 6)

        if fault_type == 0:
            # No fault — all agree
            c1, c2, c3 = correct_pc, correct_pc, correct_pc
            label = 0

        elif fault_type == 1:
            # CPU1 faulty — majority voter handles this
            c1 = correct_pc + np.random.randint(100, 5000)
            c2, c3 = correct_pc, correct_pc
            label = 1  # CPU2 is correct

        elif fault_type == 2:
            # CPU2 faulty — majority voter handles this
            c2 = correct_pc + np.random.randint(100, 5000)
            c1, c3 = correct_pc, correct_pc
            label = 0  # CPU1 is correct

        elif fault_type == 3:
            # CPU3 faulty — majority voter handles this
            c3 = correct_pc + np.random.randint(100, 5000)
            c1, c2 = correct_pc, correct_pc
            label = 0  # CPU1 is correct

        elif fault_type == 4:
            # CPU1 + CPU2 faulty — majority voter FAILS here!
            c1 = correct_pc + np.random.randint(100, 5000)
            c2 = correct_pc + np.random.randint(100, 5000)
            c3 = correct_pc
            label = 2  # only CPU3 is correct

        else:
            # CPU1 + CPU3 faulty — majority voter FAILS here!
            c1 = correct_pc + np.random.randint(100, 5000)
            c3 = correct_pc + np.random.randint(100, 5000)
            c2 = correct_pc
            label = 1  # only CPU2 is correct

        X.append([c1, c2, c3])
        y.append(label)

    return np.array(X), np.array(y)

# ================================
# Train Model
# ================================
print("Generating training data...")
X, y = generate_data(10000)

# Normalize
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

print("Training ML voter...")
model = MLPClassifier(
    hidden_layer_sizes=(32, 16),
    max_iter=1000,
    random_state=42,
    verbose=False
)
model.fit(X_train, y_train)
ml_score = model.score(X_test, y_test)

# ================================
# Compare with Majority Voter
# on SAME test data
# ================================
def majority_voter(c1, c2, c3):
    if c1 == c2: return 0  # CPU1
    if c2 == c3: return 1  # CPU2
    if c1 == c3: return 0  # CPU1
    return 0  # fallback

# Get original unscaled test data
X_test_orig = scaler.inverse_transform(X_test)

correct_majority = 0
for i in range(len(X_test)):
    c1, c2, c3 = int(X_test_orig[i][0]), \
                  int(X_test_orig[i][1]), \
                  int(X_test_orig[i][2])
    pred = majority_voter(c1, c2, c3)
    if pred == y_test[i]:
        correct_majority += 1

majority_acc = correct_majority / len(X_test) * 100

print("\n================================")
print("       ML VOTER RESULTS         ")
print("================================")
print(f"Simple Majority Voter: {majority_acc:.2f}%")
print(f"ML Voter Accuracy:     {ml_score*100:.2f}%")
print(f"Improvement:           {ml_score*100 - majority_acc:.2f}%")
print("================================")

if ml_score*100 > majority_acc:
    print("ML voter BEATS majority voter!")
else:
    print("Both performing well!")

# Save model and scaler
joblib.dump(model, 'ml_voter_model.pkl')
joblib.dump(scaler, 'scaler.pkl')
print("\nModel saved → ml_voter_model.pkl")
print("Done!")