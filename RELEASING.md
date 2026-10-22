# Releasing an OpenSSH update

## 1. Prepare

- Update the OpenSSH URL, mirror, version, and SHA-256 in
  [the formula](Formula/libsk-libfido2.rb).
- Remove the old `bottle do` block. Reset `revision` for a new upstream version;
  increment it for packaging changes to the same version.
- Keep dependency declarations and configure paths consistent.
- Bump [the cask version](Casks/libsk-libfido2-install.rb) when users need to
  rerun the installer.
- Verify downloaded source and installer files with `shasum -a 256`.

The formula and cask use a dedicated **`installer-v<version>` tag**,
independent of OpenSSH releases. Keep it unchanged when the script is unchanged.
For a script update, publish a new immutable installer tag before PR builds start,
then update the versioned filename, references, and checksums together.

## 2. Build through a PR

Open a PR targeting **`MichaelRoosz/homebrew-ssh:main`** with the formula change
in its diff. Check `git remote -v`: `origin` may point to a fork.

Wait for **brew test-bot** in [Actions](https://github.com/MichaelRoosz/homebrew-ssh/actions).
Every configured runner must build the formula without skips and upload a
`bottles_<runner>` artifact containing its bottle archive and JSON metadata.
Check dependency availability and successful standalone dylib linking.

Only PR events build bottles in [tests.yml](.github/workflows/tests.yml).
If the update already reached `main`, use a follow-up PR with a justified formula
change, such as a packaging revision bump. A documentation-only PR will not rebuild it.

## 3. Publish

In the public repository, select **Actions → brew pr-pull → Run workflow**:

1. Select `main`.
2. Enter the PR number in `pull_request`.
3. Enter the full reviewed PR head SHA in `head_sha`.
4. Run and wait for success, before build artifacts expire.

**Let this workflow integrate the PR; do not merge it first.**
[publish.yml](.github/workflows/publish.yml) uploads bottles to GHCR and pushes
the generated `bottle do` block to `main`.

Check [Packages](https://github.com/MichaelRoosz?tab=packages&repo_name=homebrew-ssh):
the new formula version/revision must be present, public, and match the bottle
metadata on `main`. Keep old versions available. For upload permission errors,
check the package's **Manage Actions access** for this repository.

## 4. Verify the installer download

Download the cask's resolved URL and verify its SHA-256 against the cask checksum.
The dedicated installer tag must already be published; neither a matching
cask-version tag nor a GitHub Release is required for downloading the script.
Never move an existing installer tag.

## 5. Test the upgrade

On a test Mac using the public tap:

```bash
brew update
brew upgrade --formula michaelroosz/ssh/libsk-libfido2
```

Confirm Homebrew pours a bottle on a supported target. Then refresh the system
copy using the appropriate installation route:

| Route | Command |
| --- | --- |
| Installed cask | `brew upgrade --cask michaelroosz/ssh/libsk-libfido2-install` |
| Manual installer | `sudo "$(brew --prefix)/bin/install-libsk-libfido2" "$(brew --prefix)"` |

Use `brew reinstall --cask` with the same cask name if it is already current.
The installer copies the dylib outside the Cellar, so upgrading the formula alone
leaves the previous system copy in place. It also reloads the SSH agent.

```bash
cmp "$(brew --prefix)/opt/libsk-libfido2/libexec/libsk-libfido2.dylib" \
  /usr/local/lib/libsk-libfido2.dylib
otool -L /usr/local/lib/libsk-libfido2.dylib
launchctl print "gui/$(id -u)/com.mroosz.ssh_env_vars"
```

Verify the files match and linkage is correct. Log out and back in, then test
FIDO2 authentication with an existing key: PIN/askpass, touch, and login.
`ssh -V` identifies the client, not this provider library.

References: [Homebrew tap publishing](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap),
[bottles](https://docs.brew.sh/Bottles),
[GitHub workflow triggering](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).
