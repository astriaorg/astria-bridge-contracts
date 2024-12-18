// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {IAstriaWithdrawer} from "./IAstriaWithdrawer.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

// This contract facilitates withdrawals of the native asset from the rollup to the base chain.
// 
// Funds can be withdrawn to either the sequencer or the origin chain via IBC.
contract AstriaWithdrawer is IAstriaWithdrawer {
    // the divisor used to convert the rollup asset amount to the base chain denomination
    //
    // set to 10 ** (18 - BASE_CHAIN_ASSET_PRECISION) on contract creation
    uint256 private immutable DIVISOR;

    constructor(
        uint32 _baseChainAssetPrecision,
        string memory _baseChainBridgeAddress,
        string memory _baseChainAssetDenomination,
        uint256 _sequencerWithdrawalFee,
        uint256 _ibcWithdrawalFee,
        address _feeRecipient
    ) Ownable(msg.sender) {
        if (_baseChainAssetPrecision > 18) {
            revert("AstriaWithdrawer: base chain asset precision must be less than or equal to 18");
        }
        BASE_CHAIN_ASSET_PRECISION = _baseChainAssetPrecision;
        BASE_CHAIN_BRIDGE_ADDRESS = _baseChainBridgeAddress;
        BASE_CHAIN_ASSET_DENOMINATION = _baseChainAssetDenomination;
        DIVISOR = 10 ** (18 - _baseChainAssetPrecision);
        SEQUENCER_WITHDRAWAL_FEE = _sequencerWithdrawalFee;
        IBC_WITHDRAWAL_FEE = _ibcWithdrawalFee;
        FEE_RECIPIENT = _feeRecipient;
    }

    modifier sufficientValue(uint256 amount, uint256 withdrawalFee) {
        require(amount > withdrawalFee, "AstriaWithdrawer: insufficient withdrawal fee");
        require((amount - withdrawalFee) / DIVISOR > 0, "AstriaWithdrawer: insufficient value, must be greater than 10 ** (18 - BASE_CHAIN_ASSET_PRECISION)");
        _;
    }

    function withdrawToSequencer(string calldata destinationChainAddress)
        external payable
        sufficientValue(msg.value, SEQUENCER_WITHDRAWAL_FEE)
    {
        ACCUMULATED_FEES += SEQUENCER_WITHDRAWAL_FEE;
        emit SequencerWithdrawal(msg.sender, msg.value - SEQUENCER_WITHDRAWAL_FEE, destinationChainAddress);
    }

    function withdrawToIbcChain(string calldata destinationChainAddress, string calldata memo)
        external payable
        sufficientValue(msg.value, IBC_WITHDRAWAL_FEE)
    {
        ACCUMULATED_FEES += IBC_WITHDRAWAL_FEE;
        emit Ics20Withdrawal(msg.sender, msg.value - IBC_WITHDRAWAL_FEE, destinationChainAddress, memo);
    }
}
