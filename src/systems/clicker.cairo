// Clicker game system with bonus mechanics
// On-chain clicker game with time-based bonuses and leveling
#[starknet::interface]
pub trait IClicker<T> {
    fn click(ref self: T);
    fn buy_upgrade(ref self: T);
    fn claim_bonus(ref self: T);
}

#[dojo::contract]
pub mod clicker {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use unity_clicker_v2::models::ClickerScore;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClickerClicked {
        #[key]
        pub player: ContractAddress,
        pub points_earned: u256,
        pub total_points: u256,
        pub current_level: u64,
        pub multiplier_used: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClickerUpgraded {
        #[key]
        pub player: ContractAddress,
        pub new_click_power: u64,
        pub new_level: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct BonusClaimed {
        #[key]
        pub player: ContractAddress,
        pub bonus_amount: u256,
        pub new_total_points: u256,
    }

    #[abi(embed_v0)]
    impl ClickerImpl of super::IClicker<ContractState> {
        fn click(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
            let timestamp = get_block_timestamp();

            // Get or create player score
            let mut score: ClickerScore = world.read_model(player);
            
            // Initialize if new player
            if score.click_power == 0 {
                score.click_power = 1;
                score.multiplier = 1;
                score.level = 1;
            }

            // Calculate points with multiplier
            let multiplied_value = score.click_power * score.multiplier;
            let multiplied_points = u256 { low: multiplied_value.into(), high: 0 };
            score.points += multiplied_points;
            score.total_clicks += 1;
            score.last_click_time = timestamp;

            // Update level based on total points (level up every 1000 points)
            let new_level_u128 = (score.points.low / 1000) + 1;
            let new_level = new_level_u128.try_into().unwrap();
            if new_level > score.level {
                score.level = new_level;
            }

            // Write updated score
            world.write_model(@score);

            // Emit event
            world.emit_event(@ClickerClicked {
                player,
                points_earned: multiplied_points,
                total_points: score.points,
                current_level: score.level,
                multiplier_used: score.multiplier,
            });
        }

        fn buy_upgrade(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let mut score: ClickerScore = world.read_model(player);

            // Cost: 100 points per upgrade level, scales with current click power
            let base_cost = (score.click_power * 100).into();
            let upgrade_cost = base_cost;
            
            // Check if player has enough points
            if score.points < upgrade_cost {
                return;
            }

            // Deduct cost and upgrade click power
            score.points -= upgrade_cost;
            score.click_power += 1;

            // Increase multiplier every 5 levels
            if score.click_power % 5 == 0 {
                score.multiplier += 1;
            }

            // Update level if needed
            let new_level_u128 = (score.points.low / 1000) + 1;
            let new_level = new_level_u128.try_into().unwrap();
            if new_level > score.level {
                score.level = new_level;
            }

            // Write updated score back to world
            world.write_model(@score);

            // Emit upgrade event
            world.emit_event(@ClickerUpgraded {
                player,
                new_click_power: score.click_power,
                new_level: score.level,
            });
        }

        fn claim_bonus(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
            let timestamp = get_block_timestamp();

            let mut score: ClickerScore = world.read_model(player);

            // Calculate bonus based on time since last click
            // Bonus: 1 point per second since last click, capped at 3600 (1 hour)
            let time_diff = timestamp - score.last_click_time;
            let bonus_seconds = if time_diff > 3600 { 3600 } else { time_diff };
            let bonus_amount = u256 { low: bonus_seconds.into(), high: 0 };

            // Only give bonus if at least 60 seconds have passed
            if time_diff < 60 {
                return;
            }

            // Add bonus to points and bonus_points tracker
            score.points += bonus_amount;
            score.bonus_points += bonus_amount;
            score.last_click_time = timestamp;

            // Update level if needed
            let new_level_u128 = (score.points.low / 1000) + 1;
            let new_level = new_level_u128.try_into().unwrap();
            if new_level > score.level {
                score.level = new_level;
            }

            // Write updated score
            world.write_model(@score);

            // Emit bonus event
            world.emit_event(@BonusClaimed {
                player,
                bonus_amount,
                new_total_points: score.points,
            });
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"clickerv2")
        }
    }
}

