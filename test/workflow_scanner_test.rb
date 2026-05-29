# frozen_string_literal: true

require_relative "test_helper"

class WorkflowScannerTest < Minitest::Test
  SHA = "1234567890abcdef1234567890abcdef12345678"

  def test_hash_based_collects_sha_pinned_actions
    content = <<~YAML
      jobs:
        build:
          steps:
            - uses: actions/checkout@#{SHA} # v4
            - uses: actions/setup-ruby@v1
    YAML

    result = WorkflowScanner.new.hash_based(content)

    assert_equal({ "actions/checkout" => [SHA] }, result)
  end

  def test_tag_based_collects_tag_pinned_actions
    content = <<~YAML
      jobs:
        build:
          steps:
            - uses: actions/checkout@#{SHA} # v4
            - uses: actions/setup-ruby@v1
    YAML

    result = WorkflowScanner.new.tag_based(content)

    assert_equal({ "actions/setup-ruby" => ["v1"] }, result)
  end

  def test_target_actions_filter
    content = <<~YAML
      - uses: actions/checkout@v4
      - uses: actions/cache@v3
    YAML

    result = WorkflowScanner.new(target_actions: ["actions/cache"]).tag_based(content)

    assert_equal({ "actions/cache" => ["v3"] }, result)
  end

  def test_deduplicates_repeated_versions
    content = <<~YAML
      - uses: actions/checkout@v4
      - uses: actions/checkout@v4
    YAML

    result = WorkflowScanner.new.tag_based(content)

    assert_equal({ "actions/checkout" => ["v4"] }, result)
  end
end
