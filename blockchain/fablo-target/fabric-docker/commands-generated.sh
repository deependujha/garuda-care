#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for blockOrderer" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-blockorderer.yaml" "peerOrganizations/block-orderer.example.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for hospital" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-hospital.yaml" "peerOrganizations/hospital.example.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for defence" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-defence.yaml" "peerOrganizations/defence.example.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for insurance" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-insurance.yaml" "peerOrganizations/insurance.example.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for dataAuthority" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-dataauthority.yaml" "peerOrganizations/data-authority.example.com" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group group1" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "Group1Genesis"

  # Create directory for chaincode packages to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'my-channel'" "U1F913"
  createChannelTx "my-channel" "$FABLO_NETWORK_ROOT/fabric-config" "MyChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'my-channel' on hospital/peer0" "U1F63B"
  docker exec -i cli.hospital.example.com bash -c "source scripts/channel_fns.sh; createChannelAndJoinTls 'my-channel' 'hospitalMSP' 'peer0.hospital.example.com:7041' 'crypto/users/Admin@hospital.example.com/msp' 'crypto/users/Admin@hospital.example.com/tls' 'crypto-orderer/tlsca.block-orderer.example.com-cert.pem' 'orderer0.group1.block-orderer.example.com:7030';"

  printItalics "Joining 'my-channel' on  hospital/peer1" "U1F638"
  docker exec -i cli.hospital.example.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'my-channel' 'hospitalMSP' 'peer1.hospital.example.com:7042' 'crypto/users/Admin@hospital.example.com/msp' 'crypto/users/Admin@hospital.example.com/tls' 'crypto-orderer/tlsca.block-orderer.example.com-cert.pem' 'orderer0.group1.block-orderer.example.com:7030';"
  printItalics "Joining 'my-channel' on  defence/peer0" "U1F638"
  docker exec -i cli.defence.example.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'my-channel' 'defenceMSP' 'peer0.defence.example.com:7061' 'crypto/users/Admin@defence.example.com/msp' 'crypto/users/Admin@defence.example.com/tls' 'crypto-orderer/tlsca.block-orderer.example.com-cert.pem' 'orderer0.group1.block-orderer.example.com:7030';"
  printItalics "Joining 'my-channel' on  insurance/peer0" "U1F638"
  docker exec -i cli.insurance.example.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'my-channel' 'insuranceMSP' 'peer0.insurance.example.com:7081' 'crypto/users/Admin@insurance.example.com/msp' 'crypto/users/Admin@insurance.example.com/tls' 'crypto-orderer/tlsca.block-orderer.example.com-cert.pem' 'orderer0.group1.block-orderer.example.com:7030';"
  printItalics "Joining 'my-channel' on  dataAuthority/peer0" "U1F638"
  docker exec -i cli.data-authority.example.com bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'my-channel' 'dataAuthorityMSP' 'peer0.data-authority.example.com:7101' 'crypto/users/Admin@data-authority.example.com/msp' 'crypto/users/Admin@data-authority.example.com/tls' 'crypto-orderer/tlsca.block-orderer.example.com-cert.pem' 'orderer0.group1.block-orderer.example.com:7030';"
}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node")" ]; then
    local version="0.0.1"
    printHeadline "Packaging chaincode 'chaincode1'" "U1F60E"
    chaincodeBuild "chaincode1" "node" "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node" "16"
    chaincodePackage "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "node" printHeadline "Installing 'chaincode1' for hospital" "U1F60E"
    chaincodeInstall "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
    chaincodeInstall "cli.hospital.example.com" "peer1.hospital.example.com:7042" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
    chaincodeApprove "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
    printHeadline "Installing 'chaincode1' for defence" "U1F60E"
    chaincodeInstall "cli.defence.example.com" "peer0.defence.example.com:7061" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
    chaincodeApprove "cli.defence.example.com" "peer0.defence.example.com:7061" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
    printHeadline "Installing 'chaincode1' for insurance" "U1F60E"
    chaincodeInstall "cli.insurance.example.com" "peer0.insurance.example.com:7081" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
    chaincodeApprove "cli.insurance.example.com" "peer0.insurance.example.com:7081" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
    printHeadline "Installing 'chaincode1' for dataAuthority" "U1F60E"
    chaincodeInstall "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
    chaincodeApprove "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
    printItalics "Committing chaincode 'chaincode1' on channel 'my-channel' as 'hospital'" "U1F618"
    chaincodeCommit "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "peer0.hospital.example.com:7041,peer0.defence.example.com:7061,peer0.insurance.example.com:7081,peer0.data-authority.example.com:7101" "crypto-peer/peer0.hospital.example.com/tls/ca.crt,crypto-peer/peer0.defence.example.com/tls/ca.crt,crypto-peer/peer0.insurance.example.com/tls/ca.crt,crypto-peer/peer0.data-authority.example.com/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'chaincode1' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "chaincode1" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node")" ]; then
      printHeadline "Packaging chaincode 'chaincode1'" "U1F60E"
      chaincodeBuild "chaincode1" "node" "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node" "16"
      chaincodePackage "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "node" printHeadline "Installing 'chaincode1' for hospital" "U1F60E"
      chaincodeInstall "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeInstall "cli.hospital.example.com" "peer1.hospital.example.com:7042" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for defence" "U1F60E"
      chaincodeInstall "cli.defence.example.com" "peer0.defence.example.com:7061" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.defence.example.com" "peer0.defence.example.com:7061" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for insurance" "U1F60E"
      chaincodeInstall "cli.insurance.example.com" "peer0.insurance.example.com:7081" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.insurance.example.com" "peer0.insurance.example.com:7081" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for dataAuthority" "U1F60E"
      chaincodeInstall "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printItalics "Committing chaincode 'chaincode1' on channel 'my-channel' as 'hospital'" "U1F618"
      chaincodeCommit "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "peer0.hospital.example.com:7041,peer0.defence.example.com:7061,peer0.insurance.example.com:7081,peer0.data-authority.example.com:7101" "crypto-peer/peer0.hospital.example.com/tls/ca.crt,crypto-peer/peer0.defence.example.com/tls/ca.crt,crypto-peer/peer0.insurance.example.com/tls/ca.crt,crypto-peer/peer0.data-authority.example.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'chaincode1' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "chaincode1" ]; then
    local version="0.0.1"
    printHeadline "Approving 'chaincode1' for hospital (dev mode)" "U1F60E"
    chaincodeApprove "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "0.0.1" "orderer0.group1.block-orderer.example.com:7030" "" "false" "" ""
    printHeadline "Approving 'chaincode1' for defence (dev mode)" "U1F60E"
    chaincodeApprove "cli.defence.example.com" "peer0.defence.example.com:7061" "my-channel" "chaincode1" "0.0.1" "orderer0.group1.block-orderer.example.com:7030" "" "false" "" ""
    printHeadline "Approving 'chaincode1' for insurance (dev mode)" "U1F60E"
    chaincodeApprove "cli.insurance.example.com" "peer0.insurance.example.com:7081" "my-channel" "chaincode1" "0.0.1" "orderer0.group1.block-orderer.example.com:7030" "" "false" "" ""
    printHeadline "Approving 'chaincode1' for dataAuthority (dev mode)" "U1F60E"
    chaincodeApprove "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "my-channel" "chaincode1" "0.0.1" "orderer0.group1.block-orderer.example.com:7030" "" "false" "" ""
    printItalics "Committing chaincode 'chaincode1' on channel 'my-channel' as 'hospital' (dev mode)" "U1F618"
    chaincodeCommit "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "0.0.1" "orderer0.group1.block-orderer.example.com:7030" "" "false" "" "peer0.hospital.example.com:7041,peer0.defence.example.com:7061,peer0.insurance.example.com:7081,peer0.data-authority.example.com:7101" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "chaincode1" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node")" ]; then
      printHeadline "Packaging chaincode 'chaincode1'" "U1F60E"
      chaincodeBuild "chaincode1" "node" "$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node" "16"
      chaincodePackage "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "node" printHeadline "Installing 'chaincode1' for hospital" "U1F60E"
      chaincodeInstall "cli.hospital.example.com" "peer0.hospital.example.com:7041" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeInstall "cli.hospital.example.com" "peer1.hospital.example.com:7042" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for defence" "U1F60E"
      chaincodeInstall "cli.defence.example.com" "peer0.defence.example.com:7061" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.defence.example.com" "peer0.defence.example.com:7061" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for insurance" "U1F60E"
      chaincodeInstall "cli.insurance.example.com" "peer0.insurance.example.com:7081" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.insurance.example.com" "peer0.insurance.example.com:7081" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printHeadline "Installing 'chaincode1' for dataAuthority" "U1F60E"
      chaincodeInstall "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "chaincode1" "$version" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
      chaincodeApprove "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" ""
      printItalics "Committing chaincode 'chaincode1' on channel 'my-channel' as 'hospital'" "U1F618"
      chaincodeCommit "cli.hospital.example.com" "peer0.hospital.example.com:7041" "my-channel" "chaincode1" "$version" "orderer0.group1.block-orderer.example.com:7030" "" "false" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "peer0.hospital.example.com:7041,peer0.defence.example.com:7061,peer0.insurance.example.com:7081,peer0.data-authority.example.com:7101" "crypto-peer/peer0.hospital.example.com/tls/ca.crt,crypto-peer/peer0.defence.example.com/tls/ca.crt,crypto-peer/peer0.insurance.example.com/tls/ca.crt,crypto-peer/peer0.data-authority.example.com/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'chaincode1' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/chaincode-kv-node'"
    fi
  fi
}

