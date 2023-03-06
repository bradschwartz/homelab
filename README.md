# My Homelab!

Currently running Raspbian 64-bit on a Raspberry Pi 4.

The plan is to manage it using bare bones bash scripts.
No Docker is allowed, only systemd files that I've written or at least templated by hand.

## The Setup

Documenting here _how_ and _what_ everything that is installed on the pi.

### Remote Access

For local-network usage, ssh was easy. I followed the official docs
for configuring it as [headless](https://www.raspberrypi.com/documentation/computers/configuration.html#setting-up-a-headless-raspberry-pi)
on the SD card after I flashed it, and the
[passwordless SSH](https://www.raspberrypi.com/documentation/computers/remote-access.html#passwordless-ssh-access)
guide for adding my SSH keys.

I also want to be able to access it when I'm not on my home network. Since I don't
pay for a static ISP, instead of allowing external SSH I decided to use `[Tailscale](https://tailscale.com)`.
Once the VPN is enabled, you can use the MagicDNS name or the IP to ssh from anywhere!

To install tailscale locally on Mac, use brew. You'll need to approve security
settings on first open to allow VPN, and it will guide you through the rest of setup.

```bash
brew install --cask tailscale
```

There was a manual step after installation to allow the raspberypi to be added
to my tailscale account.

```bash
scp -r ./scripts brad@raspberrypi:~
ssh brad@raspberrypi 'sudo bash ./scripts/tailscale.sh'
ssh brad@raspberrypi 'sudo tailscale up'
```

### Monitoring

Because why run services if we aren't sure it's working and how much resources
it's taking up?

Using Grafana by just following their Linux quick start guide:
https://grafana.com/docs/grafana-cloud/data-configuration/get-started-integration/
Private dashboard with the default integration dashboard: https://bradschwartz.grafana.net/d/fa49a4706d07a042595b664c87fb33ea/node-exporter-nodes?orgId=1&refresh=30s

## Useful Commands

```bash
# copy SSH keys:
ssh-copy-id brad@raspberrypi

# Copy default rc files
cp /etc/skel/.bash_logout /etc/skel/.bashrc /etc/skel/.profile .

# Copy install scripts
scp -r ./install/ ./setup.sh brad@raspberrypi:~
```
