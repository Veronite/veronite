#!/bin/bash

rlwrap veronite-wallet-cli --wallet-file wallet_m --password "" --testnet --trusted-daemon --daemon-address localhost:15248  --log-file wallet_miner.log stop_mining

