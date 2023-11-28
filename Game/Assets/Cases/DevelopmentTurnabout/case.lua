local case = {}

case.name = "Development Turnabout"
case.description = ""
case.author = "TheLife"

-- TODO: Create a general function for adding/creating characters.
case.characters = {
    { -- 1 - Phoenix
        ["name"] = "Phoenix Wright",
        ["displayname"] = "Phoenix",
        ["blip"] = "male",
        ["speaker"] = "Phoenix",
        ["character"] = "Phoenix",
    }
}

local PHOENIX = 1

case.scripts = {}
case.scripts["intro"] = {
    {PHOENIX, "Hello world. This is a ", utils.Color(255,0,0), "Red", utils.Color(255,255,255), " text."},
    {PHOENIX, "And this is ", utils.Color(0,0,255), "blue...", {"flash", utils.Color(255,255,255)}, " with a flash and...", {"delay", 1}, " delay."}
}