// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VoteChain {
    address public owner;
    uint256 public electionCount;
    
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
    }
    
    struct Candidate {
        string name;
        string description;
        uint256 voteCount;
    }
    
    struct Voter {
        bool registered;
        bool voted;
        uint256 weight;
        uint256 votedForCandidateId;
        uint256 votedAt;
    }
    
    mapping(uint256 => Election) public elections;
    mapping(uint256 => Candidate[]) public candidates;
    mapping(uint256 => mapping(address => Voter)) public voterInfo;
    mapping(uint256 => address[]) public registeredVotersList;
    mapping(uint256 => mapping(address => bool)) public voterHistory;
    
    // Events
    event ElectionCreated(
        uint256 indexed electionId,
        string title,
        address indexed creator,
        uint256 startTime,
        uint256 endTime
    );
    
    event ElectionPaused(uint256 indexed electionId);
    event ElectionUnpaused(uint256 indexed electionId);
    event ElectionExtended(uint256 indexed electionId, uint256 newEndTime);
    event ElectionEnded(
        uint256 indexed electionId,
        uint256 totalVotes,
        uint256 totalWeightedVotes
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
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // Create a new election
    function createElection(
        string memory _title,
        string memory _description,
        uint256 _durationInMinutes,
        string[] memory _candidateNames,
        string[] memory _candidateDescriptions
    ) external onlyOwner returns (uint256) {
        require(_candidateNames.length >= 2, "Need at least 2 candidates");
        require(_candidateNames.length == _candidateDescriptions.length, "Names and descriptions length mismatch");
        
        uint256 electionId = electionCount++;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + (_durationInMinutes * 1 minutes);
        
        elections[electionId] = Election({
            title: _title,
            description: _description,
            creator: msg.sender,
            startTime: startTime,
            endTime: endTime,
            isActive: true,
            isPaused: false,
            totalVotes: 0,
            totalWeightedVotes: 0
        });
        
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            candidates[electionId].push(Candidate({
                name: _candidateNames[i],
                description: _candidateDescriptions[i],
                voteCount: 0
            }));
        }
        
        emit ElectionCreated(electionId, _title, msg.sender, startTime, endTime);
        
        return electionId;
    }
    
    // Register voters with weights for a specific election
    function registerVoters(
        uint256 _electionId,
        address[] memory _voters,
        uint256[] memory _weights
    ) external onlyOwner {
        require(_electionId < electionCount, "Election does not exist");
        require(elections[_electionId].isActive, "Election is not active");
        require(_voters.length == _weights.length, "Voters and weights length mismatch");
        require(_voters.length > 0, "No voters provided");
        
        for (uint256 i = 0; i < _voters.length; i++) {
            address voterAddr = _voters[i];
            uint256 weight = _weights[i];
            
            require(weight > 0 && weight <= 10, "Weight must be between 1 and 10");
            require(!voterInfo[_electionId][voterAddr].registered, "Voter already registered");
            
            voterInfo[_electionId][voterAddr] = Voter({
                registered: true,
                voted: false,
                weight: weight,
                votedForCandidateId: 0,
                votedAt: 0
            });
            
            registeredVotersList[_electionId].push(voterAddr);
            
            emit VoterRegistered(_electionId, voterAddr, weight);
        }
    }
    
    // Vote in an election
    function vote(uint256 _electionId, uint256 _candidateId) external {
        require(_electionId < electionCount, "Election does not exist");
        
        Election storage election = elections[_electionId];
        require(election.isActive, "Election is not active");
        require(!election.isPaused, "Election is paused");
        require(block.timestamp < election.endTime, "Election has ended");
        
        Voter storage voter = voterInfo[_electionId][msg.sender];
        require(voter.registered, "Voter is not registered");
        require(!voter.voted, "Already voted");
        require(_candidateId < candidates[_electionId].length, "Invalid candidate");
        
        voter.voted = true;
        voter.votedForCandidateId = _candidateId;
        voter.votedAt = block.timestamp;
        voterHistory[_electionId][msg.sender] = true;
        
        uint256 weight = voter.weight;
        candidates[_electionId][_candidateId].voteCount += weight;
        election.totalVotes++;
        election.totalWeightedVotes += weight;
        
        emit Voted(
            _electionId,
            msg.sender,
            _candidateId,
            candidates[_electionId][_candidateId].name,
            weight
        );
    }
    
    // Pause an election
    function pauseElection(uint256 _electionId) external onlyOwner {
        require(_electionId < electionCount, "Election does not exist");
        require(elections[_electionId].isActive, "Election is not active");
        require(!elections[_electionId].isPaused, "Election is already paused");
        
        elections[_electionId].isPaused = true;
        
        emit ElectionPaused(_electionId);
    }
    
    // Unpause an election
    function unpauseElection(uint256 _electionId) external onlyOwner {
        require(_electionId < electionCount, "Election does not exist");
        require(elections[_electionId].isActive, "Election is not active");
        require(elections[_electionId].isPaused, "Election is not paused");
        
        elections[_electionId].isPaused = false;
        
        emit ElectionUnpaused(_electionId);
    }
    
    // Extend election duration
    function extendElection(uint256 _electionId, uint256 _extraMinutes) external onlyOwner {
        require(_electionId < electionCount, "Election does not exist");
        require(elections[_electionId].isActive, "Election is not active");
        require(_extraMinutes > 0, "Extra minutes must be greater than 0");
        
        elections[_electionId].endTime += (_extraMinutes * 1 minutes);
        
        emit ElectionExtended(_electionId, elections[_electionId].endTime);
    }
    
    // End an election early
    function endElection(uint256 _electionId) external onlyOwner {
        require(_electionId < electionCount, "Election does not exist");
        require(elections[_electionId].isActive, "Election is already ended");
        
        elections[_electionId].isActive = false;
        
        emit ElectionEnded(
            _electionId,
            elections[_electionId].totalVotes,
            elections[_electionId].totalWeightedVotes
        );
    }
    
    // View functions
    
    function getElectionInfo(uint256 _electionId) external view returns (
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
        require(_electionId < electionCount, "Election does not exist");
        Election storage e = elections[_electionId];
        return (
            e.title,
            e.description,
            e.creator,
            e.startTime,
            e.endTime,
            e.isActive,
            e.isPaused,
            e.totalVotes,
            e.totalWeightedVotes,
            candidates[_electionId].length,
            registeredVotersList[_electionId].length
        );
    }
    
    function getAllCandidates(uint256 _electionId) external view returns (
        string[] memory names,
        string[] memory descriptions,
        uint256[] memory voteCounts
    ) {
        require(_electionId < electionCount, "Election does not exist");
        Candidate[] storage cands = candidates[_electionId];
        uint256 len = cands.length;
        
        names = new string[](len);
        descriptions = new string[](len);
        voteCounts = new uint256[](len);
        
        for (uint256 i = 0; i < len; i++) {
            names[i] = cands[i].name;
            descriptions[i] = cands[i].description;
            voteCounts[i] = cands[i].voteCount;
        }
        
        return (names, descriptions, voteCounts);
    }
    
    function getCandidate(uint256 _electionId, uint256 _candidateId) external view returns (
        string memory name,
        string memory description,
        uint256 voteCount
    ) {
        require(_electionId < electionCount, "Election does not exist");
        require(_candidateId < candidates[_electionId].length, "Invalid candidate");
        Candidate storage c = candidates[_electionId][_candidateId];
        return (c.name, c.description, c.voteCount);
    }
    
    function getRegisteredVoters(uint256 _electionId) external view returns (
        address[] memory voters,
        uint256[] memory weights
    ) {
        require(_electionId < electionCount, "Election does not exist");
        uint256 len = registeredVotersList[_electionId].length;
        
        voters = new address[](len);
        weights = new uint256[](len);
        
        for (uint256 i = 0; i < len; i++) {
            address voterAddr = registeredVotersList[_electionId][i];
            voters[i] = voterAddr;
            weights[i] = voterInfo[_electionId][voterAddr].weight;
        }
        
        return (voters, weights);
    }
    
    function getVoterInfo(uint256 _electionId, address _voter) external view returns (
        bool registered,
        bool voted,
        uint256 weight,
        uint256 votedForCandidateId,
        uint256 votedAt
    ) {
        require(_electionId < electionCount, "Election does not exist");
        Voter storage v = voterInfo[_electionId][_voter];
        return (v.registered, v.voted, v.weight, v.votedForCandidateId, v.votedAt);
    }
    
    function isVoterRegistered(uint256 _electionId, address _voter) external view returns (bool) {
        require(_electionId < electionCount, "Election does not exist");
        return voterInfo[_electionId][_voter].registered;
    }
    
    function checkHasVoted(uint256 _electionId, address _voter) external view returns (bool) {
        require(_electionId < electionCount, "Election does not exist");
        return voterInfo[_electionId][_voter].voted;
    }
    
    function getElectionWinner(uint256 _electionId) external view returns (
        uint256 candidateId,
        string memory name,
        uint256 voteCount
    ) {
        require(_electionId < electionCount, "Election does not exist");
        require(!elections[_electionId].isActive, "Election is still active");
        
        Candidate[] storage cands = candidates[_electionId];
        require(cands.length > 0, "No candidates");
        
        uint256 winningId = 0;
        uint256 maxVotes = cands[0].voteCount;
        
        for (uint256 i = 1; i < cands.length; i++) {
            if (cands[i].voteCount > maxVotes) {
                maxVotes = cands[i].voteCount;
                winningId = i;
            }
        }
        
        return (winningId, cands[winningId].name, cands[winningId].voteCount);
    }
    
    // Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}