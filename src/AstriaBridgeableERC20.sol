// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {IAstriaWithdrawer} from "./IAstriaWithdrawer.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract AstriaBridgeableERC20 is IAstriaWithdrawer, ERC20 {
    // the `astriaBridgeSenderAddress` built into the astria-geth node
    address public immutable BRIDGE;

    // the divisor used to convert the rollup asset amount to the base chain denomination
    //
    // set to 10 ** (TOKEN_DECIMALS - BASE_CHAIN_ASSET_PRECISION) on contract creation
    uint256 private immutable DIVISOR;

    // emitted when tokens are minted from a deposit
    event Mint(address indexed account, uint256 amount);

    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "AstriaBridgeableERC20: only bridge can mint");
        _;
    }

    constructor(
        address _bridge,
        uint32 _baseChainAssetPrecision,
        string memory _baseChainBridgeAddress,
        string memory _baseChainAssetDenomination,
        string memory _name,
        string memory _symbol,
        uint256 _withdrawalFee,
        address _feeRecipient
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        uint8 decimals = decimals();
        if (_baseChainAssetPrecision > decimals) {
            revert("AstriaBridgeableERC20: base chain asset precision must be less than or equal to token decimals");
        }

        BASE_CHAIN_ASSET_PRECISION = _baseChainAssetPrecision;
        BASE_CHAIN_BRIDGE_ADDRESS = _baseChainBridgeAddress;
        BASE_CHAIN_ASSET_DENOMINATION = _baseChainAssetDenomination;
        DIVISOR = 10 ** (decimals - _baseChainAssetPrecision);
        BRIDGE = _bridge;
        WITHDRAWAL_FEE = _withdrawalFee;
        FEE_RECIPIENT = _feeRecipient;
    }

    modifier sufficientValue(uint256 amount) {
        require(amount / DIVISOR > 0, "AstriaBridgeableERC20: insufficient value, must be greater than 10 ** (TOKEN_DECIMALS - BASE_CHAIN_ASSET_PRECISION)");
        require(msg.value >= WITHDRAWAL_FEE, "AstriaBridgeableERC20: insufficient withdrawal fee");
        _;
    }

    function mint(address _to, uint256 _amount)
        external
        onlyBridge
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    function withdrawToSequencer(uint256 _amount, string calldata _destinationChainAddress)
        external payable
        sufficientValue(_amount)
    {
        ACCUMULATED_FEES += msg.value;
        _burn(msg.sender, _amount);
        emit SequencerWithdrawal(msg.sender, _amount, _destinationChainAddress);
    }

    function withdrawToIbcChain(uint256 _amount, string calldata _destinationChainAddress, string calldata _memo)
        external payable
        sufficientValue(_amount)
    {
        ACCUMULATED_FEES += msg.value;
        _burn(msg.sender, _amount);
        emit Ics20Withdrawal(msg.sender, _amount, _destinationChainAddress, _memo);
    }
}
