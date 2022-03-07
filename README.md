# tarsnap-cron-docker
Automated Tarsnap backups through a Docker container, cross-built for amd64, arm64, and armhf.

## Usage

- Clone this repository.

- Run `deploy.sh` to build and push the image to your own Docker Hub. It accepts one argument, which is the image tag to push as. The pushed image will run on amd64, arm64, and the armhf architectures. Docker buildx support is required, meaning you must have Docker Engine version 20.10 or higher installed.

- Edit `docker-compose.yml` to:

    - Change the `TZ` environment variable to your local timezone.

    - Change the image to your own image from Docker Hub (you don't have to, but you should not run random Docker images from the Internet that have access to your backups and private key!).

    - Mount in a crontab at `/var/run/crontab` (see the crontab file for a sample). The default crontab will take a backup at 2AM in the given timezone.

    - Replace `/backup` with a directory on the host system Tarsnap should be backing up.

    - Replace `/cache` with a directory on the host system Tarsnap can keep its cache data in.

    - If you're not using Docker Swarm, add a volume, mount in your write-only Tarsnap key to `/var/run/secrets/tarsnap`.

- If you're using docker-compose, run `docker-compose up`.

- If you're using Docker Swarm, create write-only Tarsnap keys and create a secret named `tarsnap` that contains this key. Afterwards, run `docker stack deploy --compose-file docker-compose.yml tarsnap`.
