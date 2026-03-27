// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdvancedVoting {
    // ============ STRUCTURES ============
    
    struct Candidate {
        string name;
        string description;
        uint256 voteCount;
        bool exists;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 weight;
        uint256 votedForCandidateId;
        uint256 votedAt;
    }
    
    struct Election {
        string title;
        string description;
        address creator;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isPaused;
        uint256 totalVotes;
        uint256 totalWeightedVotes;
        Candidate[] candidates;
        mapping(address => Voter) voters;
        address[] registeredVoters;
    }
    
    // ============ STATE VARIABLES ============
    
    address public owner;
    uint256 public electionCount;
    mapping(uint256 => Election) public elections;
    mapping(uint256 => mapping(address => bool)) public voterHistory;
    
    // ============ EVENTS ============
    
    event ElectionCreated(
        uint256 indexed electionId,
        string title,
        address indexed creator,
        uint256 startTime,
        uint256 endTime
    );
    
    event VoterRegistered(
        uint256 indexed electionId,
        address indexed voter,
        uint256 weight
    );
    
    event Voted(
        uint256 indexed electionId,
        address indexed voter,
        uint256 candidateId,
        string candidateName,
        uint256 weight
    );
    
    event ElectionEnded(
        uint256 indexed electionId,
        uint256 totalVotes,
        uint256 totalWeightedVotes
    );
    
    event ElectionPaused(uint256 indexed electionId);
    event ElectionUnpaused(uint256 indexed electionId);
    event ElectionExtended(uint256 indexed electionId, uint256 newEndTime);
    
    // ============ MODIFIERS ============
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier electionExists(uint256 _electionId) {
        require(_electionId < electionCount, "Election does not exist");
        _;
    }
    
    modifier electionActive(uint256 _electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election is not active");
        require(!election.isPaused, "Election is paused");
        require(block.timestamp >= election.startTime, "Election has not started");
        require(block.timestamp <= election.endTime, "Election has ended");
        _;
    }
    
    modifier onlyRegisteredVoter(uint256 _electionId) {
        Election storage election = elections[_electionId];
        require(election.voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    // ============ CONSTRUCTOR ============
    
    constructor() {
        owner = msg.sender;
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    function createElection(
        string memory _title,
        string memory _description,
        uint256 _durationInMinutes,
        string[] memory _candidateNames,
        string[] memory _candidateDescriptions
    ) external onlyOwner returns (uint256) {
        require(_candidateNames.length == _candidateDescriptions.length, "Arrays length mismatch");
        require(_candidateNames.length >= 2, "At least 2 candidates required");
        
        uint256 electionId = electionCount;
        Election storage election = elections[electionId];
        
        election.title = _title;
        election.description = _description;
        election.creator = msg.sender;
        election.startTime = block.timestamp;
        election.endTime = block.timestamp + (_durationInMinutes * 1 minutes);
        election.isActive = true;
        election.isPaused = false;
        
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            election.candidates.push(Candidate({
                name: _candidateNames[i],
                description: _candidateDescriptions[i],
                voteCount: 0,
                exists: true
            }));
        }
        
        electionCount++;
        
        emit ElectionCreated(electionId, _title, msg.sender, election.startTime, election.endTime);
        
        return electionId;
    }
    
    function registerVoters(
        uint256 _electionId,
        address[] memory _voters,
        uint256[] memory _weights
    ) external onlyOwner electionExists(_electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election must be active");
        // Allow voter registration during the election window.
        // Previously this required `block.timestamp < election.startTime`, but `startTime`
        // is set to `block.timestamp` at `createElection()`, which makes registration
        // revert almost immediately after creation.
        require(block.timestamp <= election.endTime, "Election already ended");
        require(_voters.length == _weights.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < _voters.length; i++) {
            address voter = _voters[i];
            require(!election.voters[voter].isRegistered, "Voter already registered");
            
            election.voters[voter] = Voter({
                isRegistered: true,
                hasVoted: false,
                weight: _weights[i],
                votedForCandidateId: 0,
                votedAt: 0
            });
            
            election.registeredVoters.push(voter);
            
            emit VoterRegistered(_electionId, voter, _weights[i]);
        }
    }
    
    function endElection(uint256 _electionId) external onlyOwner electionExists(_electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election already ended");
        
        election.isActive = false;
        
        emit ElectionEnded(_electionId, election.totalVotes, election.totalWeightedVotes);
    }
    
    function pauseElection(uint256 _electionId) external onlyOwner electionExists(_electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election not active");
        require(!election.isPaused, "Already paused");
        
        election.isPaused = true;
        
        emit ElectionPaused(_electionId);
    }
    
    function unpauseElection(uint256 _electionId) external onlyOwner electionExists(_electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election not active");
        require(election.isPaused, "Not paused");
        
        election.isPaused = false;
        
        emit ElectionUnpaused(_electionId);
    }
    
    function extendElection(
        uint256 _electionId,
        uint256 _extraMinutes
    ) external onlyOwner electionExists(_electionId) {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election not active");
        
        election.endTime += (_extraMinutes * 1 minutes);
        
        emit ElectionExtended(_electionId, election.endTime);
    }
    
    // ============ VOTING FUNCTIONS ============
    
    function vote(
        uint256 _electionId,
        uint256 _candidateId
    ) external electionExists(_electionId) electionActive(_electionId) onlyRegisteredVoter(_electionId) {
        Election storage election = elections[_electionId];
        Voter storage voter = election.voters[msg.sender];
        
        require(!voter.hasVoted, "Already voted");
        require(_candidateId < election.candidates.length, "Invalid candidate");
        
        voter.hasVoted = true;
        voter.votedForCandidateId = _candidateId;
        voter.votedAt = block.timestamp;
        
        election.candidates[_candidateId].voteCount += voter.weight;
        election.totalVotes++;
        election.totalWeightedVotes += voter.weight;
        
        voterHistory[_electionId][msg.sender] = true;
        
        emit Voted(
            _electionId,
            msg.sender,
            _candidateId,
            election.candidates[_candidateId].name,
            voter.weight
        );
    }
    
    // ============ VIEW FUNCTIONS ============
    
    function getElectionInfo(uint256 _electionId) external view electionExists(_electionId) returns (
        string memory title,
        string memory description,
        address creator,
        uint256 startTime,
        uint256 endTime,
        bool isActive,
        bool isPaused,
        uint256 totalVotes,
        uint256 totalWeightedVotes,
        uint256 candidateCount,
        uint256 registeredVoterCount
    ) {
        Election storage election = elections[_electionId];
        return (
            election.title,
            election.description,
            election.creator,
            election.startTime,
            election.endTime,
            election.isActive,
            election.isPaused,
            election.totalVotes,
            election.totalWeightedVotes,
            election.candidates.length,
            election.registeredVoters.length
        );
    }
    
    function getCandidate(uint256 _electionId, uint256 _candidateId) external view electionExists(_electionId) returns (
        string memory name,
        string memory description,
        uint256 voteCount
    ) {
        Election storage election = elections[_electionId];
        require(_candidateId < election.candidates.length, "Invalid candidate");
        
        Candidate storage candidate = election.candidates[_candidateId];
        return (candidate.name, candidate.description, candidate.voteCount);
    }
    
    function getAllCandidates(uint256 _electionId) external view electionExists(_electionId) returns (
        string[] memory names,
        string[] memory descriptions,
        uint256[] memory voteCounts
    ) {
        Election storage election = elections[_electionId];
        uint256 length = election.candidates.length;
        
        names = new string[](length);
        descriptions = new string[](length);
        voteCounts = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            names[i] = election.candidates[i].name;
            descriptions[i] = election.candidates[i].description;
            voteCounts[i] = election.candidates[i].voteCount;
        }
    }
    
    function getVoterInfo(uint256 _electionId, address _voter) external view electionExists(_electionId) returns (
        bool registered,
        bool voted,
        uint256 weight,
        uint256 votedForCandidateId,
        uint256 votedAt
    ) {
        Election storage election = elections[_electionId];
        Voter storage voter = election.voters[_voter];
        
        return (
            voter.isRegistered,
            voter.hasVoted,
            voter.weight,
            voter.votedForCandidateId,
            voter.votedAt
        );
    }
    
    function getRegisteredVoters(uint256 _electionId) external view electionExists(_electionId) returns (
        address[] memory voters,
        uint256[] memory weights
    ) {
        Election storage election = elections[_electionId];
        uint256 length = election.registeredVoters.length;
        
        voters = new address[](length);
        weights = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            address voterAddr = election.registeredVoters[i];
            voters[i] = voterAddr;
            weights[i] = election.voters[voterAddr].weight;
        }
    }
    
    function checkHasVoted(uint256 _electionId, address _voter) external view electionExists(_electionId) returns (bool) {
        return elections[_electionId].voters[_voter].hasVoted;
    }
    
    function isVoterRegistered(uint256 _electionId, address _voter) external view electionExists(_electionId) returns (bool) {
        return elections[_electionId].voters[_voter].isRegistered;
    }
    
    function getElectionWinner(uint256 _electionId) external view electionExists(_electionId) returns (
        uint256 candidateId,
        string memory name,
        uint256 voteCount
    ) {
        Election storage election = elections[_electionId];
        require(!election.isActive, "Election still active");
        
        uint256 winningId = 0;
        uint256 winningVotes = 0;
        
        for (uint256 i = 0; i < election.candidates.length; i++) {
            if (election.candidates[i].voteCount > winningVotes) {
                winningVotes = election.candidates[i].voteCount;
                winningId = i;
            }
        }
        
        return (
            winningId,
            election.candidates[winningId].name,
            winningVotes
        );
    }
}