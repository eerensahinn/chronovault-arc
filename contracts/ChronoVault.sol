// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ChronoVault - Arc Testnet uzerinde zaman kilitli mesaj kapsulu
/// @notice Herkes bir mesaj birakabilir (herkese acik ya da tek bir alici icin ozel),
///         mesaj yalnizca belirlenen tarih geldiginde okunabilir hale gelir.
///         Ayrica katkiya dayali basari rozetleri kazanilir.
contract ChronoVault {
    struct Capsule {
        address creator;
        address recipient; // address(0) ise herkese acik kapsul
        string message;
        uint256 unlockTime;
        uint256 createdAt;
    }

    Capsule[] private capsules;

    mapping(address => uint256) public capsuleCount;
    // badgeEarned[kullanici][badgeId] => kazanildi mi
    mapping(address => mapping(uint8 => bool)) public badgeEarned;

    uint8 public constant BADGE_FIRST_CAPSULE = 0;
    uint8 public constant BADGE_DECADE_VAULT = 1;
    uint8 public constant BADGE_TIME_TRAVELER = 2;
    uint8 public constant BADGE_FOUNDING_MEMBER = 3;

    uint256 public constant DECADE_THRESHOLD = 10;
    uint256 public constant TIME_TRAVELER_SECONDS = 365 days;
    uint256 public constant FOUNDING_MEMBER_LIMIT = 20;

    event CapsuleCreated(uint256 indexed id, address indexed creator, address indexed recipient, uint256 unlockTime);
    event BadgeEarned(address indexed user, uint8 badgeId);

    /// @notice Yeni bir zaman kapsulu olustur
    /// @param message Kapsule konulacak mesaj (1-500 karakter)
    /// @param unlockTime Kapsulun acilacagi unix zaman damgasi (gelecekte olmali)
    /// @param recipient Ozel kapsul icin alici adresi, herkese acik kapsul icin address(0)
    function createCapsule(string calldata message, uint256 unlockTime, address recipient) external {
        require(unlockTime > block.timestamp, "Acilma tarihi gelecekte olmali");
        require(bytes(message).length > 0, "Mesaj bos olamaz");
        require(bytes(message).length <= 500, "Mesaj en fazla 500 karakter olabilir");

        uint256 newId = capsules.length;

        if (newId < FOUNDING_MEMBER_LIMIT) {
            _awardBadge(msg.sender, BADGE_FOUNDING_MEMBER);
        }

        capsules.push(Capsule({
            creator: msg.sender,
            recipient: recipient,
            message: message,
            unlockTime: unlockTime,
            createdAt: block.timestamp
        }));

        capsuleCount[msg.sender] += 1;

        _awardBadge(msg.sender, BADGE_FIRST_CAPSULE);

        if (capsuleCount[msg.sender] >= DECADE_THRESHOLD) {
            _awardBadge(msg.sender, BADGE_DECADE_VAULT);
        }

        if (unlockTime - block.timestamp >= TIME_TRAVELER_SECONDS) {
            _awardBadge(msg.sender, BADGE_TIME_TRAVELER);
        }

        emit CapsuleCreated(newId, msg.sender, recipient, unlockTime);
    }

    function _awardBadge(address user, uint8 badgeId) internal {
        if (!badgeEarned[user][badgeId]) {
            badgeEarned[user][badgeId] = true;
            emit BadgeEarned(user, badgeId);
        }
    }

    /// @notice Toplam kapsul sayisi
    function totalCapsules() external view returns (uint256) {
        return capsules.length;
    }

    /// @notice Bir kapsulun herkese acik meta verisi (mesaj icerigi HARIC)
    function getCapsuleInfo(uint256 id) external view returns (
        address creator,
        address recipient,
        uint256 unlockTime,
        uint256 createdAt,
        bool isUnlocked,
        bool isPrivate
    ) {
        Capsule storage c = capsules[id];
        return (
            c.creator,
            c.recipient,
            c.unlockTime,
            c.createdAt,
            block.timestamp >= c.unlockTime,
            c.recipient != address(0)
        );
    }

    /// @notice Mesaj icerigini dondurur - acilma zamani gelmis olmali,
    ///         ozel kapsullerde ayrica cagiran kisi gonderen ya da alici olmali
    function getMessage(uint256 id) external view returns (string memory) {
        Capsule storage c = capsules[id];
        require(block.timestamp >= c.unlockTime, "Bu kapsul henuz acilmadi");

        if (c.recipient != address(0)) {
            require(
                msg.sender == c.recipient || msg.sender == c.creator,
                "Bu ozel kapsulu okuma yetkin yok"
            );
        }

        return c.message;
    }

    /// @notice Bir kullanicinin kazandigi rozetleri dondurur
    ///         [firstCapsule, decadeVault, timeTraveler, foundingMember]
    function getBadges(address user) external view returns (bool[4] memory) {
        return [
            badgeEarned[user][BADGE_FIRST_CAPSULE],
            badgeEarned[user][BADGE_DECADE_VAULT],
            badgeEarned[user][BADGE_TIME_TRAVELER],
            badgeEarned[user][BADGE_FOUNDING_MEMBER]
        ];
    }
}
