# frozen_string_literal: true

require_relative "test_helper"

class VersionResolverTest < Minitest::Test
  COMMIT = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  TAG_OBJ = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

  def test_latest_version_picks_highest_release_by_semver
    client = FakeGhClient.new(
      "repos/actions/checkout/releases" => [
        { "tag_name" => "v4.0.0", "draft" => false, "prerelease" => false },
        { "tag_name" => "v3.1.0-node20", "draft" => false, "prerelease" => false },
      ],
      "repos/actions/checkout/git/ref/tags/v4.0.0" => {
        "object" => { "sha" => COMMIT, "type" => "commit" },
      }
    )

    result = VersionResolver.new(client).latest_version("actions/checkout")

    assert_equal "#{COMMIT} # v4.0.0", result
  end

  def test_latest_version_falls_back_to_tags
    client = FakeGhClient.new(
      "repos/owner/repo/releases" => [],
      "repos/owner/repo/tags" => [
        { "name" => "v2.0.0" },
        { "name" => "v1.0.0" },
      ],
      "repos/owner/repo/git/ref/tags/v2.0.0" => {
        "object" => { "sha" => COMMIT, "type" => "commit" },
      }
    )

    result = VersionResolver.new(client).latest_version("owner/repo")

    assert_equal "#{COMMIT} # v2.0.0", result
  end

  def test_latest_version_dereferences_annotated_tag
    client = FakeGhClient.new(
      "repos/owner/repo/releases" => [
        { "tag_name" => "v1.0.0", "draft" => false, "prerelease" => false },
      ],
      "repos/owner/repo/git/ref/tags/v1.0.0" => {
        "object" => { "sha" => TAG_OBJ, "type" => "tag" },
      },
      "repos/owner/repo/git/tags/#{TAG_OBJ}" => {
        "object" => { "sha" => COMMIT },
      }
    )

    result = VersionResolver.new(client).latest_version("owner/repo")

    assert_equal "#{COMMIT} # v1.0.0", result
  end

  def test_latest_version_caches_per_repo
    client = FakeGhClient.new(
      "repos/owner/repo/releases" => [
        { "tag_name" => "v1.0.0", "draft" => false, "prerelease" => false },
      ],
      "repos/owner/repo/git/ref/tags/v1.0.0" => {
        "object" => { "sha" => COMMIT, "type" => "commit" },
      }
    )
    resolver = VersionResolver.new(client)

    resolver.latest_version("owner/repo")
    calls_after_first = client.calls.size
    resolver.latest_version("owner/repo")

    assert_equal calls_after_first, client.calls.size
  end

  def test_hash_for_tag_resolves_major_version_to_latest_in_series
    client = FakeGhClient.new(
      "repos/owner/repo/tags" => [
        { "name" => "v1.2.3" },
        { "name" => "v1.10.0" },
        { "name" => "v2.0.0" },
      ],
      "repos/owner/repo/git/ref/tags/v1.10.0" => {
        "object" => { "sha" => COMMIT, "type" => "commit" },
      }
    )

    result = VersionResolver.new(client).hash_for_tag("owner/repo", "v1")

    assert_equal "#{COMMIT} # v1.10.0", result
  end

  def test_hash_for_tag_falls_back_to_commit_lookup
    client = FakeGhClient.new(
      "repos/owner/repo/git/ref/tags/v1.2.3" => nil,
      "repos/owner/repo/commits/v1.2.3" => { "sha" => COMMIT }
    )

    result = VersionResolver.new(client).hash_for_tag("owner/repo", "v1.2.3")

    assert_equal "#{COMMIT} # v1.2.3", result
  end
end
