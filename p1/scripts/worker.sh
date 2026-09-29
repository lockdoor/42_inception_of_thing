#! /bin/bash

SERVER_IP="192.168.56.110"
TIMEOUT=300
INTERVAL=5
ELAPSED=0

$SERVER_IP

# ติดตั้ง sshpass เพื่อให้ scp ด้วย password แบบไม่ต้องโต้ตอบ
apt-get update && apt-get install -y sshpass

while true; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Error: Timed out waiting for token from $SERVER_IP" >&2
        exit 1
    fi

    # พยายามดึง token ผ่าน scp โดยข้าม host key verification
    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        vagrant@$SERVER_IP:/home/vagrant/node-token /tmp/node-token #2>/dev/null

    if [ -f /tmp/node-token ]; then
        TOKEN=$(cat /tmp/node-token)
        if [ -n "$TOKEN" ]; then
            echo "Token retrieved successfully!"
            break
        fi
    fi

    echo "Server not ready yet... (${ELAPSED}s / ${TIMEOUT}s)"
    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
done

# echo "Token found! Proceeding with provisioning..."

# Install k3s for worker node with bind interface eth1 and IP 192.168.56.111
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=${TOKEN} \
    INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1" sh -s -

# Remove token file (not need anymore)
# rm /home/vagrant/confs/token
