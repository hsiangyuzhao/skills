# Good and Bad Tests

Examples use pytest and NumPy; the same shapes apply to any framework.

## Tautological vs independent oracle

```python
# BAD: expected value recomputed the way the code computes it
def test_dice():
    pred = np.array([[1, 1], [0, 0]])
    gt = np.array([[1, 0], [0, 0]])
    expected = 2 * (pred & gt).sum() / (pred.sum() + gt.sum())
    assert dice(pred, gt) == expected


# GOOD: hand-worked literal, small enough to check on paper
def test_dice_partial_overlap():
    pred = np.array([[1, 1], [0, 0]])
    gt = np.array([[1, 0], [0, 0]])
    # overlap 1, sizes 2 and 1 -> 2 * 1 / 3
    assert dice(pred, gt) == pytest.approx(2 / 3)


# GOOD: edge case where conventions differ, pinned explicitly
def test_dice_both_empty_is_one():
    empty = np.zeros((4, 4), dtype=bool)
    assert dice(empty, empty) == 1.0
```

## Reference implementation

```python
def test_auroc_matches_sklearn():
    rng = np.random.default_rng(0)
    y = rng.integers(0, 2, 200)
    score = rng.random(200)
    # atol: both are exact rank statistics; only float summation differs
    assert our_auroc(y, score) == pytest.approx(roc_auc_score(y, score), abs=1e-12)
```

## Invariants

```python
@pytest.mark.parametrize("level", [0, 1, 2])
def test_level_to_base_round_trip(level):
    xy = np.array([[0.0, 0.0], [123.5, 77.25], [1023.0, 511.0]])
    back = base_to_level(level_to_base(xy, level, downsample=4), level, downsample=4)
    # atol: half a pixel at level 0 is the precision the format stores
    np.testing.assert_allclose(back, xy, atol=0.5)


def test_no_subject_in_two_splits():
    meta = synthetic_metadata(n_subjects=50, samples_per_subject=3, seed=0)
    train, val, test = make_splits(meta, seed=0)
    ids = [set(s.subject_id) for s in (train, val, test)]
    assert ids[0].isdisjoint(ids[1])
    assert ids[0].isdisjoint(ids[2])
    assert ids[1].isdisjoint(ids[2])
```

## Implementation-coupled vs behavioural

```python
# BAD: asserts on an internal call, breaks on a harmless refactor
def test_loader_calls_resize(mocker):
    spy = mocker.spy(transforms, "_resize_impl")
    load_sample("x.png", size=256)
    spy.assert_called_once()


# GOOD: asserts on what callers rely on
def test_loader_output_shape_and_range():
    img = load_sample(synthetic_png(h=300, w=500), size=256)
    assert img.shape == (3, 256, 256)
    assert 0.0 <= img.min() and img.max() <= 1.0
```

## Weakened to pass

```python
# BAD: tolerance widened until green, no reason given
np.testing.assert_allclose(out, ref, atol=0.1)

# GOOD: tolerance tied to a stated cause
# bf16 forward pass: ~3 significant digits
np.testing.assert_allclose(out, ref, rtol=1e-2)
```

## Heavy weights

```python
# GOOD: same interface, tiny random model, runs on CPU in milliseconds
@pytest.fixture
def tiny_segmenter():
    return build_segmenter(encoder="tiny", pretrained=False, num_classes=3).eval()
```
