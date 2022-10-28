// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CallTest {
	uint256 public amount;
	uint256 public receivedAmount;
	uint256 public fallbackedAmount;

	receive() external payable {
		receivedAmount = receivedAmount + msg.value;
	}

	fallback() external payable {
		fallbackedAmount = fallbackedAmount + msg.value;
	}

	function setAmount(uint256 _amount) public payable {
		amount = _amount;
	}

	function _decreaseAmount(uint256 _amount) public {
		amount = amount - _amount;
	}

	function decreaseAmountNormal(uint256 _amount) external {
		_decreaseAmount(_amount);
	}

	function decreaseAmountLow(uint256 _amount) external {
		(bool success, ) = address(this).call(
			abi.encodeWithSignature("_decreaseAmount(uint256)", _amount)
		);
		require(success, "Contract Execution Failed");
	}
}
