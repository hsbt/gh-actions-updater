# frozen_string_literal: true

require_relative "test_helper"

class SemverTest < Minitest::Test
  # Asserts that `higher` sorts above `lower`.
  def assert_higher(higher, lower)
    assert_equal 1, Semver.sort_key(higher) <=> Semver.sort_key(lower),
                 "expected #{higher} to sort above #{lower}"
  end

  def test_orders_by_major_minor_patch
    assert_higher "v4.0.0", "v3.9.9"
    assert_higher "v3.2.0", "v3.1.5"
    assert_higher "v3.1.5", "v3.1.4"
  end

  def test_prerelease_ranks_below_stable_peer
    assert_higher "v3.1.0", "v3.1.0-node20"
  end

  def test_newer_major_beats_backport_prerelease
    # A backport like v3.1.0-node20 published after v4.0.0 must not win.
    assert_higher "v4.0.0", "v3.1.0-node20"
  end

  def test_tag_without_v_prefix
    assert_higher "4.0.0", "3.0.0"
  end

  def test_unparsable_tag_sorts_lowest
    assert_equal [-1, -1, -1, -1], Semver.sort_key("latest")
    assert_higher "v1.0.0", "latest"
  end
end
