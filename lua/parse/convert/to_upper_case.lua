
local m = require 'lpeg'

local CH = string.char

local function table_S(t)
	local s = m.P(false)
	for k in pairs(t) do
		s = s + k
	end
	return s
end

local function table_C(t)
	return table_S(t) / t
end

local matcher = m.P(false)

local first_bytes = {}

do -- F0 9. .. ..
	first_bytes['\xF0'] = true

	local F0_matcher = m.P(false)

	do -- F0 91 A3 ..
		local mapping = {}
		for b = 0x80, 0x9F do
			mapping[CH(b)] = CH(0xF0, 0x91, 0xA2, b + 0x20)
		end
		F0_matcher = ('\x91\xA3' * table_C(mapping)) + F0_matcher
	end

	do -- F0 90 .. ..
		local F0_90_matcher = m.P(false)

		do -- F0 90 B3 ..
			local mapping = {}
			for b = 0x80, 0xB2 do
				mapping[CH(b)] = CH(0xF0, 0x90, 0xB2, b)
			end
			F0_90_matcher = ('\xB3' * table_C(mapping)) + F0_90_matcher
		end
		do -- F0 90 91 ..
			local mapping = {}
			for b = 0x80, 0x8F do
				mapping[CH(b)] = CH(0xF0, 0x90, 0x90, b + 0x18)
			end
			F0_90_matcher = ('\x91' * table_C(mapping)) + F0_90_matcher
		end
		do -- F0 90 90 ..
			local mapping = {}
			for b = 0xA8, 0xBF do
				mapping[CH(b)] = CH(0xF0, 0x90, 0x90, b - 0x28)
			end
			F0_90_matcher = ('\x90' * table_C(mapping)) + F0_90_matcher
		end
		F0_matcher = ('\x90' * F0_90_matcher) + F0_matcher
	end

	matcher = ('\xF0' * F0_matcher) + matcher
end

do -- EF BD ..
	first_bytes['\xEF'] = true
	local mapping = {}
	for b = 0x81, 0x9A do
		mapping[CH(b)] = CH(0xEF, 0xBC, b + 0x20)
	end
	matcher = ('\xEF\xBD' * table_C(mapping)) + matcher
end

do -- EA .. ..
	first_bytes['\xEA'] = true

	local EA_matcher = m.P(false)

	do -- EA AE ..
		local mapping = {}
		for b = 0x80, 0x8F do
			mapping[CH(b)] = CH(0xE1, 0x8E, b + 0x30)
		end
		for b = 0x90, 0xBF do
			mapping[CH(b)] = CH(0xE1, 0x8F, b - 0x10)
		end
		EA_matcher = ('\xAE' * table_C(mapping)) + EA_matcher
	end

	do -- EA AD ..
		local mapping = {['\x93']='\xEA\x9E\xB3'}
		for b = 0xB0, 0xBF do
			mapping[CH(b)] = CH(0xE1, 0x8E, b - 0x10)
		end
		EA_matcher = ('\xAD' * table_C(mapping)) + EA_matcher
	end
	do -- EA 9E ..
		local mapping = {}
		for b = 0x81, 0x87, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9E, b - 1)
		end
		mapping['\x8C'] = '\xEA\x9E\x8B'
		mapping['\x91'] = '\xEA\x9E\x90'
		mapping['\x93'] = '\xEA\x9E\x92'
		for b = 0x97, 0xA9, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9E, b - 1)
		end
		mapping['\xB5'] = '\xEA\x9E\xB4'
		mapping['\xB7'] = '\xEA\x9E\xB6'
		EA_matcher = ('\x9E' * table_C(mapping)) + EA_matcher
	end
	do -- EA 9D ..
		local mapping = {}
		for b = 0x81, 0xAF, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9D, b - 1)
		end
		for b = 0xBA, 0xBF, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9D, b - 1)
		end
		EA_matcher = ('\x9D' * table_C(mapping)) + EA_matcher
	end
	do -- EA 9C ..
		local mapping = {}
		for b = 0xA3, 0xBF, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9C, b - 1)
		end
		EA_matcher = ('\x9C' * table_C(mapping)) + EA_matcher
	end
	do -- EA 9A ..
		local mapping = {}
		for b = 0x81, 0x9B, 2 do
			mapping[CH(b)] = CH(0xEA, 0x9A, b - 1)
		end
		EA_matcher = ('\x9A' * table_C(mapping)) + EA_matcher
	end
	do -- EA 99 ..
		local mapping = {}
		for b = 0x81, 0xAD, 2 do
			mapping[CH(b)] = CH(0xEA, 0x99, b - 1)
		end
		EA_matcher = ('\x99' * table_C(mapping)) + EA_matcher
	end

	matcher = ('\xEA' * EA_matcher) + matcher
