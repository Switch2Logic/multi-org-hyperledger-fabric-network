Hyperledger Fabric Network with 3 orginazations 3 channels. 

# First Hyperledger Fabric Network Setup
I am a masters student learning Hyperledger Fabric. The purpose of this project was to learn how to set up a simple single organization network on Hyperledger Fabric from the ground up. This network includes the following 4 peers, 1 Orderer, 1 CA and a fabric-client. 

# Chanlenges
1. Understanding what the crypto-config.yaml and configtx.yaml files actualy do. 
2. Seting up docker-composer.yaml files. I did not understand what I was doing. I got confused with example code provided Hyperledger Fabric. This mainly due to the fact that I thought the docker-compose.yaml was appart of Hyperledger Fabric. 
3. Getting the peers to comunicate was an issue even on the local machine.
4. Then networking the peers accross multiple physical nodes. This was the most difficult thing to grasp for me.
5. Getting peers to join the channel.

# Solutions
I solved most of these issues by learning docker from a book called Master Docker.  Understanding docker lets you actually get on with learning Hyperledger Fabric itself. 

# Steps
Step1: Create Docker Swarm<br />
`$ docker swarm init --advertise-addr 192.168.1.139` <br />

Step2: Join Swarm<br />
`$ docker swarm join --token TOKEN 192.168.1.139:2377`<br />

Step3: Verify hosts on Swarm<br />
`$ docker node ls`

Step4: Create a overlay network on first computer<br />
`$ docker network create -d overlay --attachable hospital-network`<br />
note: The name of the network I used is "rebnet" if you use a different name please make sure to propagate this change through the docker-compose.yaml files you use. I recommend doing a find and replace on the term "rebnet". 

docker run -itd --name dummyContainer --net hospital-network alpine /bin/sh

Step5: Connect second computer to overlay network<br />
`$ docker run -itd --restart always --name dummyContainer --net "network-name-go's-here" alpine /bin/sh`<br />
note: This is a work around to get the second computer to connect to the ovelay network.

Step6: Copy the project folder to each computer.  <br />
note: The channel-artifacts and the crypto-config folders are the most important. Then each computer should contain a docker-compose.yaml file with Hyperledger fabric components in for that computer. Also, the start scripts also come in handy. For example docker-compose-host1.yaml and start-host.sh on the one computer. 

Step7: Start the network <br />
`$ start-host1.sh` <br />
`$ docker-compose -f docker-compose-locl.yaml up -d` <br />
note: Please make sure the .sh file is excutable in the terminal. 

