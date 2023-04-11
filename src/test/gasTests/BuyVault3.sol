/**
 * Created by Pragma Labs
 * SPDX-License-Identifier: BUSL-1.1
 */
pragma solidity ^0.8.13;

import "../fixtures/GastTestFixture.f.sol";

contract gasBuyVault_1ERC201ERC721 is GasTestFixture {
    using stdStorage for StdStorage;

    bytes3 public emptyBytes3;

    //this is a before
    constructor() GasTestFixture() { }

    //this is a before each
    function setUp() public override {
        super.setUp();

        vm.startPrank(vaultOwner);
        s_assetAddresses = new address[](2);
        s_assetAddresses[0] = address(eth);
        s_assetAddresses[1] = address(bayc);

        s_assetIds = new uint256[](2);
        s_assetIds[0] = 0;
        s_assetIds[1] = 1;

        s_assetAmounts = new uint256[](2);
        s_assetAmounts[0] = 10 ** Constants.ethDecimals;
        s_assetAmounts[1] = 1;

        proxy.deposit(s_assetAddresses, s_assetIds, s_assetAmounts);

        uint256 valueEth = (((10 ** 18 * rateEthToUsd) / 10 ** Constants.oracleEthToUsdDecimals) * s_assetAmounts[0])
            / 10 ** Constants.ethDecimals;
        uint256 valueBayc = (
            (10 ** 18 * rateBaycToEth * rateEthToUsd)
                / 10 ** (Constants.oracleBaycToEthDecimals + Constants.oracleEthToUsdDecimals)
        ) * s_assetAmounts[1];
        pool.borrow(
            uint128(((valueEth + valueBayc) / 10 ** (18 - Constants.daiDecimals) * collateralFactor) / 100),
            address(proxy),
            vaultOwner,
            emptyBytes3
        );
        vm.stopPrank();

        vm.prank(oracleOwner);
        oracleEthToUsd.transmit(int256(rateEthToUsd) / 2);
        vm.prank(oracleOwner);
        oracleBaycToEth.transmit(int256(rateBaycToEth) / 2);

        vm.prank(liquidatorBot);
        pool.liquidateVault(address(proxy));

        vm.prank(liquidityProvider);
        dai.transfer(vaultBuyer, 10 ** 10 * 10 ** 18);
    }

    function testBuyVaultStart() public {
        vm.roll(1); //compile warning to make it a view
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }

    function testBuyVaultBl100() public {
        vm.roll(100);
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }

    function testBuyVaultBl500() public {
        vm.roll(500);
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }

    function testBuyVaultBl1000() public {
        vm.roll(1000);
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }

    function testBuyVaultBl1500() public {
        vm.roll(1500);
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }

    function testBuyVaultBl2000() public {
        vm.roll(2000);
        vm.prank(vaultBuyer);
        liquidator.buyVault(address(proxy));
    }
}
