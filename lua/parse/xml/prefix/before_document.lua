
-- NOT including declaration

local re = require 're'

return re.compile([[

	prefix_prolog <- {| misc* (doctype misc*)? |} {}

	misc <- %COMMENT / %C_PI / %s+

	doctype <- '<!DOCTYPE' {|
					%s+
					{:name: %NAME :}
					(%s+ external_id)?
					%s*
					('[' (markupdecl / declsep)* ']' %s*)?
					{:type: ''->'doctype':}
				|} '>'

	external_id <- ('SYSTEM' %s+ system_literal) /
	               ('PUBLIC' %s+ pubid_literal %s+ system_literal)

	system_literal <- (["] { [^"]*       } ["]) / (['] { [^']*              } ['])
	pubid_literal  <- (["] { pubid_char* } ["]) / (['] { (!['] pubid_char)* } ['])
	pubid_char <- [ a-zA-Z0-9-'()+,./:=?;!*#@$_%] / %BREAK_LINE

	markupdecl <- elementdecl / AttlistDecl / EntityDecl / NotationDecl / %C_PI / %COMMENT

	declsep <- %s+ / PEReference

	PEReference <- '%' {| {:name: %NAME :} {:type: ''->'PEReference' :} |} ';'

	elementdecl <- '<!ELEMENT' {| %s+ {:name: %NAME :} %s+ contentspec %s* {:type:''->'elementdecl':}|} '>'

	contentspec <- contentspec_empty / contentspec_any / children
	contentspec_empty <- 'EMPTY' {:content_type:''->'empty':}
	contentspec_any <- 'ANY' {:content_type:''->'any':}
	children <- (
		{:children: {| (choice / seq) {:modifier: [?*+] :}? |} :}
		{:content_type: '' -> 'children' :}
	)
	choice <- '(' %s* cp (%s* '|' %s* cp)+ %s* ')' {:type:''->'choice':}
	seq    <- '(' %s* cp (%s* ',' %s* cp)* %s* ')' {:type:''->'seq':}
	cp <- {| (named / pcdata / choice / seq) {:modifier: [?*+] :}? |}
	named <- {:name: %NAME :} {:type:''->'named':}
	pcdata <- '#PCDATA' {:type: ''->'pcdata' :}

	AttlistDecl <- '<!ATTLIST' {| %s+ {:name: %NAME :} {| AttDef |}* %s* {:type:''->'AttlistDecl':} |} '>'
	AttDef <- %s+ {:name: %NAME :} %s+ AttType %s+ DefaultDecl
	AttType <- StringType / TokenizedType / EnumeratedType
	StringType <- {:type: 'CDATA' :}
	TokenizedType <- {:type: 'ID' / 'IDREF' / 'IDREFS' / 'ENTITY' / 'ENTITIES' / 'NMTOKEN' / 'NMTOKENS' :}
	EnumeratedType <- NotationType / Enumeration
	NotationType <- 'NOTATION' %s+ '(' %s* {%NAME} (%s* '|' %s* {%NAME})* %s* ')' {:type: ''->'notation':}
	Enumeration <- '(' %s* Nmtoken (%s* '|' %s* Nmtoken)* %s* ')' {:type: ''->'enumeration' :}
	Nmtoken <- %NAME_CHAR+
	DefaultDecl <- '#REQUIRED' / '#IMPLIED' / (('#FIXED' %s+)? AttValue)
	AttValue <- (["] ([^<&"] / Reference)* ["])
	          / (['] ([^<&'] / Reference)* ['])

	EntityDecl <- GEDecl / PEDecl
	GEDecl <- '<!ENTITY' %s+ {| {:name: %NAME :} %s+ EntityDef %s* |} '>'
	PEDecl <- '<!ENTITY' %s+ {| '%' {:name: %NAME :} %s+ PEDef %s* |} '>'

	EntityDef <- EntityValue / (external_id NDataDecl?)
	PEDef <- EntityValue / external_id
	EntityValue <- (
		(["] ([^%&"] / PEReference / Reference)* ["])
		/
		(['] ([^%&'] / PEReference / Reference)* ['])
	)
	NDataDecl <- %s+ 'NDATA' %s+ %NAME
	Reference <- EntityRef / CharRef
	EntityRef <- '&' %NAME ';'
	CharRef <- ('&#' [0-9]+ ';') / ('&#x' [0-9a-fA-F]+ ';')

	NotationDecl <- '<!NOTATION' %s+ %NAME %s+ (external_id / public_id) %s+ '>'

	public_id <- 'PUBLIC' %s+ pubid_literal

]], {
	COMMENT = require 'parse.match.comment.xml';
	C_PI = require 'parse.xml.read.processing_instruction';
	NAME = require 'parse.match.identifier.xml';
	NAME_CHAR = require 'parse.match.identifier.xml.char';
	BREAK_LINE = require 'parse.char.ascii7.break_line';
})
