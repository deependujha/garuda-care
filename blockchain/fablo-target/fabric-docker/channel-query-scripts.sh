#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "hospital" ] && [ "$3" = "peer0" ]; then

    peerChannelListTls "cli.hospital.example.com" "peer0.hospital.example.com:7041" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "hospital" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.hospital.example.com" "peer1.hospital.example.com:7042" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "defence" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.defence.example.com" "peer0.defence.example.com:7061" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "insurance" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.insurance.example.com" "peer0.insurance.example.com:7081" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "dataauthority" ] && [ "$3" = "peer0" ]
  then

    peerChannelListTls "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "my-channel" ] && [ "$3" = "hospital" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "my-channel" "cli.hospital.example.com" "peer0.hospital.example.com:7041" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "my-channel" ] && [ "$4" = "hospital" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "my-channel" "cli.hospital.example.com" "$TARGET_FILE" "peer0.hospital.example.com:7041" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "my-channel" ] && [ "$4" = "hospital" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "my-channel" "cli.hospital.example.com" "${BLOCK_NAME}" "peer0.hospital.example.com:7041" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "my-channel" ] && [ "$3" = "hospital" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "my-channel" "cli.hospital.example.com" "peer1.hospital.example.com:7042" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "my-channel" ] && [ "$4" = "hospital" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "my-channel" "cli.hospital.example.com" "$TARGET_FILE" "peer1.hospital.example.com:7042" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "my-channel" ] && [ "$4" = "hospital" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "my-channel" "cli.hospital.example.com" "${BLOCK_NAME}" "peer1.hospital.example.com:7042" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "my-channel" ] && [ "$3" = "defence" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "my-channel" "cli.defence.example.com" "peer0.defence.example.com:7061" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "my-channel" ] && [ "$4" = "defence" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "my-channel" "cli.defence.example.com" "$TARGET_FILE" "peer0.defence.example.com:7061" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "my-channel" ] && [ "$4" = "defence" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "my-channel" "cli.defence.example.com" "${BLOCK_NAME}" "peer0.defence.example.com:7061" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "my-channel" ] && [ "$3" = "insurance" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "my-channel" "cli.insurance.example.com" "peer0.insurance.example.com:7081" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "my-channel" ] && [ "$4" = "insurance" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "my-channel" "cli.insurance.example.com" "$TARGET_FILE" "peer0.insurance.example.com:7081" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "my-channel" ] && [ "$4" = "insurance" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "my-channel" "cli.insurance.example.com" "${BLOCK_NAME}" "peer0.insurance.example.com:7081" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "my-channel" ] && [ "$3" = "dataauthority" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "my-channel" "cli.data-authority.example.com" "peer0.data-authority.example.com:7101" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "my-channel" ] && [ "$4" = "dataauthority" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "my-channel" "cli.data-authority.example.com" "$TARGET_FILE" "peer0.data-authority.example.com:7101" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "my-channel" ] && [ "$4" = "dataauthority" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "my-channel" "cli.data-authority.example.com" "${BLOCK_NAME}" "peer0.data-authority.example.com:7101" "crypto-orderer/tlsca.block-orderer.example.com-cert.pem" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list hospital peer0"
  echo -e "\t List channels on 'peer0' of 'hospital'".
  echo ""

  echo "fablo channel list hospital peer1"
  echo -e "\t List channels on 'peer1' of 'hospital'".
  echo ""

  echo "fablo channel list defence peer0"
  echo -e "\t List channels on 'peer0' of 'defence'".
  echo ""

  echo "fablo channel list insurance peer0"
  echo -e "\t List channels on 'peer0' of 'insurance'".
  echo ""

  echo "fablo channel list dataauthority peer0"
  echo -e "\t List channels on 'peer0' of 'dataAuthority'".
  echo ""

  echo "fablo channel getinfo my-channel hospital peer0"
  echo -e "\t Get channel info on 'peer0' of 'hospital'".
  echo ""
  echo "fablo channel fetch config my-channel hospital peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'hospital'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> my-channel hospital peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'hospital'".
  echo ""

  echo "fablo channel getinfo my-channel hospital peer1"
  echo -e "\t Get channel info on 'peer1' of 'hospital'".
  echo ""
  echo "fablo channel fetch config my-channel hospital peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'hospital'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> my-channel hospital peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'hospital'".
  echo ""

  echo "fablo channel getinfo my-channel defence peer0"
  echo -e "\t Get channel info on 'peer0' of 'defence'".
  echo ""
  echo "fablo channel fetch config my-channel defence peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'defence'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> my-channel defence peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'defence'".
  echo ""

  echo "fablo channel getinfo my-channel insurance peer0"
  echo -e "\t Get channel info on 'peer0' of 'insurance'".
  echo ""
  echo "fablo channel fetch config my-channel insurance peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'insurance'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> my-channel insurance peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'insurance'".
  echo ""

  echo "fablo channel getinfo my-channel dataauthority peer0"
  echo -e "\t Get channel info on 'peer0' of 'dataAuthority'".
  echo ""
  echo "fablo channel fetch config my-channel dataauthority peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'dataAuthority'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> my-channel dataauthority peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'dataAuthority'".
  echo ""

}
