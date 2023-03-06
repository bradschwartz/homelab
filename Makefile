USER := brad
HOSTNAME := raspberrypi

.PHONY: ssh
ssh:
	ssh $(USER)@$(HOSTNAME)

.PHONY: upload
upload:
	scp -r scripts/ $(USER)@$(HOSTNAME):~

.PHONY: tailscale
tailscale: upload
	ssh $(USER)@$(HOSTNAME) sudo bash ./scripts/tailscale.sh
