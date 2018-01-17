# SHIELD BOSH Backup / Restore Add-on

This BOSH release provides add-on tools for augmenting SHIELD
Agents with Pivotal's [BBR toolchain][bbr] for integrating with
BOSH deployments.

## Versions

The following versions are currently available:

 - **1.0.0** via `shield-addon-bbr-1.0`
 - **1.1.4** via `shield-addon-bbr-1.1.4`

Need a version we don't (yet) support?  Open a [Github Issue][bug]
asking that we package it up.  Please identify the full version
and a link to the canonical download page.

## Using this BOSH Release

**Note:** This BOSH release is not intended to stand on its own.
It exists to augment the `shield-agent` job of the [SHIELD BOSH
Release][1], and only in cases where the bbr utilities are
missing.

To colocate this BOSH release with your shield-agent instance
group, just add a new job to the group:

```yaml
instance_groups:
  - name: whatever
    jobs:
      # ...
      - name:    shield-addon-bbr-1.1.4
        release: shield-addon-bbr
```

That's really all there is to it.

[bug]: https://github.com/shieldproject/shield-addon-bbr-boshrelease/issues
[1]:   https://github.com/starkandwayne/shield-boshrelease
