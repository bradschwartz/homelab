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

### Public Access

Why run things if we can't show people?

[Fly][https://fly.io] has a generous free tier and is super easy to deploy - I
(ab)use it for my [protohackers](https://protohackers.com/) [solutions](https://github.com/bradschwartz/protohackers).
Let's use it here to act as a web proxy for the Pi by connecting everything over
the tailscale network. Mainly following the [tailscale docs](https://tailscale.com/kb/1132/flydotio/)
on this.

1. Generate a new Tailscale auth token (Reusable, Ephemeral)
1. `flyctl secrets set TAILSCALE_AUTHKEY="${TAILSCALE_AUTHKEY}"`
1. Build a [Dockerfile](./proxy/Dockerfile)!
   - Need to run with `--privileged` flag locally
1. `flyctl deploy --local-only`

### K3s - Single Node K8s Cluster

Mainly just following the https://docs.k3s.io/quick-start guide:

```bash
curl -sfL https://get.k3s.io | sh -
# result in some errors, the important bit:
# [INFO]  Failed to find memory cgroup, you may need to add "cgroup_memory=1 cgroup_enable=memory" to your linux cmdline (/boot/cmdline.txt on a Raspberry Pi)
# Restarted k3s after editing that file:
echo "console=serial0,115200 console=tty1 root=PARTUUID=48c544c0-02 rootfstype=ext4 fsck.repair=yes rootwait cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt
sudo reboot # to have changes take effect
sudo systemctl restart k3s.service
sudo chmod ugo+rwx /etc/rancher/k3s/k3s.yaml # can scp to local and change `server` to access remotely
```

You'll need to generate Docker auths for any registries. In my case, I needed
a GitHub PAT. The auth file is located at `/etc/rancher/k3s/registries.yaml`:

```yaml
configs:
  ghcr.io:
    auth:
      username: bradschwartz
      password: ${GH_PAT}
```

Make sure to restart k3s afterwards.

## Useful Commands

```bash
# copy SSH keys:
ssh-copy-id brad@raspberrypi

# Copy default rc files
cp /etc/skel/.bash_logout /etc/skel/.bashrc /etc/skel/.profile .

# Copy install scripts
scp -r ./install/ ./setup.sh brad@raspberrypi:~
```
