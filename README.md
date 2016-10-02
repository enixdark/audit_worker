## Audit Worker

This project used to fetch data from cloud, trial , billing and openstack api and push into persistence db

### Setup
- Setup persistence database to use for project (use mongodb)
- Config env in  config/config.exs , config/prod.exs and config/dev.exs
- To install lib use:
  + `mix deps.get`
- Then, create file exec via command:
  + `mix escript.build`
- Then, 1 file audit'll generate, use:
  + `./audit -a true` to fetch all data from billing (to fetch 5000 data, consume about 1-3 minutes)
  + `./audit -a false` to fetch new data from billing
- after test , Update and move file crontab in scripts/audit-cron to /etc/cron.d


### Setup

Environments:

- MAX_CONECTION: max concurency connection to request to billing
- DELAY: time delay request to avoid timeout from server when request to billing
- TIMEOUT: timeout when hangup request to uri
- AUDIT_USERNAME: admin's username of billing
- AUDIT_PASSWORD: admin's password of billing
- AUDIT_TENANTNAME: admin's audit tenantname of billing

- CLOUD_HOST: mongo host of cloud
- CLOUD_PORT: mongo port of cloud
- CLOUD_USERNAME: mongo username of cloud
- CLOUD_PASSWORD: mongo password of cloud
- CLOUD_DATABASE: mongo database of cloud
- CLOUD_COLLECTION: mongo collection of cloud

- TRIAL_HOST: mongo host of trial cloud server
- TRIAL_PORT: mongo host of trial cloud server
- TRIAL_USERNAME: mongo host of trial cloud server
- TRIAL_PASSWORD: mongo host of trial cloud server
- TRIAL_DATABASE: mongo host of trial cloud server
- TRIAL_COLLECTION: mongo host of trial cloud server

- AUDIT_HOST: mongo host of trial cloud server
- AUDIT_PORT: mongo host of trial cloud server
- AUDIT_USER: mongo host of trial cloud server
- AUDIT_PASSWORD: mongo host of trial cloud server
- AUDIT_DATABASE: mongo host of trial cloud server
- AUDIT_COLLECTION: mongo host of trial cloud server

- OPENSTACK_URI: uri of openstack' database to get data
- TOKEN_URI: billing's uri to get access token
- BILLING_URI: billing's uri to get user's information


Before run
- Setup time scheduler for crontab in scripts/crontab or Dockfile file
use dockerfile:
- `docker build -t audit .`
- docker run -d -e audit
- setup env in env file and install docker-compose and run via command `docker-compose up`


### Test
- setup env for test in config/test.exs
- `MIX_ENV=test mix espec --cover`

### Note:
- in Dockerfile, there's a command to fetch all data from billing when start docker in the first time,you can disable it if don't need.
