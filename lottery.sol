//SPDX-License-Identifier: GPL-3.0
 
pragma solidity ^0.8.0;

///@author Ciphadus
///@title Lottery Contract with Manager's Fee

contract Lottery{

    address payable[] public players;   ///@notice initialize dynamic array
    address public manager;             ///@notice initialize manager
    uint public lotteryNumber;

    enum State {Started, Ended}		///@notice Set the lottery state
    State public lotteryState;

    constructor(){
        manager = msg.sender;
        lotteryState = State.Started;
    }


    receive() external payable {                   ///@notice receives from EOA and setting requirements
        require(msg.value == 0.1 ether);         
        players.push(payable(msg.sender));        /*@dev the one who sends ETH is added to the array. Convert into payable cos array
                                                    consists of payable address */
    }


    modifier isManager(){	///@dev modifier to ensure manager is calling functions etc.
        require(manager == msg.sender);
        _;
    }

    function getBalance() public view returns (uint){
        return address(this).balance;           ///@return Balance of the contract's account
    }

    function random() public view returns(uint) {                ///@return a pseduo-random number
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public isManager {      ///@dev selecting winner and transferring money
        require(players.length >= 3);

        uint r = random();
        address payable winner;
        uint index = r % players.length;
        uint fee = getBalance() * 10 / 100;    ///@dev calculating manager's fee which is 10% of total deposited funds
        uint winAmt = getBalance() - fee;
        winner = players[index];

        payable(manager).transfer(fee);       ///@dev pays fee to the manager
        winner.transfer(winAmt);        ///@dev sends prize money to the winner

        lotteryState = State.Ended;
        players = new address payable[](0); ///@dev reset the lottery
        

    }

    function newLottery() public {		///@dev start a new lottery
        lotteryNumber ++;
        lotteryState = State.Started;
    }





}