end

do -- E2 .. ..
	first_bytes['\xE2'] = true

	local E2_matcher = m.P(false)

	do -- E2 B4 ..
		local mapping = {}
		for b = 0x80, 0x9F do
			mapping[CH(b)] = CH(0xE1, 0x82, b + 0x20)
		end
		for b = 0xA0, 0xA5 do
			mapping[CH(b)] = CH(0xE1, 0x83, b - 0x30)
		end
		mapping['\xA7'] = '\xE1\x83\x87'
		mapping['\xAD'] = '\xE1\x83\x8D'
		E2_matcher = ('\xB4' * table_C(mapping)) + E2_matcher
	end
	do -- E2 B3 ..
		local mapping = {
			['\xAC']='\xE2\xB3\xAB'; ['\xAE']='\xE2\xB3\xAD'; ['\xB3']='\xE2\xB3\xB2';
		}
		for b = 0x81, 0xA3 do
			mapping[CH(b)] = CH(0xE2, 0xB3, b - 1)
		end
		E2_matcher = ('\xB3' * table_C(mapping)) + E2_matcher
	end
	do -- E2 B2 ..
		local mapping = {}
		for b = 0x81, 0xBF, 2 do
			mapping[CH(b)] = CH(0xE2, 0xB2, b - 1)
		end
		E2_matcher = ('\xB2' * table_C(mapping)) + E2_matcher
	end
	do -- E2 B1 ..
		local mapping = {
			['\xA5']='\xC8\xBA'; ['\xA6']='\xC8\xBE';
			['\xA1']='\xE2\xB1\xA0'; ['\xA8']='\xE2\xB1\xA7'; ['\xAA']='\xE2\xB1\xA9';
			['\xAC']='\xE2\xB1\xAB'; ['\xB3']='\xE2\xB1\xB2'; ['\xB6']='\xE2\xB1\xB5';
		}
		for b = 0x80, 0x9E do
			mapping[CH(b)] = CH(0xE2, 0xB0, b + 0x10)
		end
		E2_matcher = ('\xB1' * table_C(mapping)) + E2_matcher
	end
	do -- E2 B0 ..
		local mapping = {}
		for b = 0xB0, 0xBF do
			mapping[CH(b)] = CH(0xE2, 0xB0, b - 0x30)
		end
		E2_matcher = ('\xB0' * table_C(mapping)) + E2_matcher
	end
	do -- E2 93 ..
		local mapping = {}
		for b = 0x90, 0x99 do
			mapping[CH(b)] = CH(0xE2, 0x92, b + 0x26)
		end
		for b = 0x9A, 0xA9 do
			mapping[CH(b)] = CH(0xE2, 0x93, b - 0x1A)
		end
		E2_matcher = ('\x93' * table_C(mapping)) + E2_matcher
	end
	do -- E2 86 84
		E2_matcher = ('\x86\x84' * (m.P'' / '\xE2\x86\x83')) + E2_matcher
	end
	do -- E2 85 ..
		local mapping = {['\x8E'] = '\xE2\x84\xB2'}
		for b = 0xB0, 0xBF do
			mapping[CH(b)] = CH(0xE2, 0x85, b + 0x20)
		end
		E2_matcher = ('\x85' * table_C(mapping)) + E2_matcher
	end

	matcher = ('\xE2' * E2_matcher) + matcher
end

