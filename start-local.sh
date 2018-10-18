#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

docker-compose -f docker-compose-local.yaml up -d

# Wait for Hyperledger Fabric to start
# Incase of errors when running later commands, issue export FABRIC_START_TIMEOUT=<larger number>
export FABRIC_START_TIMEOUT=10
#echo ${FABRIC_START_TIMEOUT}
sleep ${FABRIC_START_TIMEOUT}

# Create the channel
docker exec -e "CORE_PEER_LOCALMSPID=Hospital1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@hospital1.switch2logic.co.za/msp" peer0.hospital1.switch2logic.co.za peer channel create -o orderer.switch2logic.co.za:7050 -c comunitychannel -f /etc/hyperledger/configtx/comunity_channel.tx

# Join peer0.hospital1.switch2logic.co.za to the channel.
docker exec -e "CORE_PEER_LOCALMSPID=Hospital1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@hospital1.switch2logic.co.za/msp" peer0.hospital1.switch2logic.co.za peer channel join -b comunitychannel.block
