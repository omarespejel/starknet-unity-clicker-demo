use starknet::ContractAddress;

// Simple clicker game models
// Models for the on-chain clicker game

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ClickerScore {
    #[key]
    pub player: ContractAddress,
    pub points: u256,
    pub total_clicks: u64,
    pub click_power: u64, // Base points earned per click
    pub last_click_time: u64,
    pub multiplier: u64, // Click multiplier for upgrades
    pub bonus_points: u256, // Accumulated bonus points
    pub level: u64, // Player level based on total points
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Leaderboard {
    #[key]
    pub player: ContractAddress,
    pub rank: u64,
    pub score: u256,
    pub level: u64, // Player level for leaderboard ranking
    pub last_updated: u64, // Timestamp of last update
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_basic() {
        assert(1 == 1, 'basic test');
    }
}
