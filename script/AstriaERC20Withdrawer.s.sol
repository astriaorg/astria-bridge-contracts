// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AstriaBridgeableERC20} from "../src/AstriaBridgeableERC20.sol";

contract AstriaERC20WithdrawerScript is Script {
    function deploy() public {
        address bridgeAddress = vm.envAddress("BRIDGE_ADDRESS");
        uint32 baseChainAssetPrecision = uint32(vm.envUint("BASE_CHAIN_ASSET_PRECISION"));
        string memory baseChainBridgeAddress = vm.envString("BASE_CHAIN_BRIDGE_ADDRESS");
        string memory baseChainAssetDenomination = vm.envString("BASE_CHAIN_ASSET_DENOMINATION");
        string memory tokenName = vm.envString("TOKEN_NAME");
        string memory tokenSymbol = vm.envString("TOKEN_SYMBOL");

        vm.startBroadcast();
        new AstriaBridgeableERC20(
            bridgeAddress,
            baseChainAssetPrecision,
            baseChainBridgeAddress,
            baseChainAssetDenomination,
            tokenName,
            tokenSymbol
        );
        vm.stopBroadcast();

    }
    function withdrawToSequencer() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaBridgeableERC20 astriaWithdrawer = AstriaBridgeableERC20(contractAddress);

        string memory destinationChainAddress = vm.envString("SEQUENCER_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");
        astriaWithdrawer.withdrawToSequencer{value: amount}(destinationChainAddress);

        vm.stopBroadcast();
    }

    function withdrawToIbcChain() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaBridgeableERC20 astriaWithdrawer = AstriaBridgeableERC20(contractAddress);

        string memory destinationChainAddress = vm.envString("ORIGIN_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");
        astriaWithdrawer.withdrawToIbcChain{value: amount}(destinationChainAddress, "");

        vm.stopBroadcast();
    }
}