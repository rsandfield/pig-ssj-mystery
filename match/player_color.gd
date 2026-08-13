class_name PlayerColor

enum Type {
	RED,
	ORANGE,
	YELLOW,
	GREEN,
	BLUE,
	VIOLET,
	PINK,
	BROWN,
	GRAY,
	LIME,
	MAROON,
	OLIVE,
	LAVANDER,
}

static func to_color(player_color: Type) -> Color:
	match player_color:
		Type.RED:
			return Color.RED
		Type.ORANGE:
			return Color.ORANGE
		Type.YELLOW:
			return Color.YELLOW
		Type.GREEN:
			return Color.GREEN
		Type.BLUE:
			return Color.BLUE
		Type.VIOLET:
			return Color.VIOLET
		Type.PINK:
			return Color.PINK
		Type.BROWN:
			return Color.BROWN
		Type.GRAY:
			return Color.GRAY
		Type.LIME:
			return Color.LIME
		Type.MAROON:
			return Color.MAROON
		Type.OLIVE:
			return Color.OLIVE
		Type.LAVANDER:
			return Color.LAVENDER
		_:
			return Color.WHITE


static func to_name(player_color: Type) -> String:
	return Type.keys()[player_color].capitalize()


static func from_string(text: String) -> Type:
	return Type.get(text.to_upper())
