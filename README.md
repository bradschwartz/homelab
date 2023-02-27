# My Homelab!

Currently running Raspbian 64-bit on a Raspberry Pi 4.

The plan is to manage it using bare bones bash scripts.
No Docker is allowed, only systemd files that I've written or at least templated by hand.

## Useful Commands

```bash
# copy SSH keys:
ssh-copy-id brad@raspberrypi

# Copy default rc files
cp /etc/skel/.bash_logout /etc/skel/.bashrc /etc/skel/.profile .

# Copy install scripts
scp -r ./install/ ./setup.sh brad@raspberrypi:~
```

