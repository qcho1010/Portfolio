import numpy as np

alphas = [0.001, 0.01, 0.1, 1, 10, 100, 1000]
hidden_dim = 4
dropout_percent = 0.2
do_dropout = False

# compute sigmoid nonlinearity
def sigmoid(x):
    output = 1 / (1 + np.exp(-x))
    return output


# convert output of sigmoid function to its derivative
def d_sigmoid(output):
    return output * (1 - output)


X = np.array([[0, 0, 1],
              [0, 1, 1],
              [1, 0, 1],
              [1, 1, 1]])

y = np.array([[0],
              [1],
              [1],
              [0]])

for alpha in alphas:
    print("\nTraining With Alpha:" + str(alpha))
    np.random.seed(1)

    # randomly initialize our weights with mean 0
    w0 = 2 * np.random.random((3, hidden_dim)) - 1
    w1 = 2 * np.random.random((hidden_dim, 1)) - 1

    for j in range(60000):

        # Feed forward through layers 0, 1, and 2
        L0 = X
        L1 = sigmoid(np.dot(L0, w0))
        if (do_dropout):
            L1 *= np.random.binomial(
                [np.ones((len(X), hidden_dim))], 1 - dropout_percent)[0] * \
                  (1.0 / (1 - dropout_percent))

        L2 = sigmoid(np.dot(L1, w1))

        # how much did we miss the target value?
        L2_err = L2 - y

        if (j % 10000) == 0:
            print("Error after " + str(j) + " iterations:" + str(np.mean(np.abs(L2_err))))

        # in what direction is the target value?
        # were we really sure? if so, don't change too much.
        L2_delta = L2_err * d_sigmoid(L2)

        # how much did each l1 value contribute to the l2 error (according to the weights)?
        L1_err = L2_delta.dot(w1.T)

        # in what direction is the target l1?
        # were we really sure? if so, don't change too much.
        L1_delta = L1_err * d_sigmoid(L1)

        w1 -= alpha * (L1.T.dot(L2_delta))
        w0 -= alpha * (L0.T.dot(L1_delta))

    print("Output After Training:")
    print(L2)