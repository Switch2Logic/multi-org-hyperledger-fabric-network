#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=comunitychannel

# remove previous crypto material and config transactions
rm -fr channel-artifacts/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile SingleOrdererHospitalGenesis -outputBlock ./channel-artifacts/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile Comunitychannel -outputCreateChannelTx ./channel-artifacts/comunity_channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

#------------------------------------------------------------------------------------------
# Comunity_Channel generation
#------------------------------------------------------------------------------------------

# generate anchor peer transaction
configtxgen -profile Comunitychannel -outputAnchorPeersUpdate ./channel-artifacts/hospital1MSP_anchors.tx -channelID $CHANNEL_NAME -asOrg Hospital1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Comunitychannel -outputAnchorPeersUpdate ./channel-artifacts/hospital2MSP_anchors.tx -channelID $CHANNEL_NAME -asOrg Hospital2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Comunitychannel -outputAnchorPeersUpdate ./channel-artifacts/hospital3MSP_anchors.tx -channelID $CHANNEL_NAME -asOrg Hospital3MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

#------------------------------------------------------------------------------------------
# Hospital1_2Channel generation
#------------------------------------------------------------------------------------------
# generate channel configuration transaction
configtxgen -profile Hospital2channel -outputCreateChannelTx ./channel-artifacts/hospital1_2_channel.tx -channelID hospital2channel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Hospital2channel -outputAnchorPeersUpdate ./channel-artifacts/hospital1_2MSP_anchors.tx -channelID hospital2channel -asOrg Hospital1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Hospital2channel -outputAnchorPeersUpdate ./channel-artifacts/hospital2_1MSP_anchors.tx -channelID hospital2channel -asOrg Hospital2MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

#------------------------------------------------------------------------------------------
# Hospital1_3_Channel generation
#------------------------------------------------------------------------------------------
# generate channel configuration transaction
configtxgen -profile Hospital3channel -outputCreateChannelTx ./channel-artifacts/hospital1_3_channel.tx -channelID hospital3channel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Hospital3channel -outputAnchorPeersUpdate ./channel-artifacts/hospital1_3MSP_anchors.tx -channelID hospital3channel -asOrg Hospital1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile Hospital3channel -outputAnchorPeersUpdate ./channel-artifacts/hospital3_1MSP_anchors.tx -channelID hospital3channel -asOrg Hospital3MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Hospital1MSP..."
  exit 1
fi

