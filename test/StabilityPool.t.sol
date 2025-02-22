solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {StabilityPool} from "../../../contracts/core/pools/StabilityPool/StabilityPool.sol";
import {IRToken} from "../../../contracts/interfaces/core/tokens/IRToken.sol";
import {IDEToken} from "../../../contracts/interfaces/core/tokens/IDEToken.sol";
import {IRAACCToken} from "../../../contracts/interfaces/core/tokens/IRAACCToken.sol";
import {IRAACMinter} from "../../../contracts/interfaces/core/minters/RAACMinter/IRAACMinter.sol";
import {ILendingPool} from "../../../contracts/interfaces/core/pools/LendingPool/ILendingPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StabilityPoolTest is Test {
    StabilityPool public stabilityPool;
    IRToken public rToken;
    IDEToken public deToken;
    IRAACCToken public raacToken;
    IRAACMinter public raacMinter;
    IERC20 public crvUSDToken;
    ILendingPool public lendingPool;

    address public owner = address(1);
    address public market1 = address(10);
    address public market2 = address(11);
    address public notMarket = address(12);

    function setUp() public {
        vm.startPrank(owner);
        rToken = new IRToken();
        deToken = new IDEToken();
        raacToken = new IRAACCToken();
        raacMinter = new IRAACMinter();
        crvUSDToken = new IERC20(address(0));
        lendingPool = new ILendingPool();

        stabilityPool = new StabilityPool(owner);
        stabilityPool.initialize(address(rToken), address(deToken), address(raacToken), address(raacMinter), address(crvUSDToken), address(lendingPool));
        vm.stopPrank();
    }

    function test_GetMarketAllocation_ExistingMarket() public {
        vm.startPrank(owner);
        uint256 allocation = 100;
        stabilityPool.addMarket(market1, allocation);
        vm.stopPrank();
        assertEq(stabilityPool.getMarketAllocation(market1), allocation);
    }

    function test_GetMarketAllocation_NonExistingMarket() public {
        vm.startPrank(owner);
        vm.expectRevert(StabilityPool.MarketNotFound.selector);
        stabilityPool.getMarketAllocation(notMarket);
        vm.stopPrank();
    }

    function test_IsSupportedMarket_Supported() public {
        vm.startPrank(owner);
        stabilityPool.addMarket(market2, 10);
        vm.stopPrank();
        assertTrue(stabilityPool.isSupportedMarket(market2));
    }

    function test_IsSupportedMarket_NotSupported() public {
        assertFalse(stabilityPool.isSupportedMarket(notMarket));
    }
}