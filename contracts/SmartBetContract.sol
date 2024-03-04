// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract SmartBetContract {
    address private admin;
    uint increment;
    struct Player {
        uint id;
        string pseudo;

    }
    mapping (address => Player) public players;
    event NewPlayer(uint256 id, string pseudo);
    event WinTheBet(Player winner, uint256 matchId);

    struct Match {
        uint256 teamA;
        uint256 teamB;
    }

    Match[] private matchs;

    // map of array of Players who won the bet by matchId
    mapping (uint256 => Player[]) public winners;

    uint256 private aDay = 100000;
    uint256 private beginning_of_the_day;

    constructor () {
        admin = msg.sender;
        increment = 0;
        matchs.push(Match({teamA: 1, teamB: 0}));
        matchs.push(Match({teamA: 3, teamB: 1}));
        matchs.push(Match({teamA: 1, teamB: 1}));
        beginning_of_the_day = block.timestamp;
    }

    function bet(uint256 matchId, uint256 scoreA, uint256 scoreB, string memory your_pseudo) external payable {
        require(matchId < matchs.length, "Bad request");
        admission(your_pseudo);
        Match memory match_to_bet = matchs[matchId];

        // adding player who won the bet of a Match
        if (scoreA == match_to_bet.teamA && scoreB == match_to_bet.teamB){
            Player memory winner = players[msg.sender];
            emit WinTheBet(winner, matchId);
            if (isWinner(winner, matchId)){
                return;
            }
            winners[matchId].push(winner);
        }
    }


    function isWinner(Player memory player, uint256 matchId) internal view returns (bool) {
        for (uint256 i = 0; i < winners[matchId].length; ++i) {
            if (winners[matchId][i].id == player.id) {
                return true;
            }
        }
        return false;
    }
    function admission(string memory your_pseudo) internal returns (uint256){
        require(msg.value == 0.01 ether, "Not the right amount of fees (0.01 ether)");
        players [msg.sender] = Player ({
            id: ++increment,
            pseudo: your_pseudo
        });
        emit NewPlayer(increment, your_pseudo);
        return msg.value;
    }

}