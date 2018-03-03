pragma solidity ^0.4.11;

contract EthRaf {

    address[5] private players;
    bool[5] private playerPayStatus;
    address private blankAddress;
    uint lastTran = now; //time that the contract is initialised
    uint gameSize = 10000; 

    function() public payable {}
    
    function timeSince() public view returns(uint) {
        uint currTime = block.timestamp; 
        uint elapsed = currTime - lastTran;     //time between now and last call to main()
        return elapsed;   
    }
    
    function returnFunds() public {
        uint elapsedTime = timeSince();
        uint week = 604800;     // week in seconds
        if (elapsedTime > week) {
            for (uint v = 0; v < maxPlayerCount(); v++) {
                if (players[v] != blankAddress) {
                players[v].transfer(gameSize);
                } else {
                    return;
                }
            }
        }
    }
    
    event updateAddress(    // Gets the address's of the entrants for the front page
        address addOne,
        address addTwo,
        address addThree,
        address addFour,
        address addFive
    );
        
    event timeStatus(
        uint theTime
    );
    
    function getPlayer() public view returns(address, address, address, address, address){
        return (players[0], players[1], players[2], players[3], players[4]);
    }
    
    function contractBalance() public view returns(uint) {     //return contract balance
       uint balance = this.balance;
       return balance;
    }

    function deposit(uint256 amount) payable public { 
        require(msg.value == amount);
    }

    function maxPlayerCount() public constant returns(uint count) {     //length of player array, potential for being dynamic
        return players.length;
    }

    function enterPlayer(address entrantAddress) public {     //enters a players address into the players array
        for (uint x = 0; x < maxPlayerCount(); x++) {
            if (players[x] == blankAddress) {
                players[x] = entrantAddress;
                return;
                }
            }
    }

    function initPlayer() private {     //sets array of players address to blankAddress
            for (uint i = 0; i < maxPlayerCount(); i++) {
                players[i] = blankAddress;
            }
            for (uint n = 0; n < maxPlayerCount(); n++) {
                playerPayStatus[n] = false;
            }
    }
   
    function receivePay() public payable {

        uint deposited = msg.value;     //amount deposited by msg.sender
        if (deposited == gameSize) {
            enterPlayer(msg.sender);    //enter player into players array
            for (uint y = 0; y < maxPlayerCount(); y++) { //checks they pay and changes pay status
                if (players[y] == msg.sender) {
                    playerPayStatus[y] = true;
                }
            } 
            }else {
                msg.sender.transfer(deposited);    //returns eth to owner
            }

    }

    function returnEntrants() public view returns(address, address, address, address, address) {   //returns entrants
        return (players[0], players[1], players[2],players[3],players[4]);
    }

    function returnPayees() public view returns(bool, bool, bool, bool, bool) {    //returns if they've paid
        return (playerPayStatus[0], playerPayStatus[1], playerPayStatus[2], playerPayStatus[3], playerPayStatus[4]);
    }

    function entryChecker() public view returns(bool) { //checks for 5 entries and paid players
        if ((players[4] != blankAddress)&&(playerPayStatus[4] == true)) {
            return true;
        } else {
            return false;
            }
    }

    function randGenerator() public view returns(uint) {
        uint playerXOR = uint(blankAddress);
        for (uint y = 0; y < maxPlayerCount(); y++) {   //XOR's all of the players addresses
            playerXOR = playerXOR ^ uint(players[y]);
            } 
        uint backTrackNum = (playerXOR % 150) + 1;   //amount of blocks the random no. will be generated from
        uint randNum = (uint(block.blockhash(block.number-backTrackNum))) % 5 + 1;
        return randNum;

    }   

    function main() public payable returns(address) {
        receivePay();
        lastTran = now;   //resets the last transaction time
        updateAddress(players[0], players[1], players[2],players[3],players[4]);
        uint timeItHasBeen = timeSince();
        timeStatus(timeItHasBeen);
        if (entryChecker() == true) {   //checks if all the entries are paid and address full
            uint number = randGenerator();
            address winner = players[number];
            winner.transfer(this.balance);
            initPlayer();
        } 
    }
    
}