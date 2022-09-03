#!/bin/sh

iptables -t nat -A POSTROUTING -s 172.16.238.0/24 -j MASQUERADE


