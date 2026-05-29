# frozen_string_literal: true

require_relative "test_helper"

class GitHubActionsUpdaterTest < Minitest::Test
  OLD_SHA = "1111111111111111111111111111111111111111"
  NEW = "2222222222222222222222222222222222222222 # v4"

  def with_workflow(content)
    Dir.mktmpdir do |dir|
      file = File.join(dir, "ci.yml")
      File.write(file, content)
      yield file
    end
  end

  def build(file, **opts)
    GitHubActionsUpdater.new(
      { workflow_files: [file] }.merge(opts),
      client: FakeGhClient.new,
      resolver: @resolver,
      out: StringIO.new
    )
  end

  def test_update_writes_new_hash_to_file
    @resolver = FakeResolver.new(latest: { "actions/checkout" => NEW })

    with_workflow("- uses: actions/checkout@#{OLD_SHA} # v3\n") do |file|
      build(file).run
      assert_equal "- uses: actions/checkout@#{NEW}\n", File.read(file)
    end
  end

  def test_dry_run_does_not_modify_file
    @resolver = FakeResolver.new(latest: { "actions/checkout" => NEW })
    original = "- uses: actions/checkout@#{OLD_SHA} # v3\n"

    with_workflow(original) do |file|
      build(file, dry_run: true).run
      assert_equal original, File.read(file)
    end
  end

  def test_migrate_replaces_tag_with_resolved_hash
    @resolver = FakeResolver.new(hashes: { ["actions/checkout", "v4"] => NEW })

    with_workflow("- uses: actions/checkout@v4\n") do |file|
      build(file, migrate: true).run
      assert_equal "- uses: actions/checkout@#{NEW}\n", File.read(file)
    end
  end

  def test_exits_when_gh_unavailable
    @resolver = FakeResolver.new

    with_workflow("- uses: actions/checkout@v4\n") do |file|
      updater = GitHubActionsUpdater.new(
        { workflow_files: [file] },
        client: unavailable_client,
        resolver: @resolver,
        out: StringIO.new
      )
      assert_raises(SystemExit) { updater.run }
    end
  end

  def unavailable_client
    client = FakeGhClient.new
    client.define_singleton_method(:available?) { false }
    client
  end
end
