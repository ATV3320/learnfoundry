// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    function decrement() public {
        require(number > 0, "You can't decrease further");
        number--;
    }

    function getCount() public view returns(uint) {
        return number;
    }

}