do -- E1 .. ..
	first_bytes['\xE1'] = true

	local E1_matcher = m.P(false)

	do -- E1 BF ..
		local mapping = {
			['\x83']='\xE1\xBF\x8C'; ['\x90']='\xE1\xBF\x98'; ['\x91']='\xE1\xBF\x99'; ['\xA0']='\xE1\xBF\xA8';
			['\xA1']='\xE1\xBF\xA9'; ['\xA5']='\xE1\xBF\xAC'; ['\xB3']='\xE1\xBF\xBC';
		}
		E1_matcher = ('\xBF' * table_C(mapping)) + E1_matcher
	end

	do -- E1 BE ..
		local mapping = {
			['\xB0']='\xE1\xBE\xB8'; ['\xB1']='\xE1\xBE\xB9'; ['\xB3']='\xE1\xBE\xBC'; ['\xBE']='\xCE\x99';
		}
		for i = 0, 7 do
			mapping[CH(0x80 + i)] = CH(0xE1, 0xBE, 0x88 + i)
			mapping[CH(0x90 + i)] = CH(0xE1, 0xBE, 0x98 + i)
			mapping[CH(0xA0 + i)] = CH(0xE1, 0xBE, 0xA8 + i)
		end
		E1_matcher = ('\xBE' * table_C(mapping)) + E1_matcher
	end

	do -- E1 BD ..
		local mapping = {
			['\xB0']='\xE1\xBE\xBA'; ['\xB1']='\xE1\xBE\xBB'; ['\xB2']='\xE1\xBF\x88'; ['\xB3']='\xE1\xBF\x89';
			['\xB4']='\xE1\xBF\x8A'; ['\xB5']='\xE1\xBF\x8B'; ['\xB6']='\xE1\xBF\x9A'; ['\xB7']='\xE1\xBF\x9B';
			['\xB8']='\xE1\xBF\xB8'; ['\xB9']='\xE1\xBF\xB9'; ['\xBA']='\xE1\xBF\xAA'; ['\xBB']='\xE1\xBF\xAB';
			['\xBC']='\xE1\xBF\xBA'; ['\xBD']='\xE1\xBF\xBB';
		}
		for b = 0x80, 0x85 do
			mapping[CH(b)] = CH(0xE1, 0xBD, b + 8)
		end
		for b = 0x91, 0x97, 2 do
			mapping[CH(b)] = CH(0xE1, 0xBD, b + 8)
		end
		for b = 0xA0, 0xA7 do
			mapping[CH(b)] = CH(0xE1, 0xBD, b + 8)
		end
		E1_matcher = ('\xBD' * table_C(mapping)) + E1_matcher		
	end

	do -- E1 BC ..
		local mapping = {}
		for b = 0x80, 0x87 do
			mapping[CH(b)] = CH(0xE1, 0xBC, b + 8)
		end
		for b = 0x90, 0x95 do
			mapping[CH(b)] = CH(0xE1, 0xBC, b + 8)
		end
		for b = 0xA0, 0xA7 do
			mapping[CH(b)] = CH(0xE1, 0xBC, b + 8)
		end
		for b = 0xB0, 0xB7 do
			mapping[CH(b)] = CH(0xE1, 0xBC, b + 8)
		end
		E1_matcher = ('\xBC' * table_C(mapping)) + E1_matcher
	end

	do -- E1 BB ..
		local mapping = {}
		for b = 0x81, 0xBF, 2 do
			mapping[CH(b)] = CH(0xE1, 0xBB, b - 1)
		end
		E1_matcher = ('\xBB' * table_C(mapping)) + E1_matcher
	end

	do -- E1 BA ..
		local mapping = {}
		for b = 0x81, 0x95, 2 do
			mapping[CH(b)] = CH(0xE1, 0xBA, b - 1)
		end
		mapping['\x9B'] = '\xE1\xB9\xA0'
		for b = 0xA1, 0xBF, 2 do
			mapping[CH(b)] = CH(0xE1, 0xBA, b - 1)
		end
		E1_matcher = ('\xBA' * table_C(mapping)) + E1_matcher
	end

	do -- E1 B9 ..
		local mapping = {}
		for b = 0x81, 0xBF, 2 do
			mapping[CH(b)] = CH(0xE1, 0xB9, b - 1)
		end
		E1_matcher = ('\xB9' * table_C(mapping)) + E1_matcher
	end

	do -- E1 B8 ..
		local mapping = {}
		for b = 0x81, 0xBF, 2 do
			mapping[CH(b)] = CH(0xE1, 0xB8, b - 1)
		end
		E1_matcher = ('\xB8' * table_C(mapping)) + E1_matcher
	end

	do -- E1 B5 B.
		local case_1 = '\xB9' * (m.P'' / '\xEA\x9D\xBD')
		local case_2 = '\xBD' * (m.P'' / '\xE2\xB1\xA3')
		E1_matcher = ('\xB5' * (case_1 + case_2)) + E1_matcher
	end

	do -- E1 8F B.
		local mapping = {}
		for b = 0xB8, 0xBD do
			mapping[CH(b)] = CH(0xE1, 0x8F, b - 8)
		end
		E1_matcher = ('\x8F' * table_C(mapping)) + E1_matcher
	end

	matcher = ('\xE1' * E1_matcher) + matcher
