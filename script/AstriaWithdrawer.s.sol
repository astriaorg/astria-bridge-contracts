// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AstriaWithdrawer} from "../src/AstriaWithdrawer.sol";

contract AstriaWithdrawerScript is Script {
    function setUp() public {}

    function deploy() public {
        uint32 baseChainAssetPrecision = uint32(vm.envUint("BASE_CHAIN_ASSET_PRECISION"));
        string memory baseChainBridgeAddress = vm.envString("BASE_CHAIN_BRIDGE_ADDRESS");
        string memory baseChainAssetDenomination = vm.envString("BASE_CHAIN_ASSET_DENOMINATION");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 sequencerWithdrawalFee = vm.envUint("SEQUENCER_WITHDRAWAL_FEE");
        uint256 ibcWithdrawalFee = vm.envUint("IBC_WITHDRAWAL_FEE");
        address feeRecipient = vm.envAddress("FEE_RECIPIENT");
        vm.startBroadcast(deployerPrivateKey);
        new AstriaWithdrawer(
            baseChainAssetPrecision,
            baseChainBridgeAddress,
            baseChainAssetDenomination,
            sequencerWithdrawalFee,
            ibcWithdrawalFee,
            feeRecipient
        );
        vm.stopBroadcast();
    }

    function withdrawToSequencer() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaWithdrawer astriaWithdrawer = AstriaWithdrawer(contractAddress);

        string memory destinationChainAddress = vm.envString("SEQUENCER_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");

        // Read the withdrawal fee from the contract
        uint256 fee = astriaWithdrawer.SEQUENCER_WITHDRAWAL_FEE();
        astriaWithdrawer.withdrawToSequencer{value: amount + fee}(destinationChainAddress);

        vm.stopBroadcast();
    }

    function withdrawToIbcChain() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        AstriaWithdrawer astriaWithdrawer = AstriaWithdrawer(contractAddress);

        string memory destinationChainAddress = vm.envString("ORIGIN_DESTINATION_CHAIN_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");

        // Read the withdrawal fee from the contract
        uint256 fee = astriaWithdrawer.IBC_WITHDRAWAL_FEE();
        astriaWithdrawer.withdrawToIbcChain{value: amount + fee}(destinationChainAddress, "");

        vm.stopBroadcast();
    }
}
