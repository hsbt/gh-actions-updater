# frozen_string_literal: true

require_relative "test_helper"

class WorkflowRewriterTest < Minitest::Test
  OLD_SHA = "1111111111111111111111111111111111111111"
  NEW = "2222222222222222222222222222222222222222 # v4"

  def test_update_replaces_hash_and_version_comment
    content = "      - uses: actions/checkout@#{OLD_SHA} # v3\n"

    new_content, modified, processed = WorkflowRewriter.new.rewrite(
      content, { "actions/checkout" => [OLD_SHA] }, action_key: :action_only
    ) { |_action, _version| NEW }

    assert modified
    assert_equal "      - uses: actions/checkout@#{NEW}\n", new_content
    assert_equal({ "actions/checkout" => 1 }, processed)
  end

  def test_update_preserves_trailing_directive_comment
    content = "      - uses: actions/checkout@#{OLD_SHA} # v3 # zizmor: ignore[unpinned-uses]\n"

    new_content, = WorkflowRewriter.new.rewrite(
      content, { "actions/checkout" => [OLD_SHA] }, action_key: :action_only
    ) { |_action, _version| NEW }

    assert_equal(
      "      - uses: actions/checkout@#{NEW} # zizmor: ignore[unpinned-uses]\n",
      new_content
    )
  end

  def test_migrate_replaces_tag_with_hash
    content = "      - uses: actions/checkout@v4\n"

    new_content, modified, = WorkflowRewriter.new.rewrite(
      content, { "actions/checkout" => ["v4"] }, action_key: :action_with_version
    ) { |_action, _version| NEW }

    assert modified
    assert_equal "      - uses: actions/checkout@#{NEW}\n", new_content
  end

  def test_no_replacement_when_block_returns_nil
    content = "      - uses: actions/checkout@#{OLD_SHA} # v3\n"

    new_content, modified, processed = WorkflowRewriter.new.rewrite(
      content, { "actions/checkout" => [OLD_SHA] }, action_key: :action_only
    ) { |_action, _version| nil }

    refute modified
    assert_equal content, new_content
    assert_empty processed
  end
end
