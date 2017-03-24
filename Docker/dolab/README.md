# Instructions

1. You need ssh, jq and doctl (Digital Ocean client).
2. Setup your authentication with doctl.
3. Copy the user pubkey in name.pub
4. Run ./dolab.sh 5 1gb name. The script will create instances and put the user key in authorized_keys.
