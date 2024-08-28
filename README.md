# astria-bridge-withdrawer

Forge project for the bridge withdrawer contract.

Requirements:

- foundry

Build:

```sh
forge build
```

Copy the example .env: `cp local.env.example .env`

Put your private key in `.env` and `source .env`.

### `AstriaWithdrawer.sol`

Deploy `AstriaWithdrawer.sol`:

```sh
forge script script/AstriaWithdrawer.s.sol:AstriaWithdrawerScript \
   --rpc-url $RPC_URL --broadcast --sig "deploy()" -vvvv
```

Call `withdrawToSequencer` in `AstriaWithdrawer.sol`:

```sh
forge script script/AstriaWithdrawer.s.sol:AstriaWithdrawerScript \
   --rpc-url $RPC_URL --broadcast --sig "withdrawToSequencer()" -vvvv
```

Call `withdrawToOriginChain` in `AstriaWithdrawer.sol`:

```sh
forge script script/AstriaWithdrawer.s.sol:AstriaWithdrawerScript \
   --rpc-url $RPC_URL --broadcast --sig "withdrawToOriginChain()" -vvvv
```

### `AstriaBridgeableERC20.sol`

Deploy `AstriaBridgeableERC20.sol`:

```sh
forge script script/AstriaBridgeableERC20.s.sol:AstriaBridgeableERC20Script \
--rpc-url $RPC_URL --broadcast --sig "deploy()" -vvvv
```

Mint tokens (note that this will only work on a local anvil network, as it uses `vm.prank()`)
```sh
forge script script/AstriaBridgeableERC20.s.sol:AstriaBridgeableERC20Script \
--rpc-url $RPC_URL --broadcast --sig "mint()" -vvvv
```

Call `withdrawToSequencer` in `AstriaBridgeableERC20.sol`:

```sh
forge script script/AstriaBridgeableERC20.s.sol:AstriaBridgeableERC20Script \
   --rpc-url $RPC_URL --broadcast --sig "withdrawToSequencer()" -vvvv
```

Call `withdrawToOriginChain` in `AstriaBridgeableERC20.sol`:

```sh
forge script script/AstriaBridgeableERC20.s.sol:AstriaBridgeableERC20Script \
   --rpc-url $RPC_URL --broadcast --sig "withdrawToOriginChain()" -vvvv
```
