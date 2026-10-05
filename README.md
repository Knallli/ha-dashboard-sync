# Dashboard Sync (Home Assistant add-on)

Mirrors a Git branch into a folder under `/config` every N seconds, using a read-only SSH deploy key.
Meant for static frontends under `/config/www/`. The git dir is kept outside the work tree.

Options: `repository` (SSH URL), `branch`, `interval` (s), `target`, `git_dir`, `deploy_key`.
No credentials are stored in this repository.
