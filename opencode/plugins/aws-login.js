/**
 * aws-login plugin
 *
 * On every "server.connected" event, checks whether the AWS token for the
 * configured profile is still valid by reading its cache file directly.
 * Runs the login command only when the token is missing or expired.
 *
 * Configuration (set in your shell profile):
 *
 *   # Which AWS CLI profile to check
 *   export OPENCODE_AWS_PROFILE="default"
 *
 *   # Login command to run when the token is expired
 *   export OPENCODE_AWS_LOGIN_CMD="aws sso login"
 *
 * How the cache file is located
 * ──────────────────────────────
 * Three authentication styles are supported, detected from ~/.aws/config:
 *
 *   1. Console credentials  (login_session = <arn>)
 *      Cache: ~/.aws/login/cache/<sha256-of-arn>.json
 *      Expiry: cache.accessToken.expiresAt
 *      Command: aws login [--profile <name>]
 *
 *   2. SSO token-provider   (sso_session = <name>)
 *      Cache: ~/.aws/sso/cache/<sha1-of-session-name>.json
 *      Expiry: cache.expiresAt
 *      Command: aws sso login [--profile <name>]
 *
 *   3. Legacy SSO           (sso_start_url = <url> on the profile itself)
 *      Cache: ~/.aws/sso/cache/<sha1-of-start-url>.json
 *      Expiry: cache.expiresAt
 *      Command: aws sso login [--profile <name>]
 */

import { createHash } from "crypto";
import { readFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Parse ~/.aws/config into a map of section-name → key/value pairs. */
function parseAwsConfig() {
  const configPath = join(homedir(), ".aws", "config");
  let raw;
  try {
    raw = readFileSync(configPath, "utf8");
  } catch {
    return {};
  }

  const sections = {};
  let current = null;

  for (const line of raw.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || trimmed.startsWith(";"))
      continue;

    const sectionMatch = trimmed.match(/^\[(.+?)\]$/);
    if (sectionMatch) {
      current = sectionMatch[1].trim();
      sections[current] = {};
      continue;
    }

    const kvMatch = trimmed.match(/^([^=]+?)\s*=\s*(.*)$/);
    if (kvMatch && current !== null) {
      sections[current][kvMatch[1].trim()] = kvMatch[2].trim();
    }
  }

  return sections;
}

/**
 * Resolve how to find the cache file for a given profile.
 *
 * Returns { cacheDir, filename, type } or null if no supported auth config
 * is found for the profile.
 */
function resolveCacheLocation(profileName, sections) {
  // Section header is "profile <name>" for non-default, "default" for default.
  const sectionKey =
    profileName === "default" ? "default" : `profile ${profileName}`;
  const profile = sections[sectionKey];

  if (!profile) return null;

  const home = homedir();

  // 1. Console credentials: aws login (login_session key)
  // Cache key = SHA-256 of the login_session ARN value.
  if (profile.login_session) {
    return {
      cacheDir: join(home, ".aws", "login", "cache"),
      filename: sha256(profile.login_session) + ".json",
      type: "login",
    };
  }

  // 2. Modern SSO token-provider: sso_session reference
  if (profile.sso_session) {
    return {
      cacheDir: join(home, ".aws", "sso", "cache"),
      filename: sha1(profile.sso_session) + ".json",
      type: "sso-session",
    };
  }

  // 3. Legacy SSO: sso_start_url on the profile directly
  if (profile.sso_start_url) {
    return {
      cacheDir: join(home, ".aws", "sso", "cache"),
      filename: sha1(profile.sso_start_url) + ".json",
      type: "sso-legacy",
    };
  }

  return null;
}

/** SHA-1 hex digest — used by AWS CLI for SSO cache filenames. */
function sha1(input) {
  return createHash("sha1").update(input).digest("hex");
}

/** SHA-256 hex digest — used by AWS CLI for aws-login cache filenames. */
function sha256(input) {
  return createHash("sha256").update(input).digest("hex");
}

/**
 * Read and parse a cache file given its directory and filename.
 * Returns the parsed JSON object, or null if not found / unreadable.
 */
function readCacheFile(cacheDir, filename) {
  try {
    return JSON.parse(readFileSync(join(cacheDir, filename), "utf8"));
  } catch {
    return null;
  }
}

/**
 * Extract the expiresAt string from a cache object.
 * - SSO caches (sso-session, sso-legacy): top-level expiresAt
 * - Console credentials cache (login): nested at accessToken.expiresAt
 */
function getExpiresAt(cache, type) {
  if (type === "login") {
    return cache?.accessToken?.expiresAt ?? null;
  }
  return cache?.expiresAt ?? null;
}

/**
 * Returns true when the token is present and has not yet expired.
 * Adds a 5-minute buffer so we refresh slightly before actual expiry.
 */
function isTokenValid(cache, type) {
  const raw = getExpiresAt(cache, type);
  if (!raw) return false;
  const expiresAt = new Date(raw);
  if (isNaN(expiresAt.getTime())) return false;
  const bufferMs = 5 * 60 * 1000;
  return Date.now() + bufferMs < expiresAt.getTime();
}

/**
 * Build the default login command for a profile based on the auth type.
 * Only used when OPENCODE_AWS_LOGIN_CMD is not set.
 */
function defaultLoginCmd(profileName, type) {
  const profileFlag =
    profileName === "default" ? "" : ` --profile ${profileName}`;
  if (type === "login") {
    return `aws login${profileFlag}`;
  }
  return `aws sso login${profileFlag}`;
}

// ---------------------------------------------------------------------------
// Plugin
// ---------------------------------------------------------------------------

export const AwsLoginPlugin = async ({ client, $ }) => {
  return {
      "server.connected": async () => {
      const profile = process.env.OPENCODE_AWS_PROFILE || "default";

      const log = async (level, message) =>
        client.app.log({
          body: { service: "aws-login", level, message },
        });

      // Locate the cache file for this profile ----------------------------
      const sections = parseAwsConfig();
      const location = resolveCacheLocation(profile, sections);

      if (!location) {
        await log(
          "info",
          `aws-login: no supported auth config found for profile "${profile}" in ~/.aws/config — skipping`,
        );
        return;
      }

      // Check token validity ----------------------------------------------
      const cache = readCacheFile(location.cacheDir, location.filename);
      if (isTokenValid(cache, location.type)) {
        const expiresAt = new Date(getExpiresAt(cache, location.type)).toISOString();
        await log(
          "info",
          `aws-login: token for profile "${profile}" (${location.type}) is valid until ${expiresAt} — skipping login`,
        );
        return;
      }

      // Token is missing or expired — run the login command ---------------
      const loginCmd =
        process.env.OPENCODE_AWS_LOGIN_CMD ||
        defaultLoginCmd(profile, location.type);

      const reason = cache ? "expired" : "not found";
      await log(
        "info",
        `aws-login: token for profile "${profile}" (${location.type}) is ${reason} — running: ${loginCmd}`,
      );

      try {
        await $`sh -c ${loginCmd}`;
        await log(
          "info",
          `aws-login: login succeeded for profile "${profile}"`,
        );
      } catch (err) {
        await log(
          "error",
          `aws-login: login failed for profile "${profile}": ${err?.message ?? err}`,
        );
      }
    },
  };
};
