// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {IAstriaWithdrawer} from "./IAstriaWithdrawer.sol";

// This contract facilitates withdrawals of the native asset from the rollup to the base chain.
// 
// Funds can be withdrawn to either the sequencer or the origin chain via IBC.
contract AstriaWithdrawer is IAstriaWithdrawer {
    // the divisor used to convert the rollup asset amount to the base chain denomination
    //
    // set to 10 ** (18 - BASE_CHAIN_ASSET_PRECISION) on contract creation
    uint256 private immutable DIVISOR;

    constructor(uint32 _baseChainAssetPrecision, string memory _baseChainBridgeAddress, string memory _baseChainAssetDenomination) {
        if (_baseChainAssetPrecision > 18) {
            revert("AstriaWithdrawer: base chain asset precision must be less than or equal to 18");
        }
        BASE_CHAIN_ASSET_PRECISION = _baseChainAssetPrecision;
        BASE_CHAIN_BRIDGE_ADDRESS = _baseChainBridgeAddress;
        BASE_CHAIN_ASSET_DENOMINATION = _baseChainAssetDenomination;
        DIVISOR = 10 ** (18 - _baseChainAssetPrecision);
    }

    modifier sufficientValue(uint256 amount) {
        require(amount / DIVISOR > 0, "AstriaWithdrawer: insufficient value, must be greater than 10 ** (18 - BASE_CHAIN_ASSET_PRECISION)");
        _;
    }
    
    function withdrawToSequencer(string calldata destinationChainAddress) external payable sufficientValue(msg.value) {
        emit SequencerWithdrawal(msg.sender, msg.value, destinationChainAddress);
    }

    function withdrawToIbcChain(string calldata destinationChainAddress, string calldata memo) external payable sufficientValue(msg.value) {
        emit Ics20Withdrawal(msg.sender, msg.value, destinationChainAddress, memo);
    }
}
