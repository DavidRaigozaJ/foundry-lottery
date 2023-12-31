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

import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import { VRFConsumerBaseV2 } from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Raffle
 * @author David Raigoza
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */

/** contracts */

contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();

    /** Type declarations */

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    address payable[] private s_players;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    // we are using an array to keep track of all players
    

    /** Envents */
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 entranceFee, 
        uint256 interval, 
        address vrfCoordinator, 
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
        )VRFConsumerBaseV2(vrfCoordinator){
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
        
    }

    /** Functions */

    function enterRaffle()  external payable {
        if(msg.value != i_entranceFee){
            revert Raffle__NotEnoughEthSent();
        }
        if (s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    // When is the winner supposed to be picked?

    /**
     * @dev This is the function that the Chainlink Automation nodes call
     * to see if it's time to perform an upkeep.
     * The following should be true for this to return true:
     * 1. The time interval has passed between raffle runs
     * 2. The raffle is in the OPEN state
     * 3. The contract has ETH (aka, players)
     * 4. (Implicit) The subscription is funded with LINK
     */

    function checkUpKeep(
        bytes memory /** checkData */
        ) public view returns (bool upkeepNeeded, bytes memory /** performData */ ) {
            if ((block.timestamp - s_lastTimeStamp) < i_interval) {
                revert();
            }
        }

    function pickWinner() public {
        // check time to pick the winner
        if((block.timestamp - s_lastTimeStamp) < i_interval){
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;
         uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        
    }

    // CEI: Checks, Effects, Interactions
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // Checks
        // Effects
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit PickedWinner(winner);
        // Interactions(Other contracts)
        (bool success,) = winner.call{value: address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
      
    }

    /** Getter Function */

    function getEntraceFee() external view returns(uint256) {
        return i_entranceFee;
    }

}
