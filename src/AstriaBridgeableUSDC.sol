// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {IAstriaWithdrawer} from "./IAstriaWithdrawer.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AstriaBridgeableUSDC is IAstriaWithdrawer, ERC20 {
    // the `astriaBridgeSenderAddress` built into the astria-geth node
    address public immutable BRIDGE;

    // the divisor used to convert the rollup asset amount to the base chain denomination
    //
    // set to 10 ** (TOKEN_DECIMALS - BASE_CHAIN_ASSET_PRECISION) on contract creation
    uint256 private immutable DIVISOR;

    // emitted when tokens are minted from a deposit
    event Mint(address indexed account, uint256 amount);

    modifier onlyBridge() {
        require(msg.sender == BRIDGE, "AstriaBridgeableUSDC: only bridge can mint");
        _;
    }

    constructor(
        address _bridge,
        uint32 _baseChainAssetPrecision,
        string memory _baseChainBridgeAddress, 
        string memory _baseChainAssetDenomination
    ) ERC20("USDC", "USDC") {
        if (_baseChainAssetPrecision > decimals()) {
            revert("AstriaBridgeableUSDC: base chain asset precision must be less than or equal to token decimals");
        }

        BASE_CHAIN_ASSET_PRECISION = _baseChainAssetPrecision;
        BASE_CHAIN_BRIDGE_ADDRESS = _baseChainBridgeAddress;
        BASE_CHAIN_ASSET_DENOMINATION = _baseChainAssetDenomination;
        DIVISOR = 10 ** (decimals() - _baseChainAssetPrecision);
        BRIDGE = _bridge;
    }

    modifier sufficientValue(uint256 amount) {
        require(amount / DIVISOR > 0, "AstriaBridgeableUSDC: insufficient value, must be greater than 10 ** (TOKEN_DECIMALS - BASE_CHAIN_ASSET_PRECISION)");
        _;
    }

    function mint(address _to, uint256 _amount)
        external
        onlyBridge
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function withdrawToSequencer(uint256 _amount, string calldata _destinationChainAddress)
        external
        sufficientValue(_amount)
    {
        _burn(msg.sender, _amount);
        emit SequencerWithdrawal(msg.sender, _amount, _destinationChainAddress);
    }

    function withdrawToIbcChain(uint256 _amount, string calldata _destinationChainAddress, string calldata _memo)
        external
        sufficientValue(_amount)
    {
        _burn(msg.sender, _amount);
        emit Ics20Withdrawal(msg.sender, _amount, _destinationChainAddress, _memo);
    }
}
