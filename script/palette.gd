class_name Palette


# colors
const RED: Color = Color("#e54461")
const LIGHT_RED: Color = Color("#ed5646")

const ORANGE: Color = Color("#ff8919")
const LIGHT_ORANGE: Color = Color("#f4a233")

const BLUE: Color = Color("#5774d4")
const LIGHT_BLUE: Color = Color("#4d89a6")

const GREEN: Color = Color("#83c250")
const LIGHT_GREEN: Color = Color("#5fcd73")

const PURPLE: Color = Color("#9372c2")
const LIGHT_PURPLE: Color = Color("#807bd2")

const WHITE: Color = Color("#9993a3")
const BLACK: Color = Color("#17131b")

# ui
const TEXT_NORMAL: Color = WHITE
const TEXT_MUTED: Color = Color("#464757")

const PANEL_0: Color = BLACK
const PANEL_1: Color = Color("#22161e")
const PANEL_2: Color = Color("#2d1a22")


static func light(color: Color) -> Color:
	match color:
		RED: return LIGHT_RED
		ORANGE: return LIGHT_ORANGE
		GREEN: return LIGHT_GREEN
		BLUE: return LIGHT_BLUE
		PURPLE: return LIGHT_PURPLE
		_: return Color.WHITE
