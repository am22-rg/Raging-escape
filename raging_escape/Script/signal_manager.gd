extends Node
#region Signals
# Signal for corruption
signal corruption_sig

# Emits when the enemy dies
signal died

# Naviation signals
signal to_menu
signal reset

# Sent out to pause and play the game
signal pause_game
signal play_game

# Sent when the player completes a level
signal level_complete
#endregion

#region Varibles
var current_level
#endregion
