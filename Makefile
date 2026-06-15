.PHONY: all setup setup-pi ansible flux status clean

all: setup ansible flux

setup:
	@echo "==> Ensuring prerequisites are installed..."
	@scripts/setup-mac.sh

setup-pi:
	@echo "==> Verifying Pi connectivity and updating apt cache..."
	@PI_HOST="$${PI_HOST:-raspberrypi}"; \
	PI_USER="$${PI_USER:-brad}"; \
	ssh -o StrictHostKeyChecking=accept-new "$$PI_USER@$$PI_HOST" "sudo apt-get update -qq && echo 'OK'"

ansible:
	@echo "==> Running Ansible playbook to bootstrap Pi and install k3s..."
	@ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/inventory.yml ansible/site.yml

flux:
	@echo "==> Bootstrapping Flux into the cluster..."
	@if [ -z "$${GITHUB_TOKEN}" ] || [ -z "$${GITHUB_USER}" ]; then \
		echo "ERROR: GITHUB_TOKEN and GITHUB_USER must be set"; \
		echo "  export GITHUB_TOKEN=your_personal_access_token"; \
		echo "  export GITHUB_USER=your_github_username"; \
		exit 1; \
	fi
	@KUBECONFIG=$${HOME}/.kube/raspberrypi-config \
		flux bootstrap github \
		--owner=$${GITHUB_USER} \
		--repository=homelab \
		--path=clusters/raspberrypi \
		--personal \
		--private=false

status:
	@echo "==> Pi status..."
	@ssh brad@raspberrypi "uname -a && echo '---' && k3s --version && echo '---' && k3s kubectl get nodes"

clean:
	@echo "==> Removing kubeconfig..."
	@rm -f $${HOME}/.kube/raspberrypi-config
	@echo "Done"
