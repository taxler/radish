local make_set = require 'parse.char.utf8.make.set'

local function s(v)
	return make_set{S=v}
end

local function r(v)
	return make_set{R=v}
end

local class_sets = {
	[1] = make_set {
		R = {'\u{334}\u{338}',
			'\u{1ce2}\u{1ce8}', '\u{20d8}\u{20da}',
			"\u{16af0}\u{16af4}", "\u{1d167}\u{1d169}"};
		S = "\u{1cd4}\u{20d2}\u{20d3}\u{20e5}\u{20e6}\u{20ea}\u{20eb}"
			.. "\u{10a39}\u{1bc9e}"};
	[7] = make_set {
		S = "\u{93c}\u{9bc}\u{a3c}\u{abc}\u{b3c}\u{cbc}"
			.. "\u{1037}\u{1b34}\u{1be6}\u{1c37}\u{a9b3}"
			.. "\u{110ba}\u{11173}\u{111ca}\u{11236}\u{112e9}\u{1133c}\u{114c3}\u{115c0}\u{116b7}"};
	[8] = s"\u{3099}\u{309a}";
	[9] = make_set {
		S = "\u{94d}\u{9cd}\u{a4d}\u{acd}\u{b4d}\u{bcd}\u{c4d}\u{ccd}\u{d4d}\u{dca}\u{e3a}\u{f84}"
			.. "\u{1039}\u{103a}\u{1714}\u{1734}\u{17d2}\u{1a60}\u{1b44}\u{1baa}\u{1bab}\u{1bf2}"
			.. "\u{1bf3}\u{2d7f}\u{a806}\u{a8c4}\u{a953}\u{a9c0}\u{aaf6}\u{abed}"
			.. "\u{10a3f}\u{11046}\u{1107f}\u{110b9}\u{11133}\u{11134}\u{111c0}\u{11235}\u{112ea}"
			.. "\u{1134d}\u{114c2}\u{115bf}\u{1163f}\u{116b6}\u{1172b}"};
	[10] = s"\u{5b0}"; [11] = s"\u{5b1}"; [12] = s"\u{5b2}"; [13] = s"\u{5b3}"; [14] = s"\u{5b4}";
	[15] = s"\u{5b5}"; [16] = s"\u{5b6}"; [17] = s"\u{5b7}";
	[18] = s"\u{5b8}\u{5c7}";
	[19] = s"\u{5b9}\u{5ba}";
	[20] = s"\u{5bb}"; [21] = s"\u{5bc}"; [22] = s"\u{5bd}"; [23] = s"\u{5bf}"; [24] = s"\u{5c1}";
	[25] = s"\u{5c2}"; [26] = s"\u{fb1e}";
	[27] = s"\u{64b}\u{8f0}"; [28] = s"\u{64c}\u{8f1}"; [29] = s"\u{64d}\u{8f2}";
	[30] = s"\u{618}\u{64e}"; [31] = s"\u{619}\u{64f}"; [32] = s"\u{61a}\u{650}";
	[33] = s"\u{651}"; [34] = s"\u{652}"; [35] = s"\u{670}"; [36] = s"\u{711}";
	[84] = s"\u{c55}";
	[91] = s"\u{c56}";
	[103] = s"\u{e38}\u{e39}"; [107] = r"\u{e48}\u{e4b}"; [118] = s"\u{eb8}\u{eb9}"; [122] = r"\u{ec8}\u{ecb}";
	[129] = s"\u{f71}";
	[130] = make_set {
		S = "\u{f72}\u{f80}";
		R = "\u{f7a}\u{f7d}"};
	[132] = s"\u{f74}";
	[202] = s"\u{321}\u{322}\u{327}\u{328}\u{1dd0}";
	[214] = s"\u{1dce}";
	[216] = make_set {
		S = "\u{31b}\u{f39}\u{1d165}\u{1d166}\u{1d16e}\u{1d16f}";
		R = "\u{1d170}\u{1d172}"};
	[218] = s"\u{302a}";
	[220] = make_set {
		R = {
			"\u{316}\u{319}", "\u{31c}\u{320}", "\u{323}\u{326}", "\u{329}\u{333}", "\u{339}\u{33c}",
			"\u{347}\u{349}", "\u{353}\u{356}", "\u{5a2}\u{5a7}", "\u{737}\u{739}", "\u{8ed}\u{8ef}",
			"\u{1ab5}\u{1aba}", "\u{1cd5}\u{1cd9}", "\u{1cdc}\u{1cdf}", "\u{20ec}\u{20ef}",
			"\u{a92b}\u{a92d}", "\u{fe27}\u{fe2d}",
			"\u{1d17b}\u{1d182}", "\u{1e8d0}\u{1e8d6}"};
		S = "\u{34d}\u{34e}\u{359}\u{35a}\u{591}\u{596}\u{59b}\u{5aa}\u{5c5}\u{655}\u{656}\u{65c}\u{65f}"
			.. "\u{6e3}\u{6ea}\u{6ed}\u{731}\u{734}\u{73b}\u{73c}\u{73e}\u{742}\u{744}\u{746}\u{748}\u{7f2}"
			.. "\u{859}\u{85a}\u{85b}\u{8e3}\u{8e6}\u{8e9}\u{8f6}\u{8f9}\u{8fa}\u{952}\u{f18}\u{f19}\u{f35}"
			.. "\u{f37}\u{fc6}"
			.. "\u{108d}\u{193b}\u{1a18}\u{1a7f}\u{1abd}\u{1b6c}\u{1ced}\u{1dc2}\u{1dca}\u{1dcf}\u{1dfd}"
			.. "\u{1dff}\u{20e8}\u{aab4}"
			.. "\u{101fd}\u{102e0}\u{10a0d}\u{10a3a}\u{10ae6}\u{1d18a}\u{1d18b}"};
	[222] = s"\u{59a}\u{5ad}\u{1939}\u{302d}";
	[224] = s"\u{302e}\u{302f}";
	[226] = s"\u{1d16d}";
	[228] = s"\u{5ae}\u{18a9}\u{302b}";
	[230] = make_set {
		R = {
			"\u{300}\u{314}", "\u{33d}\u{344}", "\u{34a}\u{34c}", "\u{350}\u{352}", "\u{363}\u{36f}",
			"\u{483}\u{487}", "\u{592}\u{595}", "\u{597}\u{599}", "\u{59c}\u{5a1}", "\u{610}\u{617}",
			"\u{657}\u{65b}", "\u{6d6}\u{6dc}", "\u{6df}\u{6e2}", "\u{73f}\u{741}", "\u{7eb}\u{7f1}",
			"\u{816}\u{819}", "\u{81b}\u{823}",	"\u{825}\u{827}", "\u{829}\u{82d}", "\u{8ea}\u{8ec}",
			"\u{8f3}\u{8f5}", "\u{8fb}\u{8ff}",
			"\u{135d}\u{135f}", "\u{1a75}\u{1a7c}", "\u{1ab0}\u{1ab4}", "\u{1b6d}\u{1b73}", "\u{1cd0}\u{1cd2}",
			"\u{1dc3}\u{1dc9}", "\u{1dd1}\u{1df5}", "\u{20d4}\u{20d7}", "\u{2cef}\u{2cf1}", "\u{2de0}\u{2dff}",
			"\u{a674}\u{a67d}", "\u{a8e0}\u{a8f1}", "\u{fe20}\u{fe26}",
			"\u{10376}\u{1037a}", "\u{11100}\u{11102}", "\u{11366}\u{1136c}", "\u{11370}\u{11374}",
			"\u{16b30}\u{16b36}", "\u{1d185}\u{1d189}", "\u{1d1aa}\u{1d1ad}", "\u{1d242}\u{1d244}"};	
		S = "\u{346}\u{357}\u{35b}\u{5a8}\u{5a9}\u{5ab}\u{5ac}\u{5af}\u{5c4}\u{653}\u{654}\u{65d}\u{65e}"
			.. "\u{6e4}\u{6e7}\u{6e8}\u{6eb}\u{6ec}\u{730}\u{732}\u{733}\u{735}\u{736}\u{73a}\u{73d}\u{743}"
			.. "\u{745}\u{747}\u{749}\u{74a}\u{7f3}\u{8e4}\u{8e5}\u{8e7}\u{8e8}\u{8f7}\u{8f8}\u{951}\u{953}"
			.. "\u{954}\u{f82}\u{f83}\u{f86}\u{f87}"
			.. "\u{17dd}\u{193a}\u{1a17}\u{1abb}\u{1abc}\u{1b6b}\u{1cda}\u{1cdb}\u{1ce0}\u{1cf4}\u{1cf8}\u{1cf9}"
			.. "\u{1dc0}\u{1dc1}\u{1dcb}\u{1dcc}\u{1dfe}\u{20d0}\u{20d1}\u{20db}\u{20dc}\u{20e1}\u{20e7}\u{20e9}"
			.. "\u{20f0}\u{a66f}\u{a69e}\u{a69f}\u{a6f0}\u{a6f1}\u{aab0}\u{aab2}\u{aab3}\u{aab7}\u{aab8}\u{aabe}"
			.. "\u{aabf}\u{aac1}\u{fe2e}\u{fe2f}"
			.. "\u{10a0f}\u{10a38}\u{10ae5}"};
	[232] = s"\u{315}\u{31a}\u{358}\u{302c}";
	[233] = s"\u{35c}\u{35f}\u{362}\u{1dfc}";
	[234] = s"\u{35d}\u{35e}\u{360}\u{361}\u{1dcd}";
	[240] = s"\u{345}";
}