end

do -- D6 ..
	first_bytes['\xD6'] = true
	local mapping = {}
	for b = 0x80, 0x86 do
		mapping[CH(b)] = CH(0xD5, b + 0x10)
	end
	matcher = ('\xD6' * table_C(mapping)) + matcher
end

do -- D5 ..
	first_bytes['\xD5'] = true
	local mapping = {}
	for b = 0xA1, 0xAF do
		mapping[CH(b)] = CH(0xD4, b + 0x10)
	end
	for b = 0xB0, 0xBF do
		mapping[CH(b)] = CH(0xD5, b - 0x20)
	end
	matcher = ('\xD5' * table_C(mapping)) + matcher
end

do -- D4 ..
	first_bytes['\xD4'] = true
	local mapping = {}
	for b = 0x81, 0xAF, 2 do
		mapping[CH(b)] = CH(0xD4, b - 1)
	end
	matcher = ('\xD4' * table_C(mapping)) + matcher
end

do -- D3 ..
	first_bytes['\xD3'] = true
	local mapping = {}
	for b = 0x82, 0x8E, 2 do
		mapping[CH(b)] = CH(0xD3, b - 1)
	end
	mapping['\x8F'] = '\xD3\x80'
	for b = 0x91, 0xBF, 2 do
		mapping[CH(b)] = CH(0xD3, b - 1)
	end
	matcher = ('\xD3' * table_C(mapping)) + matcher
end

do -- D2 ..
	first_bytes['\xD2'] = true
	local mapping = {}
	mapping['\x81'] = '\xD2\x80'
	for b = 0x8B, 0xBF, 2 do
		mapping[CH(b)] = CH(0xD2, b - 1)
	end
	matcher = ('\xD2' * table_C(mapping)) + matcher
end

do -- D1 ..
	first_bytes['\xD1'] = true
	local mapping = {}
	for b = 0x80, 0x8F do
		mapping[CH(b)] = CH(0xD0, b + 0x20)
	end
	for b = 0x90, 0x9F do
		mapping[CH(b)] = CH(0xD0, b - 0x10)
	end
	for b = 0xA1, 0xBF, 2 do
		mapping[CH(b)] = CH(0xD1, b - 1)
	end
	matcher = ('\xD1' * table_C(mapping)) + matcher
end

do -- D0 ..
	first_bytes['\xD0'] = true
	local mapping = {}
	for b = 0xB0, 0xBF do
		mapping[CH(b)] = CH(0xD0, b + 0x10)
	end
	matcher = ('\xD0' * table_C(mapping)) + matcher
end

do -- CF ..
	first_bytes['\xCF'] = true
	local mapping = {
		['\x80']='\xCE\xA0'; ['\x81']='\xCE\xA1'; ['\x82']='\xCE\xA3'; ['\x83']='\xCE\xA3';
		['\x84']='\xCE\xA4'; ['\x85']='\xCE\xA5'; ['\x86']='\xCE\xA6'; ['\x87']='\xCE\xA7';
		['\x88']='\xCE\xA8'; ['\x89']='\xCE\xA9'; ['\x8A']='\xCE\xAA'; ['\x8B']='\xCE\xAB';
		['\x8C']='\xCE\x8C'; ['\x8D']='\xCE\x8E'; ['\x8E']='\xCE\x8F'; ['\x90']='\xCE\x92';
		['\x91']='\xCE\x98'; ['\x95']='\xCE\xA6'; ['\x96']='\xCE\xA0'; ['\x97']='\xCF\x8F';
		['\x99']='\xCF\x98'; ['\x9B']='\xCF\x9A'; ['\x9D']='\xCF\x9C'; ['\x9F']='\xCF\x9E';
		['\xA1']='\xCF\xA0'; ['\xA3']='\xCF\xA2'; ['\xA5']='\xCF\xA4'; ['\xA7']='\xCF\xA6';
		['\xA9']='\xCF\xA8'; ['\xAB']='\xCF\xAA'; ['\xAD']='\xCF\xAC'; ['\xAF']='\xCF\xAE';
		['\xB0']='\xCE\x9A'; ['\xB1']='\xCE\xA1'; ['\xB2']='\xCF\xB9'; ['\xB3']='\xCD\xBF';
		['\xB5']='\xCE\x95'; ['\xB8']='\xCF\xB7'; ['\xBB']='\xCF\xBA';
	}
	matcher = ('\xCF' * table_C(mapping)) + matcher
end

