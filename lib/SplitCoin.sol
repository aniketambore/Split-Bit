//smart-contract for reference
//Deploy it on https://remix.ethereum.org

pragma solidity 0.6.6 ;

contract SplitCoin{
    int balance ;

    constructor() public{
        balance = 0 ;
    }

    function getBalance() view public returns(int){
        return balance ;
    }

    function depositBalance(int amt) public{
        balance = balance + amt ;
    }

    function withdrawBalance(int amt) public{
        balance = balance - amt ;
    }
}