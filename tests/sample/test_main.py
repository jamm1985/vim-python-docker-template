"""Tests for sample.main module."""

import pytest

from sample.main import get_sample, main, run


def test_get_sample_returns_requested_number_of_values() -> None:
    """get_sample returns exactly k values in [0, 1]."""
    sample = get_sample(5)
    assert len(sample) == 5
    assert all(0.0 <= value <= 1.0 for value in sample)


def test_get_sample_is_deterministic_for_same_k() -> None:
    """Template behavior is deterministic because seed is fixed."""
    assert get_sample(3) == pytest.approx(
        [0.7739560485559633, 0.4388784397520523, 0.8585979199113825],
    )


def test_run_uses_get_sample(monkeypatch: pytest.MonkeyPatch) -> None:
    """Run delegates to get_sample and returns its result unchanged."""
    expected = [0.1, 0.2]

    def fake_get_sample(k: int) -> list[float]:
        assert k == 2
        return expected

    monkeypatch.setattr("sample.main.get_sample", fake_get_sample)
    assert run(2) == expected


def test_main_writes_sample_and_returns_zero(
    monkeypatch: pytest.MonkeyPatch,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Main writes the sample to stdout and exits with status code 0."""
    expected = [0.1, 0.2]

    monkeypatch.setattr("sample.main.run", lambda: expected)

    assert main() == 0
    captured = capsys.readouterr()
    assert captured.out.strip() == str(expected)
