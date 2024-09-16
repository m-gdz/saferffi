module lang::rust::\syntax::Ferrocene

layout NoCurlyBefore 
  = @manual [}] !<< WhiteSpaceOrComment* !>> [\ \t\r\n] !>> "//" !>> "/*"
  ;

layout Whitespace 
	= WhiteSpaceOrComment* !>> [\ \t\r\n] !>> "//" !>> "/*"
	;

lexical WhiteSpaceOrComment
	= [\ \t \r \n]
	| Comment
	;

// UNSURE An AsciiCharacter is any Unicode character in the range 0x00 - 0x7F, both inclusive.
lexical AsciiCharacter
    = [\u0000-\u007F]
    ;

// #### 2. Lexical ArrayElements #####



// 2.2 Lexical Elements, Separators, and Punctuation
lexical LexicalElement
    = Comment
    | Identifier
    | Keyword
    | Literal
    | Punctuation
    ;

lexical Punctuation
    = Delimiter
    | "+" | "-" | "*" | "/" | "%" | "^" | "!" | "&" | "|" | "&&" | "||" | "\<\<" | "\>\>" | "+=" | "-=" | "*=" | "/=" | "%=" | "^=" | "&=" | "|=" | "\<\<=" | "\>\>=" | "=" | "==" | "!=" | "\>" | "\<" | "\>=" | "\<=" | "@" | "_" | "." | ".." | "..." | "..=" | "," | ";" | ":" | "::" | "-\>" | "=\>" | "=\>" | "#" | "$" | "?" 
    ;

lexical Delimiter
    = "{" | "}" | "[" | "]" | "(" | ")" 
    ;

// 2.3 Identifiers

syntax Identifier
    = NonKeywordIdentifier
    | RawIdentifier
    ;

lexical IdentifierList
    = {Identifier ","}+ ","?
    ;

lexical NonKeywordIdentifier 
    = PureIdentifier \ Keyword
    ;

lexical RawIdentifier
    = "r#" (PureIdentifier | RawIdentifierKeyword)
    ;

lexical PureIdentifier
    = [a-zA-Z] [a-zA-Z0-9_]*
    | "_" [a-zA-Z0-9_]+
    ;

lexical IdentifierOrUnderscore
    = Identifier
    | "_"
    ;

syntax Renaming
    = "as" IdentifierOrUnderscore
    ;

// Simplified XID
lexical XID_Start
    = [a-z]  // Lowercase letters
    | [A-Z]  // Uppercase letters
    // | [\u00C0-\u00D6]  // À-Ö (Latin-1 Supplement)
    // | [\u00D8-\u00F6]  // Ø-ö (Latin-1 Supplement)
    // | [\u00F8-\u00FF]  // ø-ÿ (Latin-1 Supplement)
    // | [\u0100-\u017F]  // Extended Latin-1
    // | [\u0400-\u04FF]  // Cyrillic
    // | [\u0530-\u058F]  // Armenian
    // | [\u0600-\u06FF]  // Arabic
    // | [\u0900-\u097F]  // Devanagari
    // | [\u3040-\u309F]  // Hiragana
    // | [\u30A0-\u30FF]  // Katakana
    // | [\u4E00-\u9FFF]  // CJK Unified Ideographs
    // | [\uF900-\uFAFF]  // CJK Compatibility Ideographs
    // | [\u1F600-\u1F64F] // Emoji (smileys)
    ; 

lexical XID_Continue 
    = XID_Start
    | [_0-9]  // Digits
    ;

// UNSURE A RawIdentifierKeyword is any keyword in category Keyword, except crate, self, Self, and super.
lexical RawIdentifierKeyword 
    = Keyword \ ("crate" | "self" | "Self" | "super")
    ; 

// 2.4 Literals

lexical Literal
    = BooleanLiteral
    | ByteLiteral
    | ByteStringLiteral
    | CStringLiteral
    | CharacterLiteral
    | NumericLiteral
    | StringLiteral
    ;

// 2.4.1 Byte literals

lexical ByteLiteral
    = "b\'" ByteContent "\'"
    ;

lexical ByteContent
    = ByteCharacter
    | ByteEscape
    ;

lexical ByteCharacter
    = AsciiCharacter \ ('\u0009'| '\u000A'| '\u000D'| '\u0027'| '\u005C')
    ;

lexical ByteEscape
    = "\\" ByteEscapeSequence
    ;

lexical ByteEscapeSequence
    = '0'
    | '\"'
    | '\''
    | 't'
    | 'n'
    | 'r'
    | '\\'
    | 'x' HexadecimalDigit HexadecimalDigit
    ;