setmetatable(class_sets, {
	__index = function(self, k)
		if k == 0 then
			local anti_set = make_set()
			for v, set in pairs(class_sets) do
				if type(v) == 'number' then
					anti_set = anti_set - set
				end
			end
			self[0] = anti_set
			return anti_set
		end
		return nil
	end
})

function class_sets.where(op, ref)
	if op == '=' or op == '==' then
		return class_sets[ref] or make_set { S = '' }
	elseif op == '<' then
		if ref <= 0 then
			return make_set { S = '' }
		end
		return make_set() - class_sets.where('>=', ref)
	elseif op == '<=' then
		if ref < 0 then
			return make_set { S = '' }
		elseif ref == 0 then
			return class_sets[0]
		end
		return make_set() - class_sets.where('>', ref)
	elseif op == '>' then
		if ref < 0 then
			return class_sets[0]
		end
		op = function(v)  return v > ref;  end
	elseif op == '>=' then
		if ref <= 0 then
			return make_set()
		end
		op = function(v)  return v >= ref;  end
	elseif type(op) ~= 'function' then
		error('unknown op')
	end
	local combined_set = make_set { S = '' }
	for v, set in pairs(class_sets) do
		if type(v) == 'number' then
			if op(v) then
				combined_set = combined_set + set
			end
		end
	end
	return combined_set
end

return class_sets
