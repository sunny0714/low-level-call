// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import { BaseTest, console } from "./base/BaseTest.t.sol";
import "../main/CallTest.sol";

contract ContractTest is BaseTest {
	
	
	address private owner;
	address private user1;
	address private user2;

	CallTest private callTest;
	function setUp() public {
		vm.warp(10000);

		owner = accounts.PUBLIC_KEYS(0);
		user1 = accounts.PUBLIC_KEYS(1);
		user2 = accounts.PUBLIC_KEYS(2);

		callTest = new CallTest();
		(bool success, ) = address(callTest).call{value: 2 ether}(abi.encodeWithSignature("setAmount(uint256)", 100));
		require(success, "Test is failed");
	}

	function test_setAmount_normal() public {
		callTest.setAmount(100);
		assertEq(callTest.amount(), 100);

		assertEq(address(callTest).balance, 2 ether);
	}

	function test_setAmount_lowlevel() public prankAs(owner){
		(bool sent, bytes memory data) = address(callTest).call{value: 1 ether}(abi.encodeWithSignature("setAmount(uint256)", 100));
		assertEq(callTest.amount(), 100);

		// /////////////////////
		assertEq(address(callTest).balance, 3 ether);
	}

	function test_decreaseAmountNormal() public {
		callTest.setAmount(100);
		
		callTest.decreaseAmountNormal(10);
		assertEq(callTest.amount(), 90);
	}

	function test_decreaseAmountLow() public {
		callTest.setAmount(100);
		
		callTest.decreaseAmountLow(10);
		assertEq(callTest.amount(), 90);
	}

	function test_send_givenExactAmount_thenSuccess() public {
		(bool sent, bytes memory data) = address(callTest).call{value: 10 ether}(abi.encodeWithSignature("setAmount(uint256)", 100));
		assertEq(callTest.amount(), 100);

		vm.startPrank(address(callTest));
		{
			payable(owner).send(1 ether);
		}
		vm.stopPrank();
		
		assertEq(address(callTest).balance, 11 ether);
	}

	function test_send_givenWrongAmount_thenFail() public {
		vm.startPrank(address(callTest));
		{
			payable(owner).send(5 ether);
		}
		vm.stopPrank();
	} 

	function test_transfer_givenExactAmount_thenSuccess() public {
		(bool sent, bytes memory data) = address(callTest).call{value: 10 ether}(abi.encodeWithSignature("setAmount(uint256)", 100));
		assertEq(callTest.amount(), 100);

		vm.startPrank(address(callTest));
		{
			payable(owner).transfer(1 ether);
		}
		vm.stopPrank();
		
		assertEq(address(callTest).balance, 11 ether);
	}

	function test_transfer_givenWrongAmount_thenFail() public {
		
		vm.startPrank(address(callTest));
		{
			vm.expectRevert("");
			payable(owner).transfer(5 ether);
		}
		vm.stopPrank();
	} 
	
	function test_receive() public {
		console.log(address(callTest).balance);
		address(callTest).call{value: 1 ether}("");
		assertEq(callTest.receivedAmount(), 1 ether);
		console.log(address(callTest).balance);
	}

	function test_fallback() public {
		console.log(address(callTest).balance);
		(bool sent, bytes memory data) = address(callTest).call{value: 10 ether}(abi.encodeWithSignature("setAmount1(uint256)", 100));
		assertEq(callTest.fallbackedAmount(), 10 ether);
		console.log(address(callTest).balance);
	}
}