do -- CE ..
	first_bytes['\xCE'] = true
	local mapping = {
		['\xAC']='\xCE\x86', ['\xAD']='\xCE\x88', ['\xAE']='\xCE\x89', ['\xAF']='\xCE\x8A'
	}
	for b = 0xB1, 0xBF do
		mapping[CH(b)] = CH(0xCE, b - 0x20)
	end
	matcher = ('\xCE' * table_C(mapping)) + matcher
end

do -- CD ..
	first_bytes['\xCD'] = true
	local mapping = {
		['\x85']='\xCE\x99'; ['\xB1']='\xCD\xB0'; ['\xB3']='\xCD\xB2'; ['\xB7']='\xCD\xB6';
		['\xBB']='\xCF\xBD'; ['\xBC']='\xCF\xBE'; ['\xBD']='\xCF\xBF';
	}
	matcher = ('\xCD' * table_C(mapping)) + matcher
end

do -- CA ..
	first_bytes['\xCA'] = true
	local mapping = {
		['\x80']='\xC6\xA6'; ['\x83']='\xC6\xA9'; ['\x88']='\xC6\xAE'; ['\x89']='\xC9\x84';
		['\x8A']='\xC6\xB1'; ['\x8B']='\xC6\xB2'; ['\x8C']='\xC9\x85'; ['\x92']='\xC6\xB7';
		['\x87']='\xEA\x9E\xB1'; ['\x9D']='\xEA\x9E\xB2'; ['\x9E']='\xEA\x9E\xB0';
	}
	matcher = ('\xCA' * table_C(mapping)) + matcher
end

do -- C9 ..
	first_bytes['\xC9'] = true
	local mapping = {
		['\x82']='\xC9\x81'; ['\x87']='\xC9\x86'; ['\x89']='\xC9\x88'; ['\x8B']='\xC9\x8A';
		['\x8D']='\xC9\x8C'; ['\x8F']='\xC9\x8E'; ['\x93']='\xC6\x81'; ['\x94']='\xC6\x86';
		['\x96']='\xC6\x89'; ['\x97']='\xC6\x8A'; ['\x99']='\xC6\x8F'; ['\x9B']='\xC6\x90';
		['\xA0']='\xC6\x93'; ['\xA3']='\xC6\x94'; ['\xA8']='\xC6\x97'; ['\xA9']='\xC6\x96';
		['\xAF']='\xC6\x9C'; ['\xB2']='\xC6\x9D'; ['\xB5']='\xC6\x9F';
		['\x80']='\xE2\xB1\xBF'; ['\x90']='\xE2\xB1\xAF'; ['\x91']='\xE2\xB1\xAD';
		['\x92']='\xE2\xB1\xB0'; ['\x9C']='\xEA\x9E\xAB'; ['\xA1']='\xEA\x9E\xAC';
		['\xA5']='\xEA\x9E\x8D'; ['\xA6']='\xEA\x9E\xAA'; ['\xAB']='\xE2\xB1\xA2';
		['\xAC']='\xEA\x9E\xAD'; ['\xB1']='\xE2\xB1\xAE'; ['\xBD']='\xE2\xB1\xA4';
	}
	matcher = ('\xC9' * table_C(mapping)) + matcher
end

do -- C8 ..
	first_bytes['\xC8'] = true
	local mapping = {
		['\x81']='\xC8\x80'; ['\x83']='\xC8\x82'; ['\x85']='\xC8\x84'; ['\x87']='\xC8\x86';
		['\x89']='\xC8\x88'; ['\x8B']='\xC8\x8A'; ['\x8D']='\xC8\x8C'; ['\x8F']='\xC8\x8E';
		['\x91']='\xC8\x90'; ['\x93']='\xC8\x92'; ['\x95']='\xC8\x94'; ['\x97']='\xC8\x96';
		['\x99']='\xC8\x98'; ['\x9B']='\xC8\x9A'; ['\x9D']='\xC8\x9C'; ['\x9F']='\xC8\x9E';
		['\xA3']='\xC8\xA2'; ['\xA5']='\xC8\xA4'; ['\xA7']='\xC8\xA6'; ['\xA9']='\xC8\xA8';
		['\xAB']='\xC8\xAA'; ['\xAD']='\xC8\xAC'; ['\xAF']='\xC8\xAE'; ['\xB1']='\xC8\xB0';
		['\xB3']='\xC8\xB2'; ['\xBC']='\xC8\xBB'; ['\xBF']='\xE2\xB1\xBE';
	}
	matcher = ('\xC8' * table_C(mapping)) + matcher
