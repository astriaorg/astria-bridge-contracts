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
        uint256 withdrawalFee = vm.envUint("WITHDRAWAL_FEE");
        address feeRecipient = vm.envAddress("FEE_RECIPIENT");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new AstriaBridgeableERC20(
            bridgeAddress,
            baseChainAssetPrecision,
            baseChainBridgeAddress,
            baseChainAssetDenomination,
            tokenName,
            tokenSymbol,
            withdrawalFee,
            feeRecipient
        );
        vm.stopBroadcast();
    }

    function mint() public {
        // the private key to the `EVM_BRIDGE_ADDRESS` the contract was deployed with
        uint256 evmBridgePrivateKey = vm.envUint("EVM_BRIDGE_ADDRESS_PRIVATE_KEY");
        vm.startBroadcast(evmBridgePrivateKey);

        AstriaBridgeableERC20 astriaBridgeableERC20 = AstriaBridgeableERC20(vm.envAddress("ASTRIA_BRIDGEABLE_ERC20_ADDRESS"));
        address to = vm.envAddress("MINT_TO");
        uint256 amount = vm.envUint("MINT_AMOUNT");
        astriaBridgeableERC20.mint(to, amount);

        vm.stopBroadcast();

        uint256 balance = astriaBridgeableERC20.balanceOf(to);
        console.logUint(balance);
    }

    function getBalance() public view {
        AstriaBridgeableERC20 astriaBridgeableERC20 = AstriaBridgeableERC20(vm.envAddress("ASTRIA_BRIDGEABLE_ERC20_ADDRESS"));
        address account = vm.envAddress("MINT_TO");
        uint256 balance = astriaBridgeableERC20.balanceOf(account);
        console.logUint(balance);
    }

    function withdrawToSequencer() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AstriaBridgeableERC20 astriaBridgeableERC20 = AstriaBridgeableERC20(vm.envAddress("ASTRIA_BRIDGEABLE_ERC20_ADDRESS"));
        string memory destinationChainAddress = vm.envString("SEQUENCER_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");

        // Read the withdrawal fee from the contract
        uint256 fee = astriaBridgeableERC20.WITHDRAWAL_FEE();
        astriaBridgeableERC20.withdrawToSequencer{value: fee}(amount, destinationChainAddress);

        vm.stopBroadcast();
    }

    function withdrawToIbcChain() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AstriaBridgeableERC20 astriaBridgeableERC20 = AstriaBridgeableERC20(vm.envAddress("ASTRIA_BRIDGEABLE_ERC20_ADDRESS"));
        string memory destinationChainAddress = vm.envString("ORIGIN_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");

        // Read the withdrawal fee from the contract
        uint256 fee = astriaBridgeableERC20.WITHDRAWAL_FEE();
        astriaBridgeableERC20.withdrawToIbcChain{value: fee}(amount, destinationChainAddress, "");

        vm.stopBroadcast();
    }
}
