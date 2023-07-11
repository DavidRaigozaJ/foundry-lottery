// Order of Layout

/** Pragma statements/
/** Import statements */
/** Erros */
/** Interfaces */
/** Libraries */
/** Contracts */

// Inside each contract or interface, use the following order:

/** Type declarations */
/** State variables */
/** Events */
/** Modifiers */
/** Functions */

// Layout of functions

/** Constructor */
/** Receive function (if exists) */
/** Fallback function (if exists) */
/** External */
/** Public */
/** Internal */ 
/** Private */
/** view and pure functions */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


/**
 * @title Raffle
 * @author David Raigoza
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */

/** contracts */

contract Raffle {
    error Raffle__NotEnoughEthSent();

    /** State Variables */
    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    address[] private s_players;
    uint256 private s_lastTimeStamp;

    // we are using an array to keep track of all players
    
    /** Envents */

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    /** Functions */

    function enterRaffle()  external payable {
        if(msg.value != i_entranceFee){
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    // 1. Get a Random number
    // 2. use the random numer to pick a player
    // 3. Be Automatically called
    function pickWinner() public {
        // check time to pick the winner
        if((block.timestamp - s_lastTimeStamp) < i_interval){
            revert();
        }
    }

    /** Getter Function */

    function getEntraceFee() external view returns(uint256) {
        return i_entranceFee;
    }

}