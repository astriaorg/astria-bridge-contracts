// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

abstract contract IAstriaWithdrawer is Ownable {
    // the precision of the asset on the base chain.
    //
    // the amount transferred on the base chain will be divided by 10 ^ (18 - BASE_CHAIN_ASSET_PRECISION).
    //
    // for example, if base chain asset is precision is 6, the divisor would be 10^12.
    uint32 public immutable BASE_CHAIN_ASSET_PRECISION;

    // the address of the bridge on the base chain.
    string public BASE_CHAIN_BRIDGE_ADDRESS;

    // the denomination of the asset on the base chain.
    string public BASE_CHAIN_ASSET_DENOMINATION;

    // The fee charged for each sequencer withdrawal transaction
    uint256 public SEQUENCER_WITHDRAWAL_FEE;

    // The fee charged for each IBC withdrawal transaction
    uint256 public IBC_WITHDRAWAL_FEE;

    // The address that receives the accumulated withdrawal fees
    address public FEE_RECIPIENT;

    // The total amount of fees collected & unclaimed from withdrawals
    uint256 public ACCUMULATED_FEES;

    // emitted when a withdrawal to the sequencer is initiated
    //
    // the `sender` is the evm address that initiated the withdrawal
    // the `destinationChainAddress` is the address on the sequencer the funds will be sent to
    event SequencerWithdrawal(address indexed sender, uint256 indexed amount, string destinationChainAddress);

    // emitted when a withdrawal to the IBC origin chain is initiated.
    // the withdrawal is sent to the origin chain via IBC from the sequencer using the denomination trace.
    //
    // the `sender` is the evm address that initiated the withdrawal
    // the `destinationChainAddress` is the address on the origin chain the funds will be sent to
    // the `memo` is an optional field that will be used as the ICS20 packet memo
    event Ics20Withdrawal(address indexed sender, uint256 indexed amount, string destinationChainAddress, string memo);

    modifier onlyFeeRecipient() {
        require(msg.sender == FEE_RECIPIENT, "AstriaBridgeableERC20: only fee recipient");
        _;
    }

    // Sets the sequencer withdrawal fee
    function setSequencerWithdrawalFee(uint256 _newFee) external onlyOwner {
        SEQUENCER_WITHDRAWAL_FEE = _newFee;
    }

    // Sets the IBC withdrawal fee
    function setIbcWithdrawalFee(uint256 _newFee) external onlyOwner {
        IBC_WITHDRAWAL_FEE = _newFee;
    }

    // Sets the fee recipient
    function setFeeRecipient(address _newFeeRecipient) external onlyOwner {
        FEE_RECIPIENT = _newFeeRecipient;
    }

    // Claims the accumulated fees
    function claimFees() external onlyFeeRecipient {
        (bool success, ) = FEE_RECIPIENT.call{value: ACCUMULATED_FEES}("");
        require(success, "AstriaBridgeableERC20: fee transfer failed");
        ACCUMULATED_FEES = 0;
    }
}
