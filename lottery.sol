//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

///@author Ciphadus
///@title Lottery Contract with Manager's Fee

contract Lottery{

    address payable[] public players;   ///@notice initialize dynamic array
    address public manager;             ///@notice initialize manager

    constructor(){
        manager = msg.sender;
        players.push(payable(manager)); ///@notice manager automatically enters the lottery
    }

    receive() external payable {                   ///@notice receives from EOA and setting requirements
        require(msg.value == 0.1 ether);         
        players.push(payable(msg.sender));        /*@dev the one who sends ETH is added to the array. Convert into payable cos array
                                                    consists of payable address */
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager);         ///@dev Makes sure that only the manager can run this function
        return address(this).balance;           ///@return Balance of the contract's account
    }

    function random() public view returns(uint) {                ///@return a pseduo-random number
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public {      ///@dev selecting winner and transferring money
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r = random();
        address payable winner;
        uint index = r % players.length;
        uint fee = getBalance() * 10 / 100;    ///@dev calculating manager's fee which is 10% of total deposited funds
        uint winAmt = index - fee;
        winner = players[winAmt];

        payable(manager).transfer(fee);       ///@dev pays fee to the manager
        winner.transfer(getBalance());        ///@dev sends prize money to the winner

        players = new address payable[](0); ///@dev reset the lottery
    }





}