end

do -- C7 ..
	first_bytes['\xC7'] = true
	local mapping = {
		['\x85']='\xC7\x84'; ['\x86']='\xC7\x84'; ['\x88']='\xC7\x87'; ['\x89']='\xC7\x87';
		['\x8B']='\xC7\x8A'; ['\x8C']='\xC7\x8A'; ['\x8E']='\xC7\x8D'; ['\x90']='\xC7\x8F';
		['\x92']='\xC7\x91'; ['\x94']='\xC7\x93'; ['\x96']='\xC7\x95'; ['\x98']='\xC7\x97';
		['\x9A']='\xC7\x99'; ['\x9C']='\xC7\x9B'; ['\x9D']='\xC6\x8E'; ['\x9F']='\xC7\x9E';
		['\xA1']='\xC7\xA0'; ['\xA3']='\xC7\xA2'; ['\xA5']='\xC7\xA4'; ['\xA7']='\xC7\xA6';
		['\xA9']='\xC7\xA8'; ['\xAB']='\xC7\xAA'; ['\xAD']='\xC7\xAC'; ['\xAF']='\xC7\xAE';
		['\xB2']='\xC7\xB1'; ['\xB3']='\xC7\xB1'; ['\xB5']='\xC7\xB4'; ['\xB9']='\xC7\xB8';
		['\xBB']='\xC7\xBA'; ['\xBD']='\xC7\xBC'; ['\xBF']='\xC7\xBE';
	}
	matcher = ('\xC7' * table_C(mapping)) + matcher
end

do -- C6 ..
	first_bytes['\xC6'] = true
	local mapping = {
		['\x80']='\xC9\x83'; ['\x83']='\xC6\x82'; ['\x85']='\xC6\x84'; ['\x88']='\xC6\x87';
		['\x8C']='\xC6\x8B'; ['\x92']='\xC6\x91'; ['\x95']='\xC7\xB6'; ['\x99']='\xC6\x98';
		['\x9A']='\xC8\xBD'; ['\x9E']='\xC8\xA0'; ['\xA1']='\xC6\xA0'; ['\xA3']='\xC6\xA2';
		['\xA5']='\xC6\xA4'; ['\xA8']='\xC6\xA7'; ['\xAD']='\xC6\xAC'; ['\xB0']='\xC6\xAF';
		['\xB4']='\xC6\xB3'; ['\xB6']='\xC6\xB5'; ['\xB9']='\xC6\xB8'; ['\xBD']='\xC6\xBC';
		['\xBF']='\xC7\xB7';
	}
	matcher = ('\xC6' * table_C(mapping)) + matcher
end

do -- C5 ..
	first_bytes['\xC5'] = true
	local mapping = {}
	mapping['\x80'] = '\u{13f}'
	-- even
	for b = 0x82, 0x88, 2 do
		mapping[CH(b)] = CH(0xC5, b-1)
	end
	-- odd
	for b = 0x8B, 0xB7, 2 do
		mapping[CH(b)] = CH(0xC5, b-1)
	end
	-- even
	for b = 0xBA, 0xBE, 2 do
		mapping[CH(b)] = CH(0xC5, b-1)
	end
	mapping['\xBF'] = 'S'
	matcher = ('\xC4' * table_C(mapping)) + matcher
end

do -- C4 ..
	first_bytes['\xC4'] = true
	local mapping = {}
	mapping['\xb1'] = 'I'
	for b = 0x81, 0xbe, 2 do
		mapping[CH(b)] = CH(0xc4, b-1)
	end
	matcher = ('\xC4' * table_C(mapping)) + matcher
end

do -- C3 ..
	first_bytes['\xC3'] = true
	local mapping = {}
	for b = 0xa0, 0xbe do
		mapping[CH(b)] = CH(0xC3, b - 0x20)
	end
	mapping['\xBF'] = '\u{178}'

	matcher = ('\xC3' * table_C(mapping)) + matcher
end

do -- C2 ..
	first_bytes['\xC2'] = true
	matcher = ('\xC2\xB5' * (m.P'' / '\u{39c}')) + matcher
end

matcher = #table_S(first_bytes) * matcher

-- basic latin alphabet
do
	local mapping = {}

	for b = string.byte(0x61), string.byte(0x7a) do
		mapping[CH(b)] = CH(b - 0x20)
	end

	matcher = (m.R'az' / mapping) + matcher
end

return matcher
