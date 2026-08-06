/// Shared display-name ordering for local SAF and cloud listings.
///
/// Purpose: Keep queue ingest order aligned across sources (case-insensitive
/// [DISPLAY_NAME] / Drive `name`).
/// Usage Context: [GoogleDriveCloudLibrarySource.list], cloud walk, tests.
int compareDisplayNames(String a, String b) =>
    a.toLowerCase().compareTo(b.toLowerCase());
