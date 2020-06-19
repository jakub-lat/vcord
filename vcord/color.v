module vcord

type Color int

pub fn parse_color(i int) Color {
	return Color(i)
}