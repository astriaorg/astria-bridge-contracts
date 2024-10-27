// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IAstriaWithdrawer} from "../src/IAstriaWithdrawer.sol";

contract AstriaWithdrawerManager is Script {
    function setUp() public {}

    function claimFees() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        IAstriaWithdrawer astriaWithdrawer = IAstriaWithdrawer(contractAddress);

        astriaWithdrawer.claimFees();

        vm.stopBroadcast();
    }

    function setSequencerWithdrawalFee() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        IAstriaWithdrawer astriaWithdrawer = IAstriaWithdrawer(contractAddress);

        uint256 newFee = vm.envUint("SEQUENCER_WITHDRAWAL_FEE");
        astriaWithdrawer.setSequencerWithdrawalFee(newFee);

        vm.stopBroadcast();
    }

    function setIbcWithdrawalFee() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        IAstriaWithdrawer astriaWithdrawer = IAstriaWithdrawer(contractAddress);

        uint256 newFee = vm.envUint("IBC_WITHDRAWAL_FEE");
        astriaWithdrawer.setIbcWithdrawalFee(newFee);

        vm.stopBroadcast();
    }

    function setFeeRecipient() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        IAstriaWithdrawer astriaWithdrawer = IAstriaWithdrawer(contractAddress);

        address newFeeRecipient = vm.envAddress("FEE_RECIPIENT");
        astriaWithdrawer.setFeeRecipient(newFeeRecipient);

        vm.stopBroadcast();
    }

    function transferOwnership() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = vm.envAddress("ASTRIA_WITHDRAWER");
        IAstriaWithdrawer astriaWithdrawer = IAstriaWithdrawer(contractAddress);

        address newContractOwner = vm.envAddress("CONTRACT_NEW_OWNER");
        astriaWithdrawer.transferOwnership(newContractOwner);

        vm.stopBroadcast();
    }
}
