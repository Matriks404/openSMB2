local story = {}

function story.load()
	story.lines = 0
	story.page = 0

	story.page1 = { "WHEN  MARIO OPENED A",
	           "DOOR AFTER  CLIMBING",
	           "A LONG STAIR IN  HIS",
	           "DREAM, ANOTHER WORLD",
	           "SPREAD   BEFORE  HIM",
	           "AND HE HEARD A VOICE",
	           "CALL FOR HELP TO  BE",
	           " FREED  FROM A SPELL"
	         }

	story.page2 = { "AFTER  AWAKENING,   ",
	           "MARIO  WENT TO  A   ",
	           "CAVE  NEARBY AND  TO",
	           "HIS  SURPRISE HE SAW",
	           "EXACTLY  WHAT HE SAW",
	           "IN HIS DREAM***     ",
	           "                    ",
	           "  PUSH START BUTTON "
	         }
end

return story