// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract SmartBetContract {
    address private admin;

    struct Player {
        uint id;
        address player_address;
        string pseudo;
        uint256 victories;
    }
    struct Match {
        uint256 teamA;
        uint256 teamB;
    }

    Player[] players;
    uint256 participant_number;
    Match[] private matchs;

    // map of array of Players who won the bet by matchId
    mapping(uint256 => Player[]) public winners;
    
    uint256 private time_of_a_day = 100000;
    uint256 private beginning_of_the_day;
    uint256 profits;

    event NewPlayer(uint256 id, string pseudo);
    event WinTheBet(Player winner, uint256 matchId);

    constructor() {
        admin = msg.sender;
        profits = 0;
        matchs.push(Match({teamA: 1, teamB: 0}));
        matchs.push(Match({teamA: 3, teamB: 1}));
        matchs.push(Match({teamA: 1, teamB: 0}));
        matchs.push(Match({teamA: 0, teamB: 1}));
        matchs.push(Match({teamA: 3, teamB: 1}));
        matchs.push(Match({teamA: 0, teamB: 1}));
        matchs.push(Match({teamA: 4, teamB: 3}));
        matchs.push(Match({teamA: 0, teamB: 1}));
        matchs.push(Match({teamA: 1, teamB: 0}));
        matchs.push(Match({teamA: 2, teamB: 5}));
        beginning_of_the_day = block.timestamp;
    }

    function bet(
        uint256 matchId,
        uint256 scoreA,
        uint256 scoreB,
        string memory your_pseudo
    ) external payable {
        require(matchId < matchs.length, "Bad request");
        profits += admission(your_pseudo);
        Match memory match_to_bet = matchs[matchId];

        // adding player who won the bet of a Match
        if (scoreA == match_to_bet.teamA && scoreB == match_to_bet.teamB) {
            Player memory winner;
            for (uint256 i = 0; i < players.length; ++i){
                if (players[i].player_address == msg.sender){
                    winner = players[i];
                    break;
                }
            }
            emit WinTheBet(winner, matchId);
            if (isWinner(winner, matchId)) {
                return;
            }
            ++winner.victories;
            winners[matchId].push(winner);
        }
    }

    Player[] theWinners;

    function bestWinners() public onlyOwner {
        require(block.timestamp > beginning_of_the_day + time_of_a_day, "Waiting for the end of the day");
        for (uint256 i = 0; i < matchs.length; ++i) {
            Player[] memory winners_of_match = winners[i];
        }
        uint256 nb_of_victories = matchs.length;
        while (theWinners.length < 5 && nb_of_victories > 0) {
            for (uint256 i = 0; i < participant_number; ++i) {
                if (players[i].victories == nb_of_victories) {
                    theWinners.push(players[i]);
                }
                if (theWinners.length == 5){
                    break;
                }
            }
            --nb_of_victories;
        }
    }

    function isWinner(
        Player memory player,
        uint256 matchId
    ) internal view returns (bool) {
        for (uint256 i = 0; i < winners[matchId].length; ++i) {
            if (winners[matchId][i].id == player.id) {
                return true;
            }
        }
        return false;
    }

    function admission(string memory your_pseudo) internal returns (uint256) {
        require(
            msg.value == 0.01 ether,
            "Not the right amount of fees (0.01 ether)"
        );
        players[participant_number] = Player({
            id: participant_number,
            pseudo: your_pseudo,
            player_address: msg.sender,
            victories: 0
        });
        ++participant_number;
        emit NewPlayer(participant_number, your_pseudo);
        return msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "Not Authorized");
        _;
    }
}