lexical ByteStringLiteral
    = "b\"" ![\"]* "\""
    ;

lexical ByteStringContent
    = //ByteEscape
    | SimpleByteStringCharacter
    ;

lexical SimpleByteStringCharacter
    = AsciiCharacter \ ('\u000D'|'\u0022'| '\u005C' | "\"")
    ;


lexical RawByteStringLiteral
    = "br" RawByteStringContent
    ;

lexical RawByteStringContent
    = NestedRawByteStringContent
    | "\"" AsciiCharacter* "\""
    ;

lexical NestedRawByteStringContent
    = "#" RawByteStringContent "#"
    ;

// 2.4.3 C String Literals

lexical CStringLiteral
    = RawCStringLiteral
    | SimpleCStringLiteral
    ;

lexical SimpleCStringLiteral
    = "c\"" SimpleCStringContent* "\""
    ;

lexical SimpleCStringContent
    = AsciiEscape
    | SimpleStringCharacter
    | StringContinuation
    | UnicodeEscape
    ;

lexical RawCStringLiteral
    = "cr" RawCStringContent
    ;

lexical RawCStringContent
    = NestedRawCStringContent
    | "\"" ![\r]* "\"" // UNSURE Not sure ~[\r]*
    ;

lexical NestedRawCStringContent
    = "#" RawCStringContent "#"
    ;

// 2.4.4 Numeric Literals

lexical NumericLiteral
    = FloatLiteral
    | IntegerLiteral
    ;

lexical IntegerLiteral
    = IntegerContent IntegerSuffix?
    ;

lexical IntegerContent
    = BinaryLiteral
    | DecimalLiteral
    | HexadecimalLiteral
    | OctalLiteral
    ;

lexical BinaryLiteral
    = "0b" BinaryDigitOrUnderscore* BinaryDigit BinaryDigitOrUnderscore*
    ;

lexical BinaryDigitOrUnderscore
    = BinaryDigit
    | "_"
    ;

lexical BinaryDigit
    = [0-1]
    ;

lexical DecimalLiteral
    = DecimalDigit DecimalDigitOrUnderscore*
    ;

lexical DecimalDigitOrUnderscore
    = DecimalDigit
    | "_"
    ;

lexical DecimalDigit
    = [0-9]
    ;

lexical HexadecimalLiteral
    = "0x" HexadecimalDigitOrUnderscore* HexadecimalDigit HexadecimalDigitOrUnderscore*
    ;

lexical HexadecimalDigitOrUnderscore
    = HexadecimalDigit
    | "_"
    ;

lexical HexadecimalDigit
    = [0-9 a-f A-F]
    ;

lexical OctalLiteral
    = "0o" OctalDigitOrUnderscore* OctalDigit OctalDigitOrUnderscore*
    ;

lexical OctalDigitOrUnderscore
    = OctalDigit
    | "_"
    ;

lexical OctalDigit
    = [0-7]
    ;

lexical IntegerSuffix
    = SignedIntegerSuffix
    | UnsignedIntegerSuffix
    ;

lexical SignedIntegerSuffix
    = "i8"
    | "i16"
    | "i32"
    | "i64"
    | "i128"
    | "isize"
    ;

lexical UnsignedIntegerSuffix
    = "u8"
    | "u16"
    | "u32"
    | "u64"
    | "u128"
    | "usize"
    ;

lexical FloatLiteral
    = DecimalLiteral "."
    | DecimalLiteral FloatExponent
    | DecimalLiteral "." DecimalLiteral FloatExponent?
    | DecimalLiteral ("." DecimalLiteral)? FloatExponent? FloatSuffix
    ;

lexical FloatExponent
    = ExponentLetter ExponentSign? ExponentMagnitude
    ;

lexical ExponentLetter
    = "e" | "E"
    ;

lexical ExponentSign
    = "+" | "-"
    ;

lexical ExponentMagnitude
    = DecimalDigitOrUnderscore* DecimalDigit DecimalDigitOrUnderscore*
    ;

lexical FloatSuffix
    = "f32" | "f64"
    ;

lexical CharacterLiteral
    = "\'" CharacterContent "\'"
    ;

lexical CharacterContent
    = AsciiEscape
    | CharacterLiteralCharacter
    | UnicodeEscape
    ;

lexical AsciiEscape
    = "\\0"
    | "\\\""
    | "\\\'"
    | "\\t"
    | "\\n"
    | "\\r"
    | "\\\\"
    | "\\x" OctalDigit HexadecimalDigit
    ;

// UNSURE 
lexical CharacterLiteralCharacter
    = ![\u000A \u000D \u0027 \u005C]
    ;

// UNSURE A UnicodeEscape starts with a \u{ literal, followed by 1 to 6 instances of a HexadecimalDigit, inclusive, followed by a } character. It can represent any Unicode codepoint between U+00000 and U+10FFFF, inclusive, except Unicode surrogate codepoints, which exist between the range of U+D800 and U+DFFF, inclusive.
lexical UnicodeEscape
    = "\\u{" HexadecimalDigit "}"
    | "\\u{" HexadecimalDigit HexadecimalDigit "}"
    | "\\u{" HexadecimalDigit HexadecimalDigit HexadecimalDigit "}"
    | "\\u{" HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit "}"
    | "\\u{" HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit "}"
    | "\\u{" HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit HexadecimalDigit "}"
    ;

// 2.4.6 String Literals

lexical StringLiteral
    = RawStringLiteral
    | SimpleStringLiteral
    ;

lexical SimpleStringLiteral
    = "\"" SimpleStringContent* "\""
    ;

lexical SimpleStringContent
    = AsciiEscape
    | SimpleStringCharacter
    | StringContinuation
    | UnicodeEscape
    ;

// UNSURE A SimpleStringCharacter is any Unicode character except characters 0x0D (carriage return), 0x22 (quotation mark), and 0x5C (reverse solidus).
lexical SimpleStringCharacter
    = ![\u000D \u0022 \u005C] // Not sure about what is "any character" in the doc
    ;

lexical StringContinuation // UNSURE StringContinuation is the character sequence 0x5C 0x0A (reverse solidus, new line).
    = "\u005C\u000A" // Whitespace ?
    ;

lexical RawStringLiteral
    = "r" RawStringContent
    ;

lexical RawStringContent // UNSURE
    = NestedRawStringContent
    | "\"" ![\r]* "\""
    ;

lexical NestedRawStringContent
    = "#" RawStringContent "#"
    ;

// 2.4.7 Boolean Literals

lexical BooleanLiteral
    = "true" | "false"
    ;

// 2.5 Comments ## A revoir

lexical Comment
    = BlockCommentOrDoc
    | LineCommentOrDoc
    ;

lexical BlockCommentOrDoc
    = BlockComment
    | InnerBlockDoc
    | OuterBlockDoc
    ;

lexical LineCommentOrDoc
    = LineComment
    | InnerLineDoc
    | OuterLineDoc
    ;

lexical LineComment
    = "//" ![\n]* $
    //| "//" (![!/] | "//") ![\n]*
    ;

lexical BlockComment // UNSURE Probably wrong
    = "/*" CommentStuff*  "*/"
    | "/**/"
    | "/***/"
    ;

lexical CommentStuff
  = BlockCommentOrDoc 
  | ![*/]
  | [*] !>> [/]
  | [/] !<< [*] 
  ;

lexical InnerBlockDoc // UNSURE Probably wrong
    = "/*!" (BlockCommentOrDoc | "")* "*/"
    ;

lexical InnerLineDoc
    = "//!" ![\n \r]*
    ;

lexical OuterBlockDoc // UNSURE Probably wrong, should be /** (~[*] | BlockCommentOrDoc) (BlockCommentOrDoc | ~[*/ \r])* */
    = "/**" (![*] | BlockCommentOrDoc) (BlockCommentOrDoc | ![\u0000])* "*/"
    ;

lexical OuterLineDoc
    = "///" (![/]![\n\r]*)? //UNSURE
    ;

// 2.6 Keywords

keyword Keyword
    = "as"
    | "async"
    | "await"
    | "break"
    | "const"
    | "continue"
    | "crate"
    | "dyn"
    | "enum"
    | "extern"
    | "false"
    | "fn"
    | "for"
    | "if"
    | "impl"
    | "in"
    | "let"
    | "loop"
    | "match"
    | "mod"
    | "move"
    | "mut"
    | "pub"
    | "ref"
    | "return"
    | "self"
    | "Self"
    | "static"
    | "struct"
    | "super"
    | "trait"
    | "true"
    | "type"
    | "unsafe"
    | "use"
    | "where"
    | "while"
    | "abstract"
    | "become"
    | "box"
    | "do"
    | "final"
    | "macro"
    | "override"
    | "priv"
    | "try"
    | "typeof"
    | "unsized"
    | "virtual"
    | "yield"
    | "macro_rules"
    | "\'static"
    | "union"
    ;

// #### 3. Items ####

syntax Items = Item* items;

syntax Item
    = OuterAttributeOrDoc* (ItemWithVisibility | MacroItem)
    ;

syntax ItemWithVisibility
    = VisibilityModifier? (
        ConstantDeclaration
    | EnumDeclaration
    | ExternalBlock
    | ExternalCrateImport
    | FunctionDeclaration
    | Implementation
    | ModuleDeclaration
    | StaticDeclaration
    | StructDeclaration
    | TraitDeclaration
    | TypeAliasDeclaration
    | UnionDeclaration
    | UseImport
    )
    ;

syntax MacroItem
    = MacroRulesDeclaration
    | TerminatedMacroInvocation
    ;

// #### 4. Types and traits ####

// 4.1 Types

syntax TypeSpecification
    = ImplTraitTypeSpecification
    | TraitObjectTypeSpecification
    | TypeSpecificationWithoutBounds
    ;

syntax TypeSpecificationList
    = {TypeSpecification ","}+ ","?
    ;

syntax TypeSpecificationWithoutBounds
    = ArrayTypeSpecification
    | FunctionPointerTypeSpecification
    | ImplTraitTypeSpecificationOneBound
    | InferredType
    | MacroInvocation
    | NeverType
    | ParenthesizedTypeSpecification
    | QualifiedTypePath
    | RawPointerTypeSpecification
    | ReferenceTypeSpecification
    | SliceTypeSpecification
    | TraitObjectTypeSpecificationOneBound
    | TupleTypeSpecification
    | TypePath
    ;

syntax TypeAscription
    = ":" TypeSpecification
    ;

// 4.4 Sequence Types

syntax ArrayTypeSpecification
    = "[" ElementType ";" SizeOperand "]"
    ;

syntax ElementType
    = TypeSpecification
    ;

syntax SliceTypeSpecification
    = "[" ElementType "]"
    ;

syntax TupleTypeSpecification
    = "(" TupleFieldList? ")"
    ;

syntax TupleFieldList
    = {TupleField ","}+ ","?
    ;

syntax TupleField
    = TypeSpecification
    ;

// 4.5 Abstract Data Types

// 4.5.1 Enum Types

syntax EnumDeclaration
    = "enum" Name GenericParameterList? WhereClause? "{" EnumVariantList? "}"
    ;

syntax EnumVariantList
    = {EnumVariant ","}+ ","?
    ;

syntax EnumVariant
    = OuterAttributeOrDoc* VisibilityModifier? Name EnumVariantKind?
    ;

syntax EnumVariantKind
    = DiscriminantInitializer
    | RecordStructFieldList
    | TupleStructFieldList
    ;

syntax DiscriminantInitializer
    = "=" Expression
    ;

// 4.5.2 Struct Types

syntax StructDeclaration
    = RecordStructDeclaration
    | TupleStructDeclaration
    | UnitStructDeclaration
    ;

syntax RecordStructDeclaration
    = "struct" Name GenericParameterList? WhereClause? RecordStructFieldList
    ;

syntax RecordStructFieldList
    = "{" ({RecordStructField ","}+ ","?)? "}"
    ;

syntax RecordStructField
    = OuterAttributeOrDoc* VisibilityModifier? Name TypeAscription
    ;

syntax TupleStructDeclaration
    = "struct" Name GenericParameterList? TupleStructFieldList WhereClause? ";"
    ;

syntax TupleStructFieldList
    = "(" ({TupleStructField ","}+ ","?)? ")"
    ;

syntax TupleStructField
    = OuterAttributeOrDoc* VisibilityModifier? TypeSpecification
    ;

syntax UnitStructDeclaration
    = "struct" Name GenericParameterList? WhereClause? ";"
    ;

// 4.5.3 Union Types

syntax UnionDeclaration
    = "union" Name GenericParameterList? WhereClause? RecordStructFieldList
    ;



// 4.7 Indirection Types

syntax FunctionPointerTypeSpecification
    = ForGenericParameterList? FunctionPointerTypeQualifierList "fn"
    "(" FunctionPointerTypeParameterList? ")" ReturnTypeWithoutBounds?
    ;

syntax FunctionPointerTypeQualifierList
    = "unsafe"? AbiSpecification?
    ;

syntax FunctionPointerTypeParameterList
    = FunctionPointerTypeParameter ("," FunctionPointerTypeParameter)*
    (("," VariadicPart) | ","?)
    ;

syntax VariadicPart
    = OuterAttributeOrDoc* "..."
    ;

syntax FunctionPointerTypeParameter
    = OuterAttributeOrDoc* (IdentifierOrUnderscore ":")? TypeSpecification
    ;

// 4.7.2 Raw Pointer Types

syntax RawPointerTypeSpecification
    = "*" ("const" | "mut") TypeSpecificationWithoutBounds
    ;

// 4.7.3 Reference Types

syntax ReferenceTypeSpecification
    = "&" LifetimeIndication? "mut"? TypeSpecificationWithoutBounds
    ;


// 4.8 Trait Types

// 4.8.1 Impl Trait Types

syntax ImplTraitTypeSpecification
    = "impl" TypeBoundList
    ;

syntax ImplTraitTypeSpecificationOneBound
    = "impl" TraitBound
    ;

// 4.8.2 Trait Object Types

syntax TraitObjectTypeSpecification
    = "dyn" TypeBoundList
    ;

syntax TraitObjectTypeSpecificationOneBound
    = "dyn" TraitBound
    ;


// 4.9 Other Types

// 4.9.1 Inferred Types

syntax InferredType
    = "_"
    ;

// 4.9.3 Never Type
syntax NeverType
    = "!"
    ;

// 4.9.4 Parenthesized Types
syntax ParenthesizedTypeSpecification
    = "(" TypeSpecification ")"
    ;

// 4.10 Type Aliases
syntax TypeAliasDeclaration
    = "type" Name GenericParameterList? (":" TypeBoundList)? WhereClause?
      ("=" InitializationType WhereClause?)? ";"
    ;

syntax InitializationType
    = TypeSpecification
    ;

// 4.11 Representation IMPORTANT ??


// 4.12 Type Model

// 4.13 Traits

syntax TraitDeclaration
    = "unsafe"? "trait" Name GenericParameterList? (":" SupertraitList?)? WhereClause? TraitBody
    ;

syntax SupertraitList
    = TypeBoundList
    ;

syntax TraitBody
    = "{" 
        InnerAttributeOrDoc* 
        AssociatedItem* 
    "}"
    ;

// 4.14 Trait and Lifetime Bounds

syntax TypeBoundList
    = TypeBound ("+" TypeBound)* "+"?
    ;

syntax TypeBound
    = LifetimeIndication
    | ParenthesizedTraitBound
    | TraitBound
    ;

syntax LifetimeIndication
    = Lifetime
    | "\'_"
    | "\'static"
    ;

syntax LifetimeIndicationList
    = {LifetimeIndication "+"}+ "+"?
    ;

syntax ParenthesizedTraitBound
    = "(" TraitBound ")"
    ;

syntax TraitBound
    = "?"? ForGenericParameterList? TypePath
    ;

syntax ForGenericParameterList
    = "for" GenericParameterList
    ;

// 4.14.1 Lifetimes
syntax Lifetime
    = "\'" NonKeywordIdentifier
    ;

syntax AttributedLifetime
    = OuterAttributeOrDoc* Lifetime
    ;

syntax AttributedLifetimeList
    = {AttributedLifetime ","}+ ","?
    ;


// #### 5. Patterns ####

syntax Pattern
    = "|"? {PatternWithoutAlternation "|"}+
    ;

syntax PatternList
    = {Pattern ","}+ ","?
    ;

syntax PatternWithoutAlternation
    = PatternWithoutRange
    | RangePattern
    ;

syntax PatternWithoutRange
    = IdentifierPattern
    | LiteralPattern
    | MacroInvocation
    | ParenthesizedPattern
    | pathPat: PathPattern
    | ReferencePattern
    | RestPattern
    | SlicePattern
    | StructPattern
    | TuplePattern
    | "_"
    ;

// 5.1.1 Identifier Patterns
syntax IdentifierPattern
    = "ref"? "mut"? Binding BoundPattern?
    ;

syntax BoundPattern
    = "@" Pattern
    ;

// 5.1.2 Literal Patterns
syntax LiteralPattern
    = BooleanLiteral
    | ByteLiteral
    | ByteStringLiteral
    | CharacterLiteral
    | "-"? NumericLiteral
    | RawByteStringLiteral
    | RawStringLiteral
    | SimpleStringLiteral
    ;

// 5.1.3 Parenthesized Patterns
syntax ParenthesizedPattern
    = "(" Pattern ")"
    ;

//5.1.4 Path Patterns
syntax PathPattern
    = PathExpression
    | QualifiedPathExpression
    ;

// 5.1.5 Range Patterns

syntax RangePattern
    = HalfOpenRangePattern
    | InclusiveRangePattern
    | ObsoleteRangePattern
    ;

syntax HalfOpenRangePattern
    = RangePatternLowBound ".."
    ;

syntax InclusiveRangePattern
    = RangePatternLowBound "..=" RangePatternHighBound
    ;

syntax ObsoleteRangePattern
    = RangePatternLowBound "..." RangePatternHighBound
    ;

syntax RangePatternLowBound
    = RangePatternBound
    ;

syntax RangePatternHighBound
    = RangePatternBound
    ;

syntax RangePatternBound
    = ByteLiteral
    | CharacterLiteral
    | "-"? NumericLiteral
    | PathExpression
    | QualifiedPathExpression
    ;

// 5.1.6 Reference Patterns

syntax ReferencePattern
    = "&" "mut"? PatternWithoutRange
    ;

// 5.1.7 Rest Patterns

syntax RestPattern
    = ".."
    ;

// 5.1.8 Slice Patterns

syntax SlicePattern
    = "[" PatternList? "]"
    ;

// 5.2 Struct Patterns

syntax StructPattern
    = RecordStructPattern
    | TupleStructPattern
    ;

syntax Deconstructee
    = PathExpression
    ;

// 5.2.1 Record Struct Patterns
syntax RecordStructPattern
    = Deconstructee "{" RecordStructPatternContent? "}"
    ;

syntax RecordStructPatternContent
    = RecordStructRestPattern
    | FieldDeconstructorList (("," RecordStructRestPattern)| ",")?
    ;

syntax RecordStructRestPattern
    = OuterAttributeOrDoc* RestPattern
    ;

syntax FieldDeconstructorList
    = {FieldDeconstructor ","}+
    ;

syntax FieldDeconstructor
    = OuterAttributeOrDoc* (
          IndexedDeconstructor
        | NamedDeconstructor
        | ShorthandDeconstructor
      )
    ;

syntax IndexedDeconstructor
    = FieldIndex ":" Pattern
    ;

syntax NamedDeconstructor
    = Identifier ":" Pattern
    ;

syntax ShorthandDeconstructor
    = "ref"? "mut"? Binding
    ;

syntax FieldIndex
    = DecimalLiteral
    ;

// 5.2.2 Tuple Struct Patterns
syntax TupleStructPattern
    = Deconstructee "(" PatternList? ")"
    ;

// 5.2.3 Tuple Patterns
syntax TuplePattern
    = "(" PatternList? ")"
    ;



// 5.3 Bindings Modes
syntax Binding
    = Name
    ;

// #### 6. Expressions ####
syntax Expression
    = ExpressionWithBlock
    | ExpressionWithoutBlock
    ;

syntax ExpressionWithBlock
    = OuterAttributeOrDoc* (
          AsyncBlockExpression
        | BlockExpression
        | ConstBlockExpression
        | IfExpression
        | IfLetExpression
        | LoopExpression
        | MatchExpression
        | UnsafeBlockExpression
        | NamedBlockExpression
      )
    ;

syntax ExpressionWithoutBlock
    = OuterAttributeOrDoc* (
          ArrayExpression
        | AwaitExpression
        | BreakExpression
        | CallExpression
        | ClosureExpression
        | ContinueExpression
        | FieldAccessExpression
        | IndexExpression
        | LiteralExpression
        | MethodCallExpression
        | MacroInvocation
        | OperatorExpression
        | ParenthesizedExpression
        | PathExpression
        | RangeExpression
        | ReturnExpression
        | StructExpression
        | TupleExpression
        | UnderscoreExpression
      )
    ;

syntax ExpressionList
    = {Expression ","}+ ","?
    ;

syntax Operand
    = Expression
    ;

syntax LeftOperand
    = Operand
    ;

syntax RightOperand
    = Operand
    ;

// WRONG A SubjectExpression is any expression in category Expression, except StructExpression.
syntax SubjectExpression
    = Expression
    ;

// WRONG A SubjectLetExpression is any expression in category SubjectExpression, except LazyBooleanExpression.
syntax SubjectLetExpression
    = SubjectExpression
    ;


// 6.2 Literal Expressions

syntax LiteralExpression
    = Literal
    ;

// 6.3 Path Expressions
syntax PathExpression
    = UnqualifiedPathExpression
    | QualifiedPathExpression
    ;


// 6.4 Block Expressions
syntax BlockExpression
    = "{" 
        InnerAttributeOrDoc* 
        StatementList 
    "}"
    ;

syntax StatementList
    = Statement* Expression?
    ;


// 6.4.1 Async Blocks
syntax AsyncBlockExpression
    = "async" "move"? BlockExpression
    ;

// 6.4.2 Const Blocks
syntax ConstBlockExpression
    = "const" BlockExpression
    ;

// 6.4.3 Named Blocks
syntax NamedBlockExpression
    = Label BlockExpression
    ;

// 6.4.4 Unsafe Blocks
syntax UnsafeBlockExpression
    = "unsafe" BlockExpression
    ;

// 6.5 Operator Expressions
syntax OperatorExpression
    = ArithmeticExpression
    | AssignmentExpression
    | BitExpression
    | BorrowExpression
    | ComparisonExpression
    | CompoundAssignmentExpression
    | DereferenceExpression
    | ErrorPropagationExpression
    | LazyBooleanExpression
    | NegationExpression
    | TypeCastExpression
    ;

// 6.5.1 Borrow Expression
syntax BorrowExpression
    = "&" "mut"? Operand
    ;

// 6.5.2 Dereference Expression
syntax DereferenceExpression
    = "*" Operand
    ;

// 6.5.3 Error Propagation Expression
syntax ErrorPropagationExpression
    = Operand "?" 
    ;

// 6.5.4 Negation Expression

syntax NegationExpression
    = NegationOperator Operand
    ;

syntax NegationOperator
    = BitwiseNegationOperator
    | SignNegationOperator
    ;

syntax BitwiseNegationOperator
    = "!"
    ;

syntax SignNegationOperator
    = "-"
    ;

// 6.5.5 Arithmetic Expressions

syntax ArithmeticExpression
    = AdditionExpression
    | DivisionExpression
    | MultiplicationExpression
    | RemainderExpression
    | SubtractionExpression
    ;

syntax AdditionExpression
    = LeftOperand "+" RightOperand
    ;

syntax DivisionExpression
    = LeftOperand "/" RightOperand
    ;

syntax MultiplicationExpression
    = LeftOperand "*" RightOperand
    ;

syntax RemainderExpression
    = LeftOperand "%" RightOperand
    ;

syntax SubtractionExpression
    = LeftOperand "-" RightOperand
    ;

// 6.5.6 Bit Expressions
syntax BitExpression
    = BitAndExpression
    | BitOrExpression
    | BitXorExpression
    | ShiftLeftExpression
    | ShiftRightExpression
    ;

syntax BitAndExpression
    = LeftOperand "&" RightOperand
    ;

syntax BitOrExpression
    = LeftOperand "|" RightOperand
    ;

syntax BitXorExpression
    = LeftOperand "^" RightOperand
    ;

syntax ShiftLeftExpression
    = LeftOperand "\<\<" RightOperand
    ;

syntax ShiftRightExpression
    = LeftOperand "\>\>" RightOperand
    ;

// 6.5.7 Comparison Expressions
syntax ComparisonExpression
    = EqualsExpression
    | GreaterThanExpression
    | GreaterThanOrEqualsExpression
    | LessThanExpression
    | LessThanOrEqualsExpression
    | NotEqualsExpression
    ;

syntax EqualsExpression
    = LeftOperand "==" RightOperand
    ;

syntax GreaterThanExpression
    = LeftOperand "\>" RightOperand
    ;

syntax GreaterThanOrEqualsExpression
    = LeftOperand "\>=" RightOperand
    ;

syntax LessThanExpression
    = LeftOperand "\<" RightOperand
    ;

syntax LessThanOrEqualsExpression
    = LeftOperand "\<=" RightOperand
    ;

syntax NotEqualsExpression
    = LeftOperand "!=" RightOperand
    ;

// 6.5.8 Lazy Boolean Expressions
syntax LazyBooleanExpression
    = LazyAndExpression
    | LazyOrExpression
    ;

syntax LazyAndExpression
    = LeftOperand "&&" RightOperand
    ;

syntax LazyOrExpression
    = LeftOperand "||" RightOperand
    ;

// 6.5.9 Type Cast Expressions
syntax TypeCastExpression
    = Operand "as" TypeSpecificationWithoutBounds
    ;

// 6.5.10 Assignment Expressions
syntax AssignmentExpression
    = AssigneeOperand "=" ValueOperand
    ;

syntax AssigneeOperand
    = Operand
    ;

syntax ValueOperand
    = Operand
    ;

// 6.5.11 Compound Assignment Expressions
syntax CompoundAssignmentExpression
    = AdditionAssignmentExpression
    | BitAndAssignmentExpression
    | BitOrAssignmentExpression
    | BitXorAssignmentExpression
    | DivisionAssignmentExpression
    | MultiplicationAssignmentExpression
    | RemainderAssignmentExpression
    | ShiftLeftAssignmentExpression
    | ShiftRightAssignmentExpression
    | SubtractionAssignmentExpression
    ;

syntax AdditionAssignmentExpression
    = AssignedOperand "+=" ModifyingOperand
    ;

syntax BitAndAssignmentExpression
    = AssignedOperand "&=" ModifyingOperand
    ;

syntax BitOrAssignmentExpression
    = AssignedOperand "|=" ModifyingOperand
    ;

syntax BitXorAssignmentExpression
    = AssignedOperand "^=" ModifyingOperand
    ;

syntax DivisionAssignmentExpression
    = AssignedOperand "/=" ModifyingOperand
    ;

syntax MultiplicationAssignmentExpression
    = AssignedOperand "*=" ModifyingOperand
    ;

syntax RemainderAssignmentExpression
    = AssignedOperand "%=" ModifyingOperand
    ;

syntax ShiftLeftAssignmentExpression
    = AssignedOperand "\<\<=" ModifyingOperand
    ;

syntax ShiftRightAssignmentExpression
    = AssignedOperand "\>\>=" ModifyingOperand
    ;

syntax SubtractionAssignmentExpression
    = AssignedOperand "-=" ModifyingOperand
    ;

syntax AssignedOperand
    = Operand
    ;

syntax ModifyingOperand
    = Operand
    ;

// 6.6 Underscore Expressions
syntax UnderscoreExpression
    = "_"
    ;

// 6.7 Parenthesized Expressions
syntax ParenthesizedExpression
    = "(" Operand ")"
    ;

// 6.8 Array Expressions
syntax ArrayExpression
    = "[" ArrayElementExpression? "]"
    ;

syntax ArrayElementExpression
    = ArrayElementConstructor
    | ArrayRepetitionConstructor
    ;

syntax ArrayElementConstructor
    = ExpressionList
    ;

syntax ArrayRepetitionConstructor
    = RepeatOperand ";" SizeOperand
    ;

syntax RepeatOperand
    = Operand
    ;

syntax SizeOperand
    = Operand
    ;

// 6.9 Indexing Expressions
syntax IndexExpression
    = IndexedOperand "[" IndexingOperand "]"
    ;

syntax IndexedOperand
    = Operand
    ;

syntax IndexingOperand
    = Operand
    ;

// 6.10 Tuple Expressions
syntax TupleExpression
    = "(" TupleInitializerList? ")"
    ;

syntax TupleInitializerList
    = ExpressionList
    ;

// 6.11 Struct Expressions

syntax StructExpression
    = Constructee "{" StructExpressionContent? "}"
    ;

syntax Constructee
    = PathExpression
    ;

syntax StructExpressionContent
    = BaseInitializer
    | FieldInitializerList (("," BaseInitializer) | ","?)
    ;

syntax BaseInitializer
    = ".." Operand
    ;

syntax FieldInitializerList
    = {FieldInitializer ","}+
    ;

syntax FieldInitializer
    = IndexedInitializer
    | NamedInitializer
    | ShorthandInitializer
    ;

syntax IndexedInitializer
    = FieldIndex ":" Expression
    ;

syntax NamedInitializer
    = Identifier ":" Expression
    ;

syntax ShorthandInitializer
    = Identifier
    ;

// 6.12 Invocation Expressions

// 6.12.1 Call Expressions
syntax CallExpression
    = CallOperand "(" ArgumentOperandList? ")"
    ;

syntax CallOperand
    = Operand
    ;

syntax ArgumentOperandList
    = ExpressionList
    ;

// 6.12.2 Method Call Expressions
syntax MethodCallExpression
    = ReceiverOperand "." MethodOperand "(" ArgumentOperandList? ")"
    ;

syntax ReceiverOperand
    = Operand
    ;

syntax MethodOperand
    = PathExpressionSegment
    ;

// 6.13 Field Access Expressions
syntax FieldAccessExpression
    = ContainerOperand "." FieldSelector
    ;

syntax ContainerOperand
    = Operand
    ;

syntax FieldSelector
    = IndexedFieldSelector
    | NamedFieldSelector
    ;

syntax IndexedFieldSelector
    = DecimalLiteral
    ;

syntax NamedFieldSelector
    = Identifier
    ;

// 6.14 Closure Expressions
syntax ClosureExpression
    = "move"? "|" ClosureParameterList? "|" (ClosureBody | ClosureBodyWithReturnType)
    ;

syntax ClosureBody
    = Expression
    ;

syntax ClosureBodyWithReturnType
    = ReturnTypeWithoutBounds BlockExpression
    ;

syntax ReturnTypeWithoutBounds
    = "-\>" TypeSpecificationWithoutBounds
    ;

syntax ClosureParameterList
    = {ClosureParameter ","}+ ","?
    ;

syntax ClosureParameter
    = OuterAttributeOrDoc* PatternWithoutAlternation TypeAscription?
    ;

// 6.15 Loop Expressions
syntax LoopExpression
    = Label? LoopContent
    ;

syntax Label
    = "\'" NonKeywordIdentifier ":"
    ;

syntax LoopContent
    = ForLoopExpression
    | InfiniteLoopExpression
    | WhileLetLoopExpression
    | WhileLoopExpression
    ;

syntax LoopBody
    = BlockExpression
    ;

// 6.15.1 For Loops
syntax ForLoopExpression
    = "for" Pattern "in" SubjectExpression LoopBody
    ;

// 6.15.2 Infinite Loops
syntax InfiniteLoopExpression
    = "loop" LoopBody
    ;

// 6.15.3 While Loops
syntax WhileLoopExpression
    = "while" IterationExpression LoopBody
    ;

syntax IterationExpression
    = SubjectExpression
    ;

// 6.15.4 While Let Loops
syntax WhileLetLoopExpression
    = "while" "let" Pattern "=" SubjectLetExpression LoopBody
    ;

// 6.15.5 Loop Labels
syntax LabelIndication
    = "\'" NonKeywordIdentifier
    ;

// 6.15.6 Break Expressions
syntax BreakExpression
    = "break" LabelIndication? Operand?
    ;

// 6.15.7 Continue Expressions
syntax ContinueExpression
    = "continue" LabelIndication?
    ;

// 6.16 Range Expressions
syntax RangeExpression
    = RangeFromExpression
    | RangeFromToExpression
    | RangeFullExpression
    | RangeInclusiveExpression
    | RangeToExpression
    | RangeToInclusiveExpression
    ;

syntax RangeFromExpression
    = RangeExpressionLowBound ".."
    ;

syntax RangeFromToExpression
    = RangeExpressionLowBound ".." RangeExpressionHighBound
    ;

syntax RangeFullExpression
    = ".."
    ;

syntax RangeInclusiveExpression
    = RangeExpressionLowBound "..=" RangeExpressionHighBound
    ;

syntax RangeToExpression
    = ".." RangeExpressionHighBound
    ;

syntax RangeToInclusiveExpression
    = "..=" RangeExpressionHighBound
    ;

syntax RangeExpressionLowBound
    = Operand
    ;

syntax RangeExpressionHighBound
    = Operand
    ;

// 6.17 If and If let Expressions
syntax IfExpression
    = "if" SubjectExpression BlockExpression ElseExpression?
    ;

syntax ElseExpression
    = "else" (BlockExpression | IfExpression | IfLetExpression)
    ;


syntax IfLetExpression
    = "if" "let" Pattern "=" SubjectLetExpression BlockExpression ElseExpression?
    ;

// 6.18 Match Expressions

syntax MatchExpression
    = "match" SubjectExpression "{" 
        InnerAttributeOrDoc* 
        MatchArmList? 
    "}"
    ;

syntax MatchArmList
    = IntermediateMatchArm* FinalMatchArm
    ;

syntax IntermediateMatchArm
    = MatchArmMatcher "=\>" ( (ExpressionWithBlock ","?) | (ExpressionWithoutBlock ","))
    ;

syntax FinalMatchArm
    = MatchArmMatcher "=\>" Operand ","?
    ;

syntax MatchArmMatcher
    = OuterAttributeOrDoc* Pattern MatchArmGuard?
    ;

syntax MatchArmGuard
    = "if" Operand
    ;

// 6.19 Return Expressions
syntax ReturnExpression
    = "return" Expression?
    ;

// 6.20 Await Expressions
syntax AwaitExpression
    = FutureOperand "." "await"
    ;

syntax FutureOperand
    = Operand
    ;

// #### 7. Values ####

// 7.1 Constants
syntax ConstantDeclaration
    = "const" (Name | "_") TypeAscription ConstantInitializer? ";"
    ;

syntax ConstantInitializer
    = "=" Expression
    ;

// 7.2 Statics
syntax StaticDeclaration
    = "static" mut? Name TypeAscription StaticInitializer? ";"
    ;

syntax StaticInitializer
    = "=" Expression
    ;

// #### 8. Statements #### 

syntax Statements = Statement* statements;

syntax Statement
    = ExpressionStatement
    | Item
    | LetStatement
    | TerminatedMacroInvocation
    | ";"
    ;

// 8.1 Let Statements
syntax LetStatement // MODIFIED
    = OuterAttributeOrDoc* "let" PatternWithoutRange!pathPat TypeAscription? LetInitializer? ";"
    | OuterAttributeOrDoc* "let" RangePattern TypeAscription? LetInitializer? ";"
    ;

syntax LetInitializer
    = "=" Expression ("else" BlockExpression)?
    ;


// 8.2 Expression Statements
syntax ExpressionStatement
    = ExpressionWithBlock ";"?
    | ExpressionWithoutBlock ";"
    ;

// #### 9. Functions ####
syntax FunctionDeclaration
    = FunctionQualifierList "fn" Name GenericParameterList? "(" FunctionParameterList? ")" ReturnType? WhereClause? (FunctionBody | ";")
    ;

syntax FunctionQualifierList
    = "const"? "async"? "unsafe"? AbiSpecification?
    ;

syntax FunctionParameterList
    = {FunctionParameter ","}+ ","?
    | (SelfParameter ("," FunctionParameter)* ","?)
    ;

syntax FunctionParameter
    = OuterAttributeOrDoc* (FunctionParameterPattern | FunctionParameterVariadicPart | TypeSpecification)
    ;

syntax FunctionParameterPattern
    = PatternWithoutAlternation (TypeAscription | (":" FunctionParameterVariadicPart))
    ;

syntax FunctionParameterVariadicPart
    = "..."
    ;

syntax ReturnType
    = "-\>" TypeSpecification
    ;

syntax FunctionBody
    = BlockExpression
    ;

syntax SelfParameter
    = OuterAttributeOrDoc* (ShorthandSelf | TypedSelf)
    ;

syntax ShorthandSelf
    = ("&" LifetimeIndication?)? "mut"? "self"
    ;

syntax TypedSelf
    = "mut"? "self" TypeAscription
    ;

// #### 10. Associated Items ####
syntax AssociatedItem
    = OuterAttributeOrDoc* (AssociatedItemWithVisibility | TerminatedMacroInvocation)
    ;

syntax AssociatedItemWithVisibility
    = VisibilityModifier? (
        ConstantDeclaration
      | FunctionDeclaration
      | TypeAliasDeclaration
    )
    ;

// #### 11. Implementations ####
syntax Implementation
    = InherentImplementation
    | TraitImplementation
    ;

syntax InherentImplementation
    = "impl" GenericParameterList? ImplementingType WhereClause? ImplementationBody
    ;

syntax TraitImplementation
    = "unsafe"? "impl" GenericParameterList? "!"? ImplementedTrait "for" ImplementingType WhereClause? ImplementationBody
    ;

syntax ImplementingType
    = TypeSpecification
    ;

syntax ImplementedTrait
    = TypePath
    ;

syntax ImplementationBody
    = "{" 
        InnerAttributeOrDoc* 
        AssociatedItem* 
    "}"
    ;

// #### 12. Generics ####

// 12.1 Generic Parameters
syntax GenericParameterList
    = "\<" "\>"
    |  "\<" {GenericParameter ","}+ ","? "\>" 
    ;

syntax GenericParameter
    = OuterAttributeOrDoc* (
        ConstantParameter
      | LifetimeParameter
      | TypeParameter
      )
    ;

syntax ConstantParameter
    = "const" Name TypeAscription ("=" ConstantParameterInitializer)?
    ;

syntax ConstantParameterInitializer
    = BlockExpression
    | Identifier
    | "-"? LiteralExpression
    ;

syntax LifetimeParameter
    = Lifetime (":" LifetimeIndicationList)?
    ;

syntax TypeParameter
    = Name (":" TypeBoundList?)? ("=" TypeParameterInitializer)?
    ;

syntax TypeParameterInitializer
    = TypeSpecification
    ;

// 12.2 Where Clauses
syntax WhereClause
    = "where" WhereClausePredicateList
    ;

syntax WhereClausePredicateList
    = {WhereClausePredicate ","}+ ","?
    ;

syntax WhereClausePredicate
    = LifetimeBoundPredicate
    | TypeBoundPredicate
    ;

syntax LifetimeBoundPredicate
    = LifetimeIndication ":" LifetimeIndicationList?
    ;

syntax TypeBoundPredicate
    = ForGenericParameterList? TypeSpecification ":" TypeBoundList?
    ;

// 12.3 Generic Arguments
syntax GenericArgumentList
    = "\<" {GenericArgument ","}* "\>"
    ;

syntax GenericArgument
    = BindingArgument
    | BindingBoundArgument
    | ConstantArgument
    | LifetimeArgument
    | TypeArgument
    ;

syntax BindingArgument
    = Identifier "=" TypeSpecification
    ;

syntax BindingBoundArgument
    = Identifier ":" TypeBoundList
    ;

syntax ConstantArgument
    = BlockExpression
    | "-"? LiteralExpression
    | Identifier
    ;

syntax LifetimeArgument
    = LifetimeIndication
    ;

syntax TypeArgument
    = TypeSpecification
    ;

// #### 13. Attributes ####

syntax InnerAttributeOrDoc
    = InnerAttribute
    | InnerBuiltinAttribute
    | InnerBlockDoc
    | InnerLineDoc
    ;

syntax InnerAttribute
    = "#![" AttributeContent "]"
    ;

syntax OuterAttributeOrDoc
    = OuterAttribute
    | OuterBuiltinAttribute
    | OuterBlockDoc
    | OuterLineDoc
    ;



syntax OuterAttribute
    = "#[" AttributeContent "]"
    ;

syntax AttributeContent
    = SimplePath AttributeInput?
    ;

syntax AttributeInput
    = "(" TokenTree* ")"
    | "=" Expression
    ;

syntax AttributeContentList
    = {AttributeContent ","}+ ","?
    ;

// 13.2 Build-in Attributes

syntax InnerBuiltinAttribute
    = "#!" "[" BuiltinAttributeContent "]"
    ;

syntax OuterBuiltinAttribute
    = "#" "[" BuiltinAttributeContent "]"
    ;

syntax BuiltinAttributeContent
    = AutomaticallyDerivedContent
    | CfgAttrContent
    | CfgContent
    | CollapseDebuginfoContent
    | ColdContent
    | CrateNameContent
    | CrateTypeContent
    | DeriveContent
    | DocContent
    | ExportNameContent
    | GlobalAllocatorContent
    | InlineContent
    | IgnoreContent
    | LinkContent
    | LinkNameContent
    | LinkSectionContent
    | LinkOrdinalContent
    | MacroExportContent
    | MacroUseContent
    | NoBinutilsContent
    | NoImplicitPreludeContent
    | NoLinkContent
    | NoMainContent
    | NoMangleContent
    | NonExhaustiveContent
    | NoStdContent
    | PanicHandlerContent
    | PathContent
    | ProcMacroAttributeContent
    | ProcMacroContent
    | ProcMacroDeriveContent
    | RecursionLimitContent
    | ReprContent
    | ShouldPanicContent
    | TargetFeatureContent
    | TestContent
    | TrackCallerContent
    | TypeLengthLimitContent
    | UsedContent
    | WindowsSubsystemContent
    ;

// 13.2.1 Code Generation Attributes
syntax ColdContent
    = "cold"
    ;

syntax InlineContent
    = "inline" InlineHint?
    ;

syntax InlineHint
    = "(" ( "always" | "never" ) ")"
    ;

syntax NoBinutilsContent
    = "no_builtins"
    ;

syntax TargetFeatureContent
    = "target_feature" "(" "enable" "=" "\"" FeatureList "\"" ")"
    ;

syntax FeatureList
    = {Feature ","}+
    ;

syntax Feature
    = "adx"
  | "aes"
  | "avx"
  | "avx2"
  | "bmi1"
  | "bmi2"
  | "fma"
  | "fxsr"
  | "lzcnt"
  | "pclmulqdq"
  | "popcnt"
  | "rdrand"
  | "rdseed"
  | "sha"
  | "sse"
  | "sse2"
  | "sse3"
  | "sse4.1"
  | "sse4.2"
  | "ssse3"
  | "xsave"
  | "xsavec"
  | "xsaveopt"
  | "xsaves"
    ;

syntax TrackCallerContent
    = "track_caller"
    ;

// 13.2.2 Conditional Compilation Attributes
syntax CfgContent
    = "cfg" "(" ConfigurationPredicate ")"
    ;

syntax ConfigurationPredicate
    = ConfigurationOption
    | ConfigurationPredicateAll
    | ConfigurationPredicateAny
    | ConfigurationPredicateNot
    ;

syntax ConfigurationOption
    = ConfigurationOptionName ConfigurationOptionValue?
    ;

syntax ConfigurationOptionName
    = Identifier
    ;

syntax ConfigurationOptionValue
    = "=" StringLiteral
    ;

syntax ConfigurationPredicateAll
    = "all"  "(" ConfigurationPredicateList? ")"
    ;

syntax ConfigurationPredicateAny
    = "any" "(" ConfigurationPredicateList? ")"
    ;

syntax ConfigurationPredicateNot
    = "not" "(" ConfigurationPredicate ")"
    ;

syntax ConfigurationPredicateList
    =  {ConfigurationPredicate ","}+ ","?
    ;

syntax CfgAttrContent
    = "cfg_attr" "(" ConfigurationPredicate "," AttributeContentList ")"
    ;

// 13.2.3 Derivation Attributes
syntax AutomaticallyDerivedContent
    = "automatically_derived"
    ;

syntax DeriveContent
    = "derive" "(" SimplePathList? ")"
    ;


// 13.2.4 Diagnostic Attributes

syntax DocContent
    = "doc" DocInput
    ;

syntax DocInput
    = "=" MacroInvocation
    | "=" StringLiteral
    | "(" TokenTree* ")"
    ;

// 13.2.6 Foreign Function Interface Attributes
syntax CrateNameContent
    = "crate_name" "=" StringLiteral
    ;

syntax CrateTypeContent
    = "crate_type" "="  "\"" CrateType "\""
    ;

syntax CrateType
    = "bin"
    | "cdylib"
    | "dylib"
    | "lib"
    | "proc-macro"
    | "rlib"
    | "staticlib"
    ;

syntax ExportNameContent
    = "export_name" "=" StringLiteral
    ;

syntax LinkContent
    = "link" "(" LinkOption ")"
    ;

syntax LinkOption
    = NativeLibraryName
    | NativeLibraryNameWithKind
    | WebAssemblyModuleName
    ;

syntax NativeLibraryName
    = "name" "=" StringLiteral
    ;

syntax NativeLibraryNameWithKind
    = NativeLibraryName "," NativeLibraryKind
    ;

syntax WebAssemblyModuleName
    = "wasm_import_module" "=" StringLiteral
    ;

syntax NativeLibraryKind
    = "kind" "=" NativeLibraryKindType "\""
    ;

syntax NativeLibraryKindType
    = "dylib"
    | "raw-dylib"
    | "framework"
    | "static"
    ;

syntax LinkNameContent
    = "link_name" "=" StringLiteral
    ;

syntax LinkSectionContent
    = "link_section" "=" StringLiteral
    ;

syntax LinkOrdinalContent
    = "link_ordinal" "(" DecimalLiteral ")"
    ;

syntax NoLinkContent
    = "no_link"
    ;


syntax NoMainContent
    = "no_main"
    ;

syntax NoMangleContent
    = "no_mangle"
    ;

syntax ReprContent
    = "repr" "(" Representation ")"
    ;

syntax Representation
    = RepresentationKind Alignment?
    ;

syntax RepresentationKind
    = PrimitiveRepresentation
    | "C"
    | "Rust"
    | "transparent"
    ;

syntax PrimitiveRepresentation
    = "i8"
    | "i16"
    | "i32"
    | "i64"
    | "i128"
    | "isize"
    | "u8"
    | "u16"
    | "u32"
    | "u64"
    | "u128"
    | "usize"
    ;

syntax Alignment
    = AlignmentDecrease
    | AlignmentIncrease
    ;

syntax AlignmentDecrease
    = "packed"
    ;

syntax AlignmentIncrease
    = "align" "(" DecimalLiteral ")"
    ;

syntax UsedContent
    = "used"
    ;

// 13.2.7 Limits Attributes
syntax RecursionLimitContent
    = "recursion_limit" "=" "\"" DecimalLiteral "\""
    ;

syntax TypeLengthLimitContent
    = "type_length_limit" "=" "\"" DecimalLiteral "\""
    ;


// 13.2.8 Macro Attributes
syntax CollapseDebuginfoContent
    = "collapse_debuginfo" "(" CollapseDebuginfoKind ")"
    ;

syntax CollapseDebuginfoKind
    = "no"
    | "external"
    | "yes"
    ;

syntax MacroExportContent
    = "macro_export"
    ;

syntax MacroUseContent
    = "macro_use" ImportedMacroList?
    ;

syntax ImportedMacroList
    = "(" IdentifierList ")"
    ;

syntax ProcMacroContent
    = "proc_macro"
    ;

syntax ProcMacroAttributeContent
    = "proc_macro_attribute"
    ;

syntax ProcMacroDeriveContent
    = "proc_macro_derive" "(" DeriveName ("," HelperAttributeList)? ")"
    ;

syntax DeriveName
    = Name
    ;

syntax HelperAttributeList
    = "attributes" "(" IdentifierList ")"
    ;

// 13.2.9 Modules attributes
syntax PathContent
    = "path" "=" StringLiteral
    ;


// 13.2.10 Prelude Attributes
syntax NoImplicitPreludeContent
    = "no_implicit_prelude"
    ;

syntax NoStdContent
    = "no_std"
    ;

// 13.2.11 Runtime Attributes
syntax GlobalAllocatorContent
    = "global_allocator"
    ;

syntax PanicHandlerContent
    = "panic_handler"
    ;

syntax WindowsSubsystemContent
    = "windows_subsystem" "=" "\"" SubsystemKind "\""
    ;

syntax SubsystemKind
    = "console"
    | "windows"
    ;

// 13.2.12 Testing Attributes
syntax IgnoreContent
    = "ignore" IgnoreReason?
    ;

syntax IgnoreReason
    = "=" StringLiteral
    ;

syntax ShouldPanicContent
    = "should_panic" ExpectedPanicMessage?
    ;

syntax ExpectedPanicMessage
    = "(" "expected" "=" StringLiteral ")"
    ;

syntax TestContent
    = "test"
    ;

// 13.2.13 Type Attributes
syntax NonExhaustiveContent
    = "non_exhaustive"
    ;


// #### 14. Entities and Resolution ####

// 14.1 Entities
syntax Name
    = Identifier
    ;

// 14.2 Visibility
syntax VisibilityModifier
    = CratePublicModifier
    | SelfPublicModifier
    | SimplePathPublicModifier
    | SimplePublicModifier
    | SuperPublicModifier
    ;

syntax CratePublicModifier
    = "pub" "(" "crate" ")"
    ;

syntax SelfPublicModifier
    = "pub" "(" "self" ")"
    ;

syntax SimplePathPublicModifier
    = "pub" "(" "in" SimplePath ")"
    ;

syntax SimplePublicModifier
    = "pub"
    ;

syntax SuperPublicModifier
    = "pub" "(" "super" ")"
    ;

// 14.3 Paths
syntax SimplePath
    = "::"? SimplePathSegment ("::" SimplePathSegment)*
    ;

syntax SimplePathSegment
    = Identifier
    | "crate"
    | "$crate"
    | "self"
    | "super"
    ;

syntax SimplePathList
    = {SimplePath ","}+ ","?
    ;

syntax QualifiedType
    = "\<" TypeSpecification QualifyingTrait? "\>"
    ;

syntax QualifyingTrait
    = "as" TypePath
    ;

syntax UnqualifiedPathExpression
    = "::"? PathExpressionSegment ("::" PathExpressionSegment)*
    ;

syntax PathExpressionSegment
    = PathSegment ("::" GenericArgumentList)?
    ;

syntax PathSegment
    = SimplePathSegment
    | "Self"
    ;

syntax QualifiedPathExpression
    = QualifiedType ("::" PathExpressionSegment)+
    ;

syntax TypePath
    = "::"? TypePathSegment ("::" TypePathSegment)*
    ;

syntax TypePathSegment
    = PathSegment "::"? (GenericArgumentList | QualifiedFnTrait)?
    ;

syntax QualifiedFnTrait
    = "(" TypeSpecificationList? ")" ReturnType?
    ;

syntax QualifiedTypePath
    = QualifiedType ("::" TypePathSegment)+
    ;

// 14.7 Use Imports
syntax UseImport
    = "use" UseImportContent ";"
    ;

syntax UseImportContent
    = GlobImport
    | NestingImport
    | SimpleImport
    ;

syntax GlobImport
    = SimplePathPrefix? "*"
    ;

syntax NestingImport
    = SimplePathPrefix? "{" UseImportContentList? "}"
    ;

syntax SimpleImport
    = SimplePath Renaming?
    ;

syntax SimplePathPrefix
    = SimplePath? "::"
    ;

syntax UseImportContentList
    = {UseImportContent ","}+ ","?
    ;



// #### 15. Ownership and Destruction #### EMPTY

// #### 16. Exceptions and Errors #### EMPTY

// #### 17. Concurrency #### EMPTY

// #### 18. Program Structure and Compilation ####

// 18.1 Source Files

start syntax SourceFile
    = ZeroWidthNoBreakSpace?
    Shebang?
    InnerAttributeOrDoc*
    Item*
    ;

lexical ZeroWidthNoBreakSpace
    = "\uFEFF"
    ;

lexical Shebang
    = "#!" !>> "[" ![\n]* $;

syntax Newline
    = "\n"
    ;

// 18.2 Modules
syntax ModuleDeclaration
    = "unsafe"? "mod" Name ModuleSpecification
    ;

syntax ModuleSpecification
    = InlineModuleSpecification
    | OutlineModuleSpecification
    ;

syntax InlineModuleSpecification
    = "{" 
        InnerAttributeOrDoc* 
        Item* 
    "}"
    ;

syntax OutlineModuleSpecification
    = ";"
    ;

// 18.4 Crate Imports
syntax ExternalCrateImport
    = "extern" "crate" CrateIndication Renaming? ";"
    ;

syntax CrateIndication
    = Identifier
    | "self"
    ;



// #### 19. Unsafety #### EMPTY

// #### 20. Macros ####

// 20.1 Delarative Macros

syntax MacroRulesDeclaration
    = "macro_rules" "!" Name MacroRulesDefinition
    ;

syntax MacroRulesDefinition
    = "(" MacroRuleList ")" ";"
    | "[" MacroRuleList "]" ";"
    | "{" MacroRuleList "}"
    ;

syntax MacroRuleList
    = {MacroRule ";"}+ ";"?
    ;

syntax MacroRule
    = MacroMatcher "=\>" MacroTranscriber
    ;

syntax MacroMatcher
    = "(" MacroMatch* ")"
    | "[" MacroMatch* "]"
    | "{" MacroMatch* "}"
    ;

syntax MacroTranscriber
    = DelimitedTokenTree
    ;

syntax MacroMatch
    = MacroMatcher
    | MacroMatchToken
    | MacroMetavariableMatch
    | MacroRepetitionMatch
    ;

// UNSURE A MacroMatchToken is any lexical element in category LexicalElement, except punctuation $ and category Delimiter.

syntax MacroMatchToken
    = LexicalElement \ ("$" | Delimiter)
    ;

// 20.1.1 Metavariables

syntax MacroMetavariableMatch
    = "$" MacroMetavariable ":" MacroFragmentSpecifier
    ;

syntax MacroMetavariable
    = Keyword
    | NonKeywordIdentifier
    ;

syntax MacroFragmentSpecifier
    = "block"
    | "expr"
    | "ident"
    | "item"
    | "lifetime"
    | "literal"
    | "meta"
    | "pat"
    | "pat_param"
    | "path"
    | "stmt"
    | "tt"
    | "ty"
    | "vis"
    ;

syntax MacroMetavariableIndication
    = "$" MacroMetavariable
    ;

// 20.1.2 Repetition

syntax MacroRepetitionMatch
    = "$" "(" MacroRepetitionMatchContent ")" MacroRepetitionSeparator? MacroRepetitionOperator
    ;

syntax MacroRepetitionMatchContent
    = MacroMatch*
    ;

syntax MacroRepetitionTranscriber
    = "$" "(" TokenTree* ")" MacroRepetitionSeparator? MacroRepetitionOperator
    ;

syntax MacroRepetitionOperator
    = "+"
    | "*"
    | "?"
    ;

// UNSURE A MacroRepetitionSeparator is any lexical element in category LexicalElement, except punctuation +, *, ?, and category Delimiter.
syntax MacroRepetitionSeparator
    = LexicalElement \ ("+" | "*" | "?" | Delimiter)
    ;

// 20.3 Macro Invocation

syntax MacroInvocation
    = SimplePath "!" DelimitedTokenTree
    ;

syntax DelimitedTokenTree
    = "(" TokenTree* ")"
    | "[" TokenTree* "]"
    | "{" TokenTree* "}"
    ;

syntax TokenTree
    = DelimitedTokenTree
    | NonDelimitedToken
    ;

syntax TerminatedMacroInvocation
    = SimplePath "!" "(" TokenTree* ")" ";"
    | SimplePath "!" "[" TokenTree* "]" ";"
    | SimplePath "!" "{" TokenTree* "}" 
    ;

// UNSURE A NonDelimitedToken is any lexical element in category LexicalElement, except category Delimiter.
syntax NonDelimitedToken
    = LexicalElement \ ("{" | "}" | "[" | "]" | "(" | ")") // Could be replaced by "Delimiter" but Rascal complains
    ;



// #### 21. FFI ####

// 21.1 ABI

syntax AbiSpecification
    = "extern" AbiKind?
    ;

syntax AbiKind
    = RawStringLiteral
    | StringLiteral
    ;


// 21.2 External Blocks
syntax ExternalBlock
    = "unsafe"? "extern" AbiKind? "{" 
        InnerAttributeOrDoc* 
        ExternItem* 
    "}"
    ;

syntax ExternItem
    = OuterAttributeOrDoc* (ExternalItemWithVisibility | TerminatedMacroInvocation)
    ;

syntax ExternalItemWithVisibility
    = VisibilityModifier? (
        FunctionDeclaration
      | StaticDeclaration
    )
    ;


// #### 22. Inline Assembly ####

