
def select_uncertain_samples(predictions, threshold=0.6):
    return [i for i, p in enumerate(predictions) if max(p) < threshold]