notifyOrgsAboutChannels() {
  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "my-channel" "hospitalMSP" "MyChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "my-channel" "defenceMSP" "MyChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "my-channel" "insuranceMSP" "MyChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"
  createNewChannelUpdateTx "my-channel" "dataAuthorityMSP" "MyChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannelTls "my-channel" "hospitalMSP" "cli.hospital.example.com" "peer0.hospital.example.com" "orderer0.group1.block-orderer.example.com:7030" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
  notifyOrgAboutNewChannelTls "my-channel" "defenceMSP" "cli.defence.example.com" "peer0.defence.example.com" "orderer0.group1.block-orderer.example.com:7030" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
  notifyOrgAboutNewChannelTls "my-channel" "insuranceMSP" "cli.insurance.example.com" "peer0.insurance.example.com" "orderer0.group1.block-orderer.example.com:7030" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"
  notifyOrgAboutNewChannelTls "my-channel" "dataAuthorityMSP" "cli.data-authority.example.com" "peer0.data-authority.example.com" "orderer0.group1.block-orderer.example.com:7030" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "my-channel" "hospitalMSP" "cli.hospital.example.com"
  deleteNewChannelUpdateTx "my-channel" "defenceMSP" "cli.defence.example.com"
  deleteNewChannelUpdateTx "my-channel" "insuranceMSP" "cli.insurance.example.com"
  deleteNewChannelUpdateTx "my-channel" "dataAuthorityMSP" "cli.data-authority.example.com"
}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose down)

  printf "\nRemoving chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.hospital.example.com-chaincode1" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.hospital.example.com-chaincode1*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.hospital.example.com-chaincode1" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.hospital.example.com-chaincode1*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.defence.example.com-chaincode1" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.defence.example.com-chaincode1*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.insurance.example.com-chaincode1" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.insurance.example.com-chaincode1*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer0.data-authority.example.com-chaincode1" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.data-authority.example.com-chaincode1*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "\nRemoving generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
