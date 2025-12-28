
import numpy as np
from sklearn.metrics import confusion_matrix, classification_report
import matplotlib.pyplot as plt

y_true = [0,0,1,1,0,1]
y_pred = [0,1,1,1,0,0]

cm = confusion_matrix(y_true, y_pred)
print("Confusion Matrix:\n", cm)
print(classification_report(y_true, y_pred))

plt.imshow(cm)
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("True")
plt.colorbar()
plt.savefig("confusion_matrix.png")
