# Contributing

## Maintainer Commit Identity

For Blackscale maintainer work, configure each new checkout explicitly rather
than inheriting an unrelated machine-wide Git identity:

```sh
git config --local user.name Blackscale
git config --local user.email hello@blackscale.tech
git config --local core.hooksPath .githooks
sh scripts/check-attribution.sh identity
```

The hooks and CI reject the known unrelated inherited identity in authors,
committers and co-author trailers. Required attribution CI protects the default
branch. Genuine outside contributors retain their own identity.
Never retarget published release tags to repair display attribution; those tags
anchor registry provenance.
