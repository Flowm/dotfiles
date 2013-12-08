#!/usr/bin/env bash

sudo cp /home/flow/.myconf/.ssh/a_keys/authorized_keys_flow /home/flow/.ssh/authorized_keys
sudo chown flow:flow /home/flow/.ssh/authorized_keys

sudo cp /home/flow/.myconf/.ssh/a_keys/authorized_keys_tun /home/tun/.ssh/authorized_keys
sudo chown tun:tun /home/flow/.ssh/authorized_keys
