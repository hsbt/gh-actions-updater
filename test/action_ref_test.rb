# frozen_string_literal: true

require_relative "test_helper"

class ActionRefTest < Minitest::Test
  def test_repo_returns_owner_repo_as_is
    assert_equal "actions/checkout", ActionRef.repo("actions/checkout")
  end

  def test_repo_strips_subaction_path
    assert_equal "github/codeql-action", ActionRef.repo("github/codeql-action/autobuild")
  end

  def test_sha_recognizes_40_hex_chars
    assert ActionRef.sha?("a" * 40)
    assert ActionRef.sha?("0123456789abcdef0123456789abcdef01234567")
  end

  def test_sha_rejects_tags_and_short_strings
    refute ActionRef.sha?("v4")
    refute ActionRef.sha?("v4.1.0")
    refute ActionRef.sha?("a" * 39)
    refute ActionRef.sha?(nil)
  end
end
