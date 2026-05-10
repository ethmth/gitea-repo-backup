# gitea-repo-backup



## Obtaining Token ("API Key")

1. Log into your Gitea instance as an admin user
2. Click your avatar (top-right) → Settings
3. In the left sidebar, go to Applications
4. Under "Generate New Token", give it a name (e.g. backup-script)
5. Select these scopes: **repository (read)** and **issue (read)** — or just enable all read scopes to keep it simple
6. Click Generate Token and copy it immediately — Gitea only shows it once