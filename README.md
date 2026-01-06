# Transmission Exporter for Prometheus

This is a fork of https://github.com/metalmatze/transmission-exporter, See [README.md Original Here](./README.orig.md).

Prometheus exporter for [Transmission](https://transmissionbt.com/) metrics, written in Go.

### Configuration

ENV Variable | Description
|----------|-----|
| WEB_PATH | Path for metrics, default: `/metrics` |
| WEB_ADDR | Address for this exporter to run, default: `:19091` |
| TRANSMISSION_ADDR | Transmission address to connect with, default: `http://localhost:9091` |
| TRANSMISSION_USERNAME | Transmission username, no default |
| TRANSMISSION_PASSWORD | Transmission password, no default |

### Docker

    docker pull ghcr.io/imbo-fr/transmission-exporter
    docker run -d -p 19091:19091 ghcr.io/imbo-fr/transmission-exporter

### Docker Compose

Example `docker-compose.yml` with Transmission also running in docker.

    transmission:
      image: linuxserver/transmission
      restart: always
      ports:
        - "127.0.0.1:9091:9091"
        - "51413:51413"
        - "51413:51413/udp"
    transmission-exporter:
      image: ghcr.io/imbo-fr/transmission-exporter
      restart: always
      links:
        - transmission
      ports:
        - "127.0.0.1:19091:19091"
      environment:
        TRANSMISSION_ADDR: http://transmission:9091

### Development

For development we encourage you to use `make install` instead, it's faster.

### Fork modifications

Now simply copy the `.env.example` to `.env`, like `cp .env.example .env` and set your preferences.
Now you're good to go.

I made these changes because the latency of fetching metrics was too slow. My changes improved that latency from ~2 minutes to ~2 seconds (I have several thousand Linux ISOs in Transmission).

Summary of changes made in this fork:

* Instead of grabbing every torrent, it uses the RPC query `"ids": "recently-active"` to only grab recently active torrents. It still grabs every torrent on the first run, then does recently active only from then on. A map is used to maintain torrents current status, the key is the torrent hash. This way the metrics stay available, they just don't change while the torrent is dormant. This is faster since Transmission doesn't serialize and send unchanged information.
* Fields for files, peers, and trackers are all removed. **These metrics are no longer exported,** and they are no longer requested as fields in RPC calls. So, **this fork has less functionality**, but it's faster. Those metrics aren't interesting anyway. :)
* New exported metric `uploaded_ever_bytes`. Technically you could compute this by multiplying the ratio by the size, but I would rather just export the actual integer. Transmission will tell you this if you ask, so `uploadedEver` was added to the list of fields requested from its RPC.
* `lastScrapeTimedOut` issue fixed by simply changing datatype in JSON struct from bool to int
* Also added a bunch more exported metrics: `downloaded_ever_bytes`, `peers_connected`, `peers_getting_from_us`, `peers_sending_to_us`


TODO (not implemented yet)
* As per https://github.com/transmission/transmission/blob/main/docs/rpc-spec.md, when using this `recently-active` thing, there is an additional reply called `removed` which is a list of torrents that were removed. I currently ignore this, because I virtually never remove torrents. But just saying, this exporter will not remove torrents, because it doesn't parse this reply. I guess you could restart the exporter after removing torrents?

### Original authors of the Transmission package  
Tobias Blom (https://github.com/tubbebubbe/transmission)  
Long Nguyen (https://github.com/longnguyen11288/go-transmission)
