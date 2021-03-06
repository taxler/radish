
return {

	csUTF8 = 'UTF-8';
	csUTF16 = 'UTF-16'; csUTF16BE = 'UTF-16BE'; csUTF16LE = 'UTF-16LE';
	csUTF32	= 'UTF-32'; csUTF32BE = 'UTF-32BE'; csUTF32LE = 'UTF-32LE';

	-- in a list, the first entry is the primary name

	csASCII = {'US-ASCII','us',
		'iso-ir-6','ANSI_X3.4-1968','ANSI_X3.4-1986','ISO_646.irv:1991','ISO646-USv','IBM367','cp367'};
	csISOLatin1 = {'ISO-8859-1', 'ISO_8859-1', 'latin1', 'l1';
		'iso-ir-100', 'IBM819', 'CP819'};

	cswindows874 = 'windows-874';
	cswindows1250 = 'windows-1250';
	cswindows1251 = 'windows-1251';
	cswindows1252 = 'windows-1252';
	cswindows1253 = 'windows-1253';
	cswindows1254 = 'windows-1254';
	cswindows1255 = 'windows-1255';
	cswindows1256 = 'windows-1256';
	cswindows1257 = 'windows-1257';
	cswindows1258 = 'windows-1258';
	
	csISOLatin2 = {'ISO-8859-2', 'ISO_8859-2', 'latin2', 'l2'; 'iso-ir-101'};
	csISOLatin3 = {'ISO-8859-3', 'ISO_8859-3', 'latin3', 'l3'; 'iso-ir-109'};
	csISOLatin4 = {'ISO-8859-4', 'ISO_8859-4', 'latin4', 'l4'; 'iso-ir-110'};
	csISOLatinCyrillic = {'ISO-8859-5'; 'iso-ir-144', 'ISO_8859-5', 'cyrillic'};
	csISOLatinArabic = {'ISO-8859-6', 'ISO_8859-6', 'arabic'; 'iso-ir-127', 'ECMA-114', 'ASMO-708'};
	csISOLatinGreek = {'ISO-8859-7', 'ISO_8859-7', 'greek', 'greek8';
		'iso-ir-126', 'ELOT_928', 'ECMA-118'};
	csISOLatinHebrew = {'ISO-8859-8', 'ISO_8859-8', 'hebrew', 'iso-ir-138'};
	csISOLatin5 = {'ISO-8859-9'; 'ISO_8859-9', 'iso-ir-148', 'latin5', 'l5'};
	csISOLatin6 = {'ISO-8859-10'; 'iso-ir-157', 'l6', 'ISO_8859-10:1992', 'latin6'};
	csTIS620 = {'TIS-620', 'ISO-8859-11'};
	-- there is no ISO-8859-12
	csISO885913	= 'ISO-8859-13';
	csISO885914 = {'ISO-8859-14', 'ISO_8859-14:1998', 'ISO_8859-14', 'latin8', 'iso-celtic', 'l8', 'iso-ir-199'};
	csISO885915 = {'ISO-8859-15', 'ISO_8859-15', 'Latin-9'};
	csISO885916 = {'ISO-8859-16', 'iso-ir-226', 'ISO_8859-16:2001', 'ISO_8859-16', 'latin10', 'l10'};
	csISOTextComm = {'ISO_6937-2-add'; 'iso-ir-142'};
	csHalfWidthKatakana = {'JIS_X0201'; 'X0201'};
	csJISEncoding = 'JIS_Encoding';
	csShiftJIS = {'Shift_JIS', 'MS_Kanji'};
	csEUCPkdFmtJapanese = 'EUC-JP';
	csEUCFixWidJapanese	= 'Extended_UNIX_Code_Fixed_Width_for_Japanese';
	csISO4UnitedKingdom	= {'BS_4730', 'uk', 'gb', 'ISO646-GB', 'iso-ir-4'};
	csISO11SwedishForNames = {'SEN_850200_C', 'se2', 'ISO646-SE2', 'iso-ir-11'};
	csISO15Italian = {'IT', 'ISO646-IT', 'iso-ir-15'};
	csISO17Spanish = {'ES', 'ISO646-ES', 'iso-ir-17'};
	csISO21German = {'DIN_66003', 'de', 'ISO646-DE', 'iso-ir-21'};
	csISO60DanishNorwegian = {'NS_4551-1', 'no', 'iso-ir-60', 'ISO646-NO', 'csISO60Norwegian1'};
	csISO69French = {'NF_Z_62-010', 'fr', 'iso-ir-69', 'ISO646-FR'};
	csISO10646UTF1 = 'ISO-10646-UTF-1';
	csISO646basic1983 = {'ISO_646.basic:1983', 'ref'};
	csINVARIANT = 'INVARIANT';
	csISO2IntlRefVersion = {'ISO_646.irv:1983', 'irv', 'iso-ir-2'};
	csNATSSEFI = {'NATS-SEFI', 'iso-ir-8-1'};
	csNATSSEFIADD = {'NATS-SEFI-ADD', 'iso-ir-8-2'};
	csNATSDANO = {'NATS-DANO', 'iso-ir-9-1'};
	csNATSDANOADD = {'NATS-DANO-ADD', 'iso-ir-9-2'};
	csISO10Swedish = {'SEN_850200_B', 'FI', 'se', 'ISO646-FI', 'ISO646-SE', 'iso-ir-10'};
	csKSC56011987 = {'KS_C_5601-1987', 'korean', 'KS_C_5601-1989', 'KSC_5601', 'iso-ir-149'};
	csISO2022KR	= 'ISO-2022-KR';
	csEUCKR	= 'EUC-KR';
	csISO2022JP = 'ISO-2022-JP';
	csISO2022JP2 = 'ISO-2022-JP-2';
	csISO13JISC6220jp = {'JIS_C6220-1969-jp', 'JIS_C6220-1969', 'iso-ir-13', 'katakana', 'x0201-7'};
	jp = {'JIS_C6220-1969-ro', 'iso-ir-14', 'ISO646-JP'};
	csISO16Portuguese = {'csISO14JISC6220ro', 'iso-ir-16', 'ISO646-PT'};
	csISO18Greek7Old = {'greek7-old', 'iso-ir-18'};
	csISO19LatinGreek = {'latin-greek', 'iso-ir-19'};
	csISO25French = {'NF_Z_62-010_(1973)', 'iso-ir-25', 'ISO646-FR1'};
	csISO27LatinGreek1 = {'Latin-greek-1', 'iso-ir-27'};
	csISO5427Cyrillic = {'ISO_5427', 'iso-ir-37'};
	csISO42JISC62261978 = {'JIS_C6226-1978', 'iso-ir-42'};
	csISO47BSViewdata = {'BS_viewdata', 'iso-ir-47'};
	csISO49INIS	= {'INIS', 'iso-ir-49'};
	csISO50INIS8 = {'INIS-8', 'iso-ir-50'};
	csISO51INISCyrillic = {'INIS-cyrillic', 'iso-ir-51'};
	csISO54271981 = {'ISO_5427:1981', 'iso-ir-54', 'ISO5427Cyrillic1981'};
	csISO5428Greek = {'ISO_5428:1980', 'iso-ir-55'};
	csISO57GB1988 = {'GB_1988-80', 'iso-ir-57', 'cn', 'ISO646-CN'};
	csISO58GB231280 = {'GB_2312-80', 'iso-ir-58', 'chinese'};
	csISO61Norwegian2 = {'NS_4551-2', 'ISO646-NO2', 'iso-ir-61', 'no2'};
	csISO70VideotexSupp1 = {'videotex-suppl', 'iso-ir-70'};
	csISO84Portuguese2 = {'PT2', 'iso-ir-84', 'ISO646-PT2'};
	csISO85Spanish2 = {'ES2', 'iso-ir-85', 'ISO646-ES2'};
	csISO86Hungarian = {'MSZ_7795.3', 'hu', 'iso-ir-86', 'ISO646-HU'};
	csISO87JISX0208 = {'JIS_C6226-1983', 'iso-ir-87', 'x0208', 'JIS_X0208-1983'};
	csISO88Greek7 = {'greek7', 'iso-ir-88'};
	csISO89ASMO449 = {'ASMO_449', 'arabic7', 'ISO_9036', 'iso-ir-89'};
	csISO90	= 'iso-ir-90';
	csISO91JISC62291984a = {'JIS_C6229-1984-a', 'iso-ir-91', 'jp-ocr-a'};
	csISO92JISC62991984b = {'JIS_C6229-1984-b', 'iso-ir-92', 'ISO646-JP-OCR-B', 'jp-ocr-b'};
	csISO93JIS62291984badd = {'JIS_C6229-1984-b-add', 'iso-ir-93', 'jp-ocr-b-add'};
	csISO94JIS62291984hand = {'JIS_C6229-1984-hand', 'iso-ir-94', 'jp-ocr-hand'};
	csISO95JIS62291984handadd = {'JIS_C6229-1984-hand-add', 'iso-ir-95', 'jp-ocr-hand-add'};
	csISO96JISC62291984kana = {'JIS_C6229-1984-kana', 'iso-ir-96'};
	csISO2033 = {'ISO_2033-1983', 'iso-ir-98', 'e13b'};
	csISO99NAPLPS = {'ANSI_X3.110-1983', 'iso-ir-99', 'CSA_T500-1983', 'NAPLPS'};
	csISO102T617bit = {'T.61-7bit', 'iso-ir-102'};
	csISO103T618bit = {'T.61-8bit', 'T.61', 'iso-ir-103'};
	csISO111ECMACyrillic = {'ECMA-cyrillic', 'iso-ir-111', 'KOI8-E'};
	csISO121Canadian1 = {'CSA_Z243.4-1985-1', 'ca', 'csa71', 'csa7-1', 'iso-ir-121', 'ISO646-CA'};
	csISO122Canadian2 = {'CSA_Z243.4-1985-2', 'csa72', 'csa7-2', 'iso-ir-122', 'ISO646-CA2'};
	csISO123CSAZ24341985gr = {'CSA_Z243.4-1985-gr', 'iso-ir-123'};
	csISO88596E = 'ISO-8859-6-E';
	csISO88596I = 'ISO-8859-6-I';
	csISO128T101G2 = {'T.101-G2', 'iso-ir-128'};
	csISO88598E = 'ISO-8859-8-E';
	csISO88598I = 'ISO-8859-8-I';
	csISO139CSN369103 = {'CSN_369103', 'iso-ir-139'};
	csISO141JUSIB1002 = {'JUS_I.B1.002', 'iso-ir-141', 'ISO646-YU', 'js', 'yu'};
	csISO143IECP271 = {'IEC_P27-1', 'iso-ir-143'};
	csISO146Serbian = {'JUS_I.B1.003-serb', 'iso-ir-146', 'serbian'};
	csISO147Macedonian = {'JUS_I.B1.003-mac', 'macedonian', 'iso-ir-147'};
	csISO150GreekCCITT = {'greek-ccitt', 'iso-ir-150', 'csISO150'};
	csISO151Cuba = {'NC_NC00-10:81', 'cuba', 'iso-ir-151', 'ISO646-CU'};
	csISO6937Add = {'ISO_6937-2-25', 'iso-ir-152'};
	csISO153GOST1976874 = {'GOST_19768-74', 'ST_SEV_358-88', 'iso-ir-153'};
	csISO8859Supp = {'ISO_8859-supp', 'iso-ir-154', 'latin1-2-5'};
	csISO10367Box = {'ISO_10367-box', 'iso-ir-155'};
	csISO158Lap = {'latin-lap', 'lap', 'iso-ir-158'};
	csISO159JISX02121990 = {'JIS_X0212-1990', 'x0212', 'iso-ir-159'};
	csISO646Danish = {'DS_2089', 'DS2089', 'ISO646-DK', 'dk'};
	csUSDK = 'us-dk'; csDKUS = 'dk-us';
	csKSC5636 = {'KSC5636', 'ISO646-KR'};
	csUnicode11UTF7 = 'UNICODE-1-1-UTF-7';
	csISO2022CN	= 'ISO-2022-CN';
	csISO2022CNEXT = 'ISO-2022-CN-EXT';
	csGBK = {'GBK', 'CP936', 'MS936', 'windows-936'};
	csGB18030 = 'GB18030';
	csOSDEBCDICDF0415 = 'OSD_EBCDIC_DF04_15';
	csOSDEBCDICDF03IRV = 'OSD_EBCDIC_DF03_IRV';
	csOSDEBCDICDF041 = 'OSD_EBCDIC_DF04_1';
	csISO115481 = {'ISO-11548-1', 'ISO_11548-1', 'ISO_TR_11548-1'};
	csKZ1048 = {'KZ-1048', 'STRK1048-2002', 'RK1048'};
	csUnicode = 'ISO-10646-UCS-2';
	csUCS4 = 'ISO-10646-UCS-4';
	csUnicodeASCII = 'ISO-10646-UCS-Basic';
	csUnicodeLatin1 = {'ISO-10646-Unicode-Latin1', 'ISO-10646'};
	csUnicodeJapanese = 'ISO-10646-J-1';
	csUnicodeIBM1261 = 'ISO-Unicode-IBM-1261';
	csUnicodeIBM1268 = 'ISO-Unicode-IBM-1268';
	csUnicodeIBM1276 = 'ISO-Unicode-IBM-1276';
	csUnicodeIBM1264 = 'ISO-Unicode-IBM-1264';
	csUnicodeIBM1265 = 'ISO-Unicode-IBM-1265';
	csUnicode11 = 'UNICODE-1-1';
	csSCSU = 'SCSU';
	csUTF7 = 'UTF-7';
	csCESU8 = {'CESU-8', 'csCESU-8'};
	csBOCU1 = {'BOCU-1', 'csBOCU-1'};
	csWindows30Latin1 = 'ISO-8859-1-Windows-3.0-Latin-1';
	csWindows31Latin1 = 'ISO-8859-1-Windows-3.1-Latin-1';
	csWindows31Latin2 = 'ISO-8859-2-Windows-Latin-2';
	csWindows31Latin5 = 'ISO-8859-9-Windows-Latin-5';
	csHPRoman8 = {'hp-roman8', 'roman8', 'r8'};
	csAdobeStandardEncoding = 'Adobe-Standard-Encoding';
	csVenturaUS = 'Ventura-US';
	csVenturaInternational = 'Ventura-International';
	csDECMCS = {'DEC-MCS', 'dec'};
	csPC850Multilingual	 = {'IBM850', 'cp850', '850'};
	csPC8DanishNorwegian = 'PC8-Danish-Norwegian';
	csPC862LatinHebrew = {'IBM862', 'cp862', '862'};
	csPC8Turkish = 'PC8-Turkish';
	csIBMSymbols = 'IBM-Symbols';
	csIBMThai = 'IBM-Thai';
	csHPLegal = 'HP-Legal'; csHPPiFont = 'HP-Pi-font'; csHPMath8 = 'HP-Math8';
	csHPPSMath = 'Adobe-Symbol-Encoding';
	csHPDesktop = 'HP-DeskTop';
	csVenturaMath = 'Ventura-Math';
	csMicrosoftPublishing = 'Microsoft-Publishing';
	csWindows31J = 'Windows-31J';
	csGB2312 = 'GB2312';
	csBig5 = 'Big5';
	csMacintosh	= {'macintosh', 'mac'};
	csIBM037 = {'IBM037', 'cp037', 'ebcdic-cp-us', 'ebcdic-cp-ca', 'ebcdic-cp-wt', 'ebcdic-cp-nl'};
	csIBM038 = {'IBM038', 'cp038'};
	csIBM273 = {'IBM273', 'CP273'};
	csIBM274 = {'IBM274', 'EBCDIC-BE', 'CP274'};
	csIBM275 = {'IBM275', 'EBCDIC-BR', 'cp275'};
	csIBM277 = {'IBM277', 'EBCDIC-CP-DK', 'EBCDIC-CP-NO'};
	csIBM278 = {'IBM278', 'CP278', 'ebcdic-cp-fi', 'ebcdic-cp-se'};
	csIBM280 = {'IBM280', 'CP280', 'ebcdic-cp-it'};
	csIBM281 = {'IBM281', 'EBCDIC-JP-E', 'cp281'};
	csIBM284 = {'IBM284', 'CP284', 'ebcdic-cp-es'};
	csIBM285 = {'IBM285', 'CP285', 'ebcdic-cp-gb'};
	csIBM290 = {'IBM290', 'cp290', 'EBCDIC-JP-kana'};
	csIBM297 = {'IBM297', 'cp297', 'ebcdic-cp-fr'};
	csIBM420 = {'IBM420', 'cp420', 'ebcdic-cp-ar1'};
	csIBM423 = {'IBM423', 'cp423', 'ebcdic-cp-gr'};
	csIBM424 = {'IBM424', 'cp424', 'ebcdic-cp-he'};
	csPC8CodePage437 = {'IBM437', 'cp437', '437'};
	csIBM500 = {'IBM500', 'CP500', 'ebcdic-cp-be', 'ebcdic-cp-ch'};
	csIBM851 = {'IBM851', 'cp851', '851'};
	csPCp852 = {'IBM852', 'cp852', '852'};
	csIBM855 = {'IBM855', 'cp855', '855'};
	csIBM857 = {'IBM857', 'cp857', '857'};
	csIBM860 = {'IBM860', 'cp860', '860'};
	csIBM861 = {'IBM861', 'cp861', '861', 'cp-is'};
	csIBM863 = {'IBM863', 'cp863', '863'};
	csIBM864 = {'IBM864', 'cp864'};
	csIBM865 = {'IBM865', 'cp865', '865'};
	csIBM868 = {'IBM868', 'CP868', 'cp-ar'};
	csIBM869 = {'IBM869', 'cp869', '869', 'cp-gr'};
	csIBM870 = {'IBM870', 'CP870', 'ebcdic-cp-roece', 'ebcdic-cp-yu'};
	csIBM871 = {'IBM871', 'CP871', 'ebcdic-cp-is'};
	csIBM880 = {'IBM880', 'cp880', 'EBCDIC-Cyrillic'};
	csIBM891 = {'IBM891', 'cp891'};
	csIBM903 = {'IBM903', 'cp903'};
	csIBBM904 = {'IBM904', 'cp904', '904'};
	csIBM905 = {'IBM905', 'CP905', 'ebcdic-cp-tr'};
	csIBM918 = {'IBM918', 'CP918', 'ebcdic-cp-ar2'};
	csIBM1026 = {'IBM1026', 'CP1026'};
	csIBMEBCDICATDE	= 'EBCDIC-AT-DE'; csEBCDICATDEA = 'EBCDIC-AT-DE-A'; csEBCDICCAFR = 'EBCDIC-CA-FR';
	csEBCDICDKNO = 'EBCDIC-DK-NO'; csEBCDICDKNOA = 'EBCDIC-DK-NO-A'; csEBCDICFISE = 'EBCDIC-FI-SE';
	csEBCDICFISEA = 'EBCDIC-FI-SE-A';
	csEBCDICFR = 'EBCDIC-FR'; csEBCDICIT = 'EBCDIC-IT'; csEBCDICPT = 'EBCDIC-PT'; csEBCDICES = 'EBCDIC-ES';
	csEBCDICESA	= 'EBCDIC-ES-A'; csEBCDICESS = 'EBCDIC-ES-S';
	csEBCDICUK = 'EBCDIC-UK'; csEBCDICUS = 'EBCDIC-US';
	csUnknown8BiT = 'UNKNOWN-8BIT';
	csMnemonic = 'MNEMONIC';
	csMnem = 'MNEM';
	csVISCII = 'VISCII';
	csVIQR = 'VIQR';
	csKOI8R	= 'KOI8-R';
	['HZ-GB-2312'] = 'HZ-GB-2312';
	csIBM866 = {'IBM866', 'cp866', '866'};
	csPC775Baltic = {'IBM775', 'cp775'};
	csKOI8U	= 'KOI8-U';
	csIBM00858 = {'IBM00858', 'CCSID00858', 'CP00858', 'PC-Multilingual-850+euro'};
	csIBM00924 = {'IBM00924', 'CCSID00924', 'CP00924', 'ebcdic-Latin9--euro'};
	csIBM01140 = {'IBM01140', 'CCSID01140', 'CP01140', 'ebcdic-us-37+euro'};
	csIBM01141 = {'IBM01141', 'CCSID01141', 'CP01141', 'ebcdic-de-273+euro'};
	csIBM01142 = {'IBM01142', 'CCSID01142', 'CP01142', 'ebcdic-dk-277+euro', 'ebcdic-no-277+euro'};
	csIBM01143 = {'IBM01143', 'CCSID01143', 'CP01143', 'ebcdic-fi-278+euro', 'ebcdic-se-278+euro'};
	csIBM01144 = {'IBM01144', 'CCSID01144', 'CP01144', 'ebcdic-it-280+euro'};
	csIBM01145 = {'IBM01145', 'CCSID01145', 'CP01145', 'ebcdic-es-284+euro'};
	csIBM01146 = {'IBM01146', 'CCSID01146', 'CP01146', 'ebcdic-gb-285+euro'};
	csIBM01147 = {'IBM01147', 'CCSID01147', 'CP01147', 'ebcdic-fr-297+euro'};
	csIBM01148 = {'IBM01148', 'CCSID01148', 'CP01148', 'ebcdic-international-500+euro'};
	csIBM01149 = {'IBM01149', 'CCSID01149', 'CP01149', 'ebcdic-is-871+euro'};
	csBig5HKSCS = 'Big5-HKSCS';
	csIBM1047 = {'IBM1047', 'IBM-1047'};
	csPTCP154 = {'PTCP154', 'PT154', 'CP154', 'Cyrillic-Asian'};
	csAmiga1251 = {'Amiga-1251', 'Ami1251', 'Amiga1251', 'Ami-1251'};
	csKOI7switched = 'KOI7-switched';
	csBRF = 'BRF';
	csTSCII = 'TSCII';
	csCP51932 = 'CP51932'; csCP50220 = 'CP50220';

}
