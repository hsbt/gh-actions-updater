# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "tmpdir"

# The executable has no .rb extension, so load it explicitly. The CLI entry
# point is guarded by `$PROGRAM_NAME == __FILE__`, so loading only defines the
# classes without running anything.
load File.expand_path("../gh-actions-updater", __dir__)

# Stands in for GhClient: returns canned API responses keyed by endpoint.
class FakeGhClient
  attr_reader :calls

  def initialize(responses = {})
    @responses = responses
    @calls = []
  end

  def available?
    true
  end

  def run(args)
    @calls << args
    nil
  end

  def api(endpoint, _params = {})
    @calls << endpoint
    @responses[endpoint]
  end
end

# Stands in for VersionResolver with pre-baked answers.
class FakeResolver
  def initialize(latest: {}, hashes: {})
    @latest = latest
    @hashes = hashes
  end

  def latest_version(repo)
    @latest[repo]
  end

  def hash_for_tag(repo, tag)
    @hashes[[repo, tag]]
  end
end
