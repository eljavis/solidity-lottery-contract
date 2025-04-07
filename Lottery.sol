// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Lottery {
    
    address public owner;
    uint public minFee;
    address[] public players;
    mapping(address => uint) public playerBalance;

    
    event PlayerJoined(address player, uint amount);
    event WinnerPicked(address winner, uint amount);
    event LotteryReset();

    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier minFeeToPay() {
        require(msg.value >= minFee, "Not enough Ether sent.");
        _;
    }

    
    constructor(uint _minFee) {
        owner = msg.sender;
        minFee = _minFee;
    }

    
    function play() public payable minFeeToPay {
        players.push(msg.sender);
        playerBalance[msg.sender] += msg.value;
        emit PlayerJoined(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getRandomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery.");

        uint index = getRandomNumber() % players.length;
        address winner = players[index];
        uint prize = getBalance();

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Failed to send Ether to the winner.");

        emit WinnerPicked(winner, prize);

        players = new address[](0); // Reset players array
        emit LotteryReset();
    }
}
