# Online cover fetch (candidate)

**Status:** Not implemented. Candidate later feature — documented so embedded
covers can ship first without redesigning the art cache.

## Overview

Optionally fill missing album art by searching **MusicBrainz** and downloading
from the **Cover Art Archive (CAA)** when a track is about to play and still
has no on-device cover. Reuses the same `artwork/<trackId>.jpg` +
`artworkCacheRef` path as embedded extract — no parallel store.

## Why later (not v1 covers)

- Embedded tags cover most well-tagged libraries with **zero** new network or
  privacy surface.
- Matching quality (wrong release / compilation / sparse tags) dominates effort
  more than the HTTP call.
- TinyTunes is local-first; silent play-time lookups would surprise users after
  the existing privacy story (local library + optional Drive only).

## Proposed scope (lightweight)

Trigger only when **all** of the following hold:

1. A local file is ready to play (local path, or cloud download already finished).
2. `artworkCacheRef` is null (no on-device cover yet).
3. User has enabled an explicit Settings toggle (default **off**), e.g.
   “Fetch missing covers online”.

Then: search MusicBrainz → fetch CAA front image → write the same capped JPEG
used for embedded art → set `artworkCacheRef`. Failures stay quiet (no
placeholder UI).

### Out of scope for this candidate

- Batch / ingest / queue-scroll fetching
- Deduplicating one image across many tracks by album MBID
- Replacing embedded art with online art (embedded always wins when present)
- Counting online art toward the cloud GB budget

## Privacy requirements (non-negotiable if built)

| Requirement | Detail |
| --- | --- |
| Opt-in | Settings toggle, **default off** |
| Disclosure | Privacy policy (EN + DE) names MusicBrainz / Cover Art Archive and what is sent (artist / album / title; IP visible to those services) |
| In-app copy | Short Settings/About explanation of the outbound request |
| No silent path | Never run when the toggle is off |

Play-path lookups identify listening metadata to a third party; treat this like
another explicit cloud choice, not a background nicety.

## Effort ballpark (historical estimate)

| Slice | Rough cost |
| --- | --- |
| MVP (opt-in, play-current only, best search hit, shared art file) | ~2–4 days |
| Ship-quality (matching confidence, rate limits, privacy copy, tests) | ~1–2 weeks |

API/CAA download is the easy part; **correct album identity** is the hard part.

## Architecture fit

Depends on the embedded-cover design ([album cover decisions plan](../../.cursor/plans/album_cover_decisions_205f9e9d.plan.md)):

- Same art file lifecycle and cleanup hooks as embedded
- Natural extension of play-path enrichment after a readable local file exists
  (today used for cloud tag fill; local can share the “about to play + null art”
  gate)
- Prefer a small `CoverArtFetcher` (or similar) interface behind the toggle so
  MusicBrainz stays swappable

## Related

- Embedded covers (v1): queue trailing thumb + `MediaItem.artUri` — see player
  docs once implemented
- [Cloud library](cloud-library.md) — existing opt-in network path (Drive)
- [Privacy policy](../legal/privacy-policy.md) — must be updated before enabling
  any online fetch in a release

---
*Last updated: 2026-08-06*
