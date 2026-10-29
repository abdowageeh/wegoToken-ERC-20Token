// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "forge-std/Test.sol";
import "../src/WegoToken.sol";
import "@OpenZeppelin/contracts/interfaces/draft-IERC6093.sol";

contract WegoTokenTest is Test {
    WegoToken public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public{
        owner = address (this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        token = new WegoToken("WegoToken", "WT3");
    }
    

    // CONSTRACTOR TEST

    function test_constructor_setsName() public view {
        assertEq(token.name(), "WegoToken");
    }

    function test_constructor_setsSymbol() public view {
        assertEq(token.symbol(), "WT3");
    }

    function test_constructor_setsOwner() public view {
        assertEq(token.owner(), owner);
    }

    function test_constructor_zeroInitialSupply() public view {
        assertEq(token.totalSupply(), 0);
    }

    function test_constructor_decimals() public view {
        assertEq(token.decimals(), 18);
    }

    // ******** MINT TESTS ********

    function test_mint_asOwner() public {
        token.mint(user1, 1000e18);
        assertEq(token.balanceOf(user1), 1000e18);
        assertEq(token.totalSupply(), 1000e18);
    }

    function test_mint_toMultipleAddresses() public {
        token.mint(user1, 500e18);
        token.mint(user2, 300e18);
        assertEq(token.balanceOf(user1), 500e18);
        assertEq(token.balanceOf(user2), 300e18);
        assertEq(token.totalSupply(), 800e18);
    }

    function test_mint_revertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1)
            );
        token.mint(user1, 1000e18);
    }

    function test_mint_revertsIfZeroAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0))
            );
        token.mint(address(0), 1000e18);
    }

    // ******* Transfer Tests ********

    function test_transfer_successful() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        bool ok = token.transfer(user2, 500e18);
        assertTrue(ok);
        assertEq(token.balanceOf(user1), 500e18);
        assertEq(token.balanceOf(user2), 500e18);
    }

    function test_transfer_revertsIfInsufficientBalance() public {
        token.mint(user1, 100e18);
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user1, 100e18, 150e18)
            );
        token.transfer(user2, 150e18);
    }

    function test_transfer_revertsIfZeroAddress() public {
        token.mint(user1, 100e18);
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0))
            );
        token.transfer(address(0), 50e18);
    }

    function test_transfer_emitsTransferEvent() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(user1, user2, 500e18);
        token.transfer(user2, 500e18);
    }


    // ******* Approve&Allowance Tests ********


    function test_approve_successful() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        bool ok = token.approve(user2, 300e18);
        assertTrue(ok);
        assertEq(token.allowance(user1, user2), 300e18);
    }

    function test_approve_overwritePreviousAllowance() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        token.approve(user2, 500e18);
        vm.prank(user1);
        token.approve(user2, 200e18);
        assertEq(token.allowance(user1, user2), 200e18);
    }

    function test_approve_revertsIfZeroAddress() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidSpender.selector, address(0))
            );
        token.approve(address(0), 100e18);
    }

    function test_approve_emitsApprovalEvent() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit IERC20.Approval(user1, user2, 300e18);
        token.approve(user2, 300e18);
    }


    // ****** TransferFrom Tests ********

    function test_transferFrom_successful() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        token.approve(user2, 500e18);

        vm.prank(user2);
        bool ok = token.transferFrom(user1, user2, 300e18);
        assertTrue(ok);
        assertEq(token.balanceOf(user1), 700e18);
        assertEq(token.balanceOf(user2), 300e18);
        assertEq(token.allowance(user1, user2), 200e18);
    }

    function test_transferFrom_revertsIfInsufficientAllowance() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        token.approve(user2, 200e18);

        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector,  user2, 200e18, 300e18)
            );
        token.transferFrom(user1, user2, 300e18);
    }

    function test_transferFrom_infinteApproval() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        token.approve(user2, type(uint256).max);

        vm.prank(user2);
        bool ok = token.transferFrom(user1, user2, 300e18);
        assertTrue(ok);
        assertEq(token.balanceOf(user1), 700e18);
        assertEq(token.balanceOf(user2), 300e18);
        assertEq(token.allowance(user1, user2), type(uint256).max);
    }

    function test_transferFrom_revertsIfZeroAddress() public {
        token.mint(user1, 1000e18);
        vm.prank(user1);
        token.approve(user2, 300e18);

        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0))
            );
        token.transferFrom(user1, address(0), 100e18);
    }

    // ****** transfer ownership tests ******


    function test_transferOwnership_successful() public {
        token.transferOwnership(user1);
        assertEq(token.owner(), user1);
    }

    function test_transferOwnership_revertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1)
            );
        token.transferOwnership(user2);
    }

    function test_transferOwnership_revertsIfZeroAddress() public {
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0))
            );
        token.transferOwnership(address(0));
    }

    function test_transferOwnership_newOwnerCanMint() public {
        token.transferOwnership(user1);
        vm.prank(user1);
        token.mint(user2, 1000e18);
        assertEq(token.balanceOf(user2), 1000e18);
    }

    function test_transferOwnership_oldOwnerCannotMint() public {
        token.transferOwnership(user1);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner)
            );
        token.mint(user2, 1000e18);
    }


    // ***** renounce Ownership Tests ******

    function test_renounceOwnership_successful() public {
        token.renounceOwnership();
        assertEq(token.owner(), address(0));
    }

    function test_renounceOwnership_revertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1)
            );
        token.renounceOwnership();
    }

    function test_renounceOwnership_noOneCanMint() public {
        token.renounceOwnership();
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner)
            );
        token.mint(user2, 1000e18);
    }

}
