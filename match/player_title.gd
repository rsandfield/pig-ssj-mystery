class_name PlayerTitle

enum Type {
	MR,
	MS,
	MRS,
	MX,
	DR,
	PROF,
	REV,
	SIR,
	DAME,
	LORD,
	LADY,
	PVT,
	SGT,
	LT,
	CAPT,
	MAJ,
	COL,
}

const BASIC: Array[Type] = [Type.MR, Type.MS, Type.MRS, Type.MX]


static func to_name(t: Type) -> String:
	return Type.keys()[t].capitalize()


static func from_string(text: String) -> Type:
	return Type.get(text.to_upper(), Type.MR)
