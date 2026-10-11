## 1. Vehicle domain model

- [ ] 1.1 Add stable `VehicleId`/`VehicleTierId` types and data-driven vehicle/tier definitions for WEIKU C→B→A; verify lookups resolve family card, SeedType, previous/next tier, default tier and maximum tier without C/B/A-specific branches.
- [ ] 1.2 Add shared queries for card cost, refresh time, projectile damage, preview image, attribute text, bar ranges and displayed upgrade cost; verify garage-facing values resolve to cost 100, damage 20/40/60 and the existing WEIKU cooldown source.
- [ ] 1.3 Add a pure vehicle placement resolver with results for empty placement, next-tier upgrade, locked tier, current maximum and invalid target; verify table-driven checks cover empty→C, C→B, B→A, locked B/A, A-at-max and unrelated plants.

## 2. Profile migration and currency

- [ ] 2.1 Add bounded per-vehicle progress records and helpers to `PlayerInfo`, initialize WEIKU to C on reset/new profile, and verify unknown vehicle/tier IDs safely fall back without out-of-bounds access.
- [ ] 2.2 Upgrade profile serialization from version 12 to 13 with conditional tail records and a one-time pre-migration backup; verify a copied real v12 profile loads with its existing level, purchases, coins and other fields intact, then reloads after being saved as v13.
- [ ] 2.3 Remove the successful-read coin overwrite, centralize the display/internal ×10 conversion, and raise the stored coin cap consistently with the 10,000,000 displayed initial balance; verify save/reload preserves balances and `AddCoins` no longer truncates a high balance to 99,999.
- [ ] 2.4 Implement the sequential vehicle-upgrade transaction and immediate profile save; verify displayed balances 499,990/500,000/500,010 produce respectively rejected/successful/successful C→B outcomes with exactly 500,000 deducted only on success.
- [ ] 2.5 Verify C→B→A requires two separate confirmed transactions, rejects a repeated transaction at A, and survives process restart with both tier and remaining coin balance unchanged.

## 3. Garage resources and interface

- [ ] 3.1 Register garage dialog/button resources, ASCII-safe LawnStrings keys, and one lightweight preview image per WEIKU tier (initially reusable from `idle_00`); verify every manifest ID resolves from `assets/extension` without inheriting an incorrect default path.
- [ ] 3.2 Implement `GarageDialog` lifecycle and the 800×600 layout with left-top rank/attributes, central preview, left-bottom stat bars, right-side tier path, cute description and right-bottom modification area; verify C, B and A definitions render without clipping or loading all three full animations at once.
- [ ] 3.3 Add `DIALOG_GARAGE` plus `LawnApp` open/close methods and a main-selector garage button with correct add/remove/order/disable handling; verify opening and closing repeatedly returns to an interactive main menu with music restored and does not overlap existing Store/Almanac/Zen Garden hit areas.
- [ ] 3.4 Connect garage state to profile progress so C is the initial presentation, path nodes distinguish unlocked/current/locked, and successful upgrades immediately refresh preview, properties, stats and next-tier state; verify the UI transitions C→B→A without reopening the dialog.
- [ ] 3.5 Add confirmation, insufficient-funds and maximum-tier flows with double-click protection; verify canceled, invalid and repeated clicks never deduct coins or advance progress.
- [ ] 3.6 Verify the non-wide-character build displays safe fallback labels such as `GARAGE` and `Cute and cool!` without a `wcstombs` assertion; record Chinese typography as a separate future font/localization task.

## 4. Single-card chooser behavior

- [ ] 4.1 Change the public WEIKU family card (`SEED_WEIKU_C`) to 100 sun and the family display name/icon, while keeping B/A entity definitions and all existing enum values; verify card drawing, tooltip, cost and resource preload use the single family identity.
- [ ] 4.2 Update normal chooser membership and layout so only one WEIKU card appears and occupies one extra slot; verify WEIKU_B/A no longer appear as selectable cards and unrelated special SeedTypes remain excluded.
- [ ] 4.3 Update availability and seed-bank setup paths to expose only the family card without disabling restoration of existing B/A entities; verify a new normal level starts with one selected WEIKU packet.

## 5. In-battle stacked upgrades

- [ ] 5.1 Integrate the shared placement resolver into `Board::CanPlantAt`, cursor highlighting and failure advice without adding WEIKU to the original purple-card `Plant::IsUpgrade` list; verify empty placement and eligible same-family targets highlight consistently while locked/max/unrelated targets do not.
- [ ] 5.2 Update the planting commit path to resolve the output SeedType before charging, create C on empty ground, and replace C→B or B→A on valid stacking while preserving legal support/pumpkin layers; verify every successful action costs exactly 100 sun and triggers the one family packet cooldown.
- [ ] 5.3 Ensure all rejected stacking paths return before sun deduction, entity destruction and `WasPlanted()`; verify locked B, locked A, current maximum and unrelated-plant attempts preserve sun, cooldown, target health/state and target SeedType.
- [ ] 5.4 Preserve tier-specific combat after replacement; verify C/B/A still play their own idle/shoot/fly animations, fire at the configured frame and deal 20/40/60 damage respectively.
- [ ] 5.5 Normalize legacy saved WEIKU_B/A seed packets to the family C packet while retaining compatible refresh progress, without changing on-board B/A plants; verify a copied pre-change battle save resumes with the old entity tier and the new single-card rules.
- [ ] 5.6 Exercise the resolver with a temporary appended test tier after A (without shipping S assets) and verify next-tier/path/maximum logic advances generically, then remove the temporary test fixture.

## 6. Integration validation and documentation

- [ ] 6.1 Run all affected WEIKU resource synchronization scripts if their generated resources change, then verify generated headers, `.reanim`, manifest blocks and variant-specific cache removal remain correct.
- [ ] 6.2 Build `DebugGOTY|x64` with the documented MSBuild v145 command and temporary `/source-charset:.1252`; verify the build exits successfully without changing project toolset files or source encodings.
- [ ] 6.3 Launch from `build/DebugGOTY_x64/bin` and verify no dependency, Fatal Error or assertion dialog appears; process survival alone is not sufficient evidence.
- [ ] 6.4 Manually verify the complete new-profile flow: garage starts at C, each 500,000 modification unlocks exactly one tier, restart preserves coins/tier, chooser has one 100-sun card, and field placement progresses C→B→A with two same-card stacks.
- [ ] 6.5 Manually verify failure and compatibility flows: insufficient garage funds, stacking above unlock, stacking at maximum, unrelated occupied cell, v12 profile migration, old WEIKU_B/A field entities and old B/A seed packets all match the specs without data loss.
- [ ] 6.6 Measure process memory while entering the garage and cycling C/B/A after a cold start; verify the garage does not instantiate all three full Reanimation sets solely for previews and record the observed delta.
- [ ] 6.7 Update `AGENTS.md`, `PVZ_MOD_MAP.md` and the new-plant documentation only after successful in-game verification, recording the final garage/progression/save/stacking route and any deviations from this design.
- [ ] 6.8 Run `openspec validate add-weiku-garage-upgrade-system --strict` and `git diff --check`; verify the change artifacts and implementation diff pass before handoff.