Step8: Create and join a channel and join peer 0 via fabric-client. <br />
`$ docker exec -it cli bash`<br />
CORE_PEER_LOCALMSPID=Hospital1MSP
`$ export CORE_PEER_ADDRESS=peer0.hospital1.switch2logic.co.za:7051`<br />
`$ peer channel create -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/comunity_channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem` <br />
peer channel create -o orderer.switch2logic.co.za:7050 -c hospital2channel -f ./chan/hospital1_2_channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem`
peer channel create -o orderer.switch2logic.co.za:7050 -c hospital3channel -f ./hospital1_3_channel.tx

note: channel can only be created ones and will give an error if you recreate it just move on.

Step9: Join each peer to the channel <br />
`$ docker exec -it cli bash`<br />
`$ export CORE_PEER_ADDRESS=peer0.hospital1.switch2logic.co.za:7051`<br />
`$ export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/hospital1.switch2logic.co.za/users/Admin@hospital1.switch2logic.co.za/msp`<br />
`$ peer channel fetch 0 comunitychannel.block --channelID comunitychannel --orderer orderer.switch2logic.co.za:7050`<br />
`$ peer channel join -b comunitychannel.block`<br />
peer channel fetch 0 hospital2channel.block --channelID hospital2channel --orderer orderer.switch2logic.co.za:7050
`$ peer channel join -b /chan/hospital2channel.block`<br />
peer channel fetch 0 hospital3channel.block --channelID hospital2channel --orderer orderer.switch2logic.co.za:7050
`$ peer channel join -b hospital3channel.block`<br />

peer channel update -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/hospital1MSP_anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

peer channel update -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/hospital2MSP_anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

peer channel update -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/hospital3MSP_anchors.tx --cafile tlsca.switch2logic.co.za-cert.pem

peer channel update -o orderer.switch2logic.co.za:7050 -c hospital2channel -f ./channel-artifacts/hospital1_2MSP_anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem


peer channel update -o orderer.switch2logic.co.za:7050 -c hospital2channel -f ./channel-artifacts/hospital2_1MSP_anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem


peer channel update -o orderer.switch2logic.co.za:7050 -c hospital3channel -f hospital1_3MSP_anchors.tx --cafile tlsca.switch2logic.co.za-cert.pem

peer channel update -o orderer.switch2logic.co.za:7050 -c hospital3channel -f hospital3_1MSP_anchors.tx --cafile tlsca.switch2logic.co.za-cert.pem


Step10: Check docker logs <br />
`$ docker logs peer1.hospital1.switch2logic.co.za:7051 -f` <br />
Note: There should be no errors. 

# Lessons Learned
If you want to get started with Hyperledger Fabric you need a firm understanding of docker.



export CORE_PEER_ADDRESS=peer0.hospital1.switch2logic.co.za:7051

peer channel update -o orderer.switch2logic.co.za:7050 -c comunitychannel -f hospital1MSP_anchors.tx --cafile  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

# Install Hyperleder Fabric chaincode via fabric-client
`$ peer chaincode install -n fabcar -v 1.0 -p github.com/hyperledger/fabric/peer/chaincode/` <br />

# List installed chaincode
`$ peer chaincode list --installed` <br />

# Instaniante chaincode
`$ peer chaincode instantiate -o orderer.switch2logic.co.za:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem -C hospital2channel -n fabcar -v 1.0 -c '{"Args":["init"]}'` <br />

peer chaincode instantiate -o orderer.switch2logic.co.za:7050 -n fabcar -v 1.0 -c '{"Args":["init"]}' -C hospital2channel

# Query hyperledger-fabric chaincode
`$ peer chaincode query -C comunitychannel -n fabcar -c '{"Args":["queryAllCars"]}'` <br />
`$ peer chaincode invoke -o orderer.switch2logic.co.za:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem -C hospital2channel -n fabcar  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/hospital2.switch2logic.co.za/peers/peer0.hospital2.switch2logic.co.za/tls/ca.crt -c '{"Args":["createCar","CAR11","VW","Polo","Black","Channel1_2Car"]}'` <br />

peer chaincode invoke -o orderer.switch2logic.co.za:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem -C comunitychannel -n fabcar  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/peerOrganizations/hospital2.switch2logic.co.za/peers/peer0.hospital2.switch2logic.co.za/tls/ca.crt -c '{"Args":["initLedger",""]}'



Steps
1. peer channel create -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/comunity_channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

2. peer channel join -b comunitychannel.block

3. peer channel update -o orderer.switch2logic.co.za:7050 -c comunitychannel -f ./channel-artifacts/hospital1MSP_anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

4. peer chaincode install -n fabcar -v 1.0 -p github.com/chaincode/

5. peer chaincode instantiate -o orderer.switch2logic.co.za:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem -C comutitychannel -n fabcar -v 1.0 -c '{"Args":["init"]}' "OR ('Hospital1MSP.peer','Hospital2MSP.peer')"

peer chaincode upgrade -n patient -p /opt/gopath/src/github.com/hyperledger/fabric/peer/chaincode/ -v 2 -c '{"Args":["init"]}' -C hospital2channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem

peer chaincode upgrade -o orderer.switch2logic.co.za:7050 -C hospital2channel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem  -n patient -p /opt/gopath/src/github.com/chaincode/ -v 2 -c '{"Args":["init"]}' 

peer chaincode upgrade -o orderer.switch2logic.co.za:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto-config/ordererOrganizations/switch2logic.co.za/orderers/orderer.switch2logic.co.za/msp/tlscacerts/tlsca.switch2logic.co.za-cert.pem -C hospital2channel -n patient -v 1.1 -c '{"Args":["init"]}' -P "OR ('Hospital1MSP.peer','Hospital2MSP.peer')"