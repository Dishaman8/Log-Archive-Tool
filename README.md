# Log Archive Tool
# Project URL: https://roadmap.sh/projects/log-archive-tool
Creates a compressed, timestamped archive of a log directory and records each
archive operation.

## Usage

```bash
chmod +x log-archive.sh
./log-archive.sh <log-directory>
```

For example:

```bash
./log-archive.sh /var/log
```

The archive is named `logs_archive_YYYYMMDD_HHMMSS.tar.gz` and is stored in a
sibling directory named `<log-directory>_archives`. The same directory contains
`archive.log`, with the date, time, source directory, and archive path.

Set `ARCHIVE_DIR` to use another destination:

```bash
ARCHIVE_DIR=/srv/log-archives ./log-archive.sh /var/log
```
