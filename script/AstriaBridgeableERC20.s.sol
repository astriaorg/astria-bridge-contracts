// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AstriaBridgeableERC20} from "../src/AstriaBridgeableERC20.sol";

contract AstriaBridgeableERC20Script is Script {
    function deploy() public {
        address bridgeAddress = vm.envAddress("EVM_BRIDGE_ADDRESS");
        uint32 baseChainAssetPrecision = uint32(vm.envUint("BASE_CHAIN_ASSET_PRECISION"));
        string memory baseChainBridgeAddress = vm.envString("BASE_CHAIN_BRIDGE_ADDRESS");
        string memory baseChainAssetDenomination = vm.envString("BASE_CHAIN_ASSET_DENOMINATION");
        string memory tokenName = vm.envString("TOKEN_NAME");
        string memory tokenSymbol = vm.envString("TOKEN_SYMBOL");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
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

    function mint() public {
        // the `EVM_BRIDGE_ADDRESS` the contract was deployed with
        address evmBridgeAddress = address(0);
        vm.prank(evmBridgeAddress);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaBridgeableERC20 astriaWithdrawer = AstriaBridgeableERC20(contractAddress);

        address to = vm.envAddress("MINT_TO");
        uint256 amount = vm.envUint("MINT_AMOUNT");
        astriaWithdrawer.mint(to, amount);

        vm.stopPrank(); 
    }

    function withdrawToSequencer() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaBridgeableERC20 astriaWithdrawer = AstriaBridgeableERC20(contractAddress);

        string memory destinationChainAddress = vm.envString("SEQUENCER_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");
        astriaWithdrawer.withdrawToSequencer(amount, destinationChainAddress);

        vm.stopBroadcast();
    }

    function withdrawToIbcChain() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaBridgeableERC20 astriaWithdrawer = AstriaBridgeableERC20(contractAddress);

        string memory destinationChainAddress = vm.envString("ORIGIN_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");
        astriaWithdrawer.withdrawToIbcChain(amount, destinationChainAddress, "");

        vm.stopBroadcast();
    }
}
