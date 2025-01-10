// SPDX-License-Identifier: MIT or Apache-2.0
pragma solidity ^0.8.21;

import {AstriaBridgeableERC20} from "./AstriaBridgeableERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract AstriaBridgeableERC20Manager is Ownable {

  struct BridgeableErc20Asset {
    uint256 startHeight;
    bytes32 astriaAssetDenominationHash;
    address erc20Contract;
  }

  mapping(string => BridgeableErc20Asset) public bridgeableErc20Assets;

  modifier onlyErc20Bridge(address _bridgeableERC20Address) {
    AstriaBridgeableERC20 bridgeableErc20 = AstriaBridgeableERC20(_bridgeableERC20Address);
    require(msg.sender == bridgeableErc20.BRIDGE(), "AstriaBridgeableERC20Manager: only erc20 bridge can call this function");
    _;
  }

  constructor() Ownable(msg.sender) {}

  function createBridgeableErc20Asset (
    uint32 _baseChainAssetPrecision,
    string memory _baseChainBridgeAddress,
    string memory _baseChainAssetDenomination,
    string memory _name,
    string memory _symbol,
    uint256 _sequencerWithdrawalFee,
    uint256 _ibcWithdrawalFee,
    address _feeRecipient,
    uint8 _decimals
  ) external onlyOwner {
    require(bytes(_baseChainBridgeAddress).length == 45, "AstriaBridgeableERC20Manager: astria bridge address must be 45 bytes");
    AstriaBridgeableERC20 newBridgeableErc20 = new AstriaBridgeableERC20(
      address(this),
      _baseChainAssetPrecision,
      _baseChainBridgeAddress,
      _baseChainAssetDenomination,
      _name,
      _symbol,
      _sequencerWithdrawalFee,
      _ibcWithdrawalFee,
      _feeRecipient,
      _decimals
    );
    uint256 startHeight = block.number + 1;
    _registerBridgeableErc20Asset(startHeight, address(newBridgeableErc20));
  }

  function registerBridgeableErc20Asset (
    uint256 _startHeight,
    address _contractAddress
  ) external onlyOwner {
    _registerBridgeableErc20Asset(_startHeight, _contractAddress);
  }

  function getEnabledContractAddressForBridge (string memory astriaBridgeAddress) external view returns (address) {
    return _getEnabledContractForBridge(astriaBridgeAddress).erc20Contract;
  }

  function mint(string memory _astriaBridgeAddress, string memory _astriaAssetDenom, uint256 _astriaAmount, address _to) external onlyErc20Bridge(msg.sender) {
    BridgeableErc20Asset storage bridgeableErc20 = _getEnabledContractForBridge(_astriaBridgeAddress);
    AstriaBridgeableERC20 bridgeableContract = AstriaBridgeableERC20(bridgeableErc20.erc20Contract);

    require(address(bridgeableErc20.erc20Contract) != address(0), "AstriaBridgeableERC20Manager: asset not registered");
    require(keccak256(bytes(_astriaAssetDenom)) == bridgeableErc20.astriaAssetDenominationHash, "AstriaBridgeableERC20Manager: asset denomination mismatch");
    uint256 assetScalar = 10 ** (bridgeableContract.decimals() - bridgeableContract.BASE_CHAIN_ASSET_PRECISION());
    uint256 amount = _astriaAmount * assetScalar;

    bridgeableContract.mint(_to, amount);
  }

  function _registerBridgeableErc20Asset (
    uint256 _startHeight,
    address _contractAddress
  ) internal {
    require(_startHeight >= 0, "AstriaBridgeableERC20Manager: start height must be greater than or equal to 0");
    AstriaBridgeableERC20 bridgeableErc20 = AstriaBridgeableERC20(_contractAddress);
    bytes32 _baseChainAssetDenominationHash = keccak256(bytes(bridgeableErc20.BASE_CHAIN_ASSET_DENOMINATION()));

    bridgeableErc20Assets[bridgeableErc20.BASE_CHAIN_BRIDGE_ADDRESS()] = BridgeableErc20Asset({
      startHeight: _startHeight,
      astriaAssetDenominationHash: _baseChainAssetDenominationHash,
      erc20Contract: _contractAddress
    });
  }

  function _getEnabledContractForBridge (string memory _astriaBridgeAddress) internal view returns (BridgeableErc20Asset storage) {
    BridgeableErc20Asset storage erc20Asset = bridgeableErc20Assets[_astriaBridgeAddress];
    require(erc20Asset.startHeight >= block.number, "AstriaBridgeableERC20Manager: asset not activated");
    
    return erc20Asset;
  }
}
