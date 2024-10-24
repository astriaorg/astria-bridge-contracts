// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AstriaBridgeableUSDC} from "../src/AstriaBridgeableUSDC.sol";

contract AstriaBridgeableUSDCScript is Script {
    function deploy() public {
        address bridgeAddress = vm.envAddress("EVM_BRIDGE_ADDRESS");
        uint32 baseChainAssetPrecision = uint32(vm.envUint("BASE_CHAIN_ASSET_PRECISION"));
        string memory baseChainBridgeAddress = vm.envString("BASE_CHAIN_BRIDGE_ADDRESS");
        string memory baseChainAssetDenomination = vm.envString("BASE_CHAIN_ASSET_DENOMINATION");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new AstriaBridgeableUSDC(
            bridgeAddress,
            baseChainAssetPrecision,
            baseChainBridgeAddress,
            baseChainAssetDenomination
        );
        vm.stopBroadcast();
    }
}
