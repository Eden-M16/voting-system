# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-03-26

### Added
- Weighted voting system (voters have different weights 1-10)
- Voter registration before elections
- Election controls: pause, unpause, extend, end
- Candidate descriptions/party information
- Winner announcement after election ends
- Registration status display for voters
- Paused status indicator in UI
- Admin controls panel with all management features

### Changed
- Updated contract ABI with 8 new functions
- Enhanced frontend with 5 new tabs
- Improved error handling and loading states
- Better mobile responsiveness

### Fixed
- Naming conflict in hasVoted function (renamed to checkHasVoted)
- Timeout issues during deployment
- Network detection improvements

## [1.0.0] - 2026-03-25

### Added
- Basic voting functionality
- Create elections with candidates
- Real-time vote counting
- MetaMask wallet integration
- GitHub Pages deployment
- Statistics dashboard
- Toast notifications
- Vote confirmation modal