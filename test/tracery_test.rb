$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'test/unit'
require 'tracery'
require "mods-eng-basic"

class TraceryTest < Test::Unit::TestCase
    include Tracery
    def setup
        Tracery.resetRnd
        @grammar = createGrammar({
            "deepHash" => ["\\#00FF00", "\\#FF00FF"],
            "deeperHash" => ["#deepHash#"],
            "animal" => ["bear", "cat", "dog", "fox", "giraffe", "hippopotamus"],
            "mood" => ["quiet", "morose", "gleeful", "happy", "bemused", "clever", "jovial", "vexatious", "curious", "anxious", "obtuse", "serene", "demure"],

            "nonrecursiveStory" => ["The #pet# went to the beach."],
            # story : ["#recursiveStory#", "#recursiveStory#", "#nonrecursiveStory#"],
            "recursiveStory" => ["The #pet# opened a book about[pet:#mood# #animal#] #pet.a#. #[#setPronouns#]story#[pet:POP] The #pet# closed the book."],

            "svgColor" => ["rgb(120,180,120)", "rgb(240,140,40)", "rgb(150,45,55)", "rgb(150,145,125)", "rgb(220,215,195)", "rgb(120,250,190)"],
            "svgStyle" => ['style="fill:#svgColor#;stroke-width:3;stroke:#svgColor#"'],

            "name" => ["Cheri", "Fox", "Morgana", "Jedoo", "Brick", "Shadow", "Krox", "Urga", "Zelph"],
            "story" => ["#hero.capitalize# was a great #occupation#, and this song tells of #heroTheir# adventure. #hero.capitalize# #didStuff#, then #heroThey# #didStuff#, then #heroThey# went home to read a book."],
            "monster" => ["dragon", "ogre", "witch", "wizard", "goblin", "golem", "giant", "sphinx", "warlord"],
            "setPronouns" => ["[heroThey:they][heroThem:them][heroTheir:their][heroTheirs:theirs]", "[heroThey:she][heroThem:her][heroTheir:her][heroTheirs:hers]", "[heroThey:he][heroThem:him][heroTheir:his][heroTheirs:his]"],
            "setOccupation" => ["[occupation:baker][didStuff:baked bread,decorated cupcakes,folded dough,made croissants,iced a cake]", "[occupation:warrior][didStuff:fought #monster.a#,saved a village from #monster.a#,battled #monster.a#,defeated #monster.a#]"],
            "capitalizeMe" => "SOME CAPITAL LETTERS",
            "capitalizeMore" => "this sentence HAS CAPITALS IN IT",
            "empty" => "",
            "single" => "a",
            "origin" => ["#[#setPronouns#][#setOccupation#][hero:#name#]story#"]
        })
        @grammar.addModifiers(Modifiers.baseEngModifiers)
    end

    def test_main_expansion_tests
        tests = {
        plaintextShort: {
           src: "a",
           expected: "a"
        },
        plaintextLong: {
            src: "Emma Woodhouse, handsome, clever, and rich, with a comfortable home and happy disposition, seemed to unite some of the best blessings of existence; and had lived nearly twenty-one years in the world with very little to distress or vex her.",
            expected: "Emma Woodhouse, handsome, clever, and rich, with a comfortable home and happy disposition, seemed to unite some of the best blessings of existence; and had lived nearly twenty-one years in the world with very little to distress or vex her."
        },

        # Escape chars
        escapeCharacter: {
            src: "\\#escape hash\\# and escape slash\\\\",
            expected: "#escape hash# and escape slash\\"
        },

        escapeDeep: {
            src: "#deepHash# [myColor:#deeperHash#] #myColor#"
        },

        escapeQuotes: {
            src: "\"test\" and \'test\'",
            expected: "\"test\" and \'test\'"
        },
        escapeBrackets: {
            src: "\\[\\]",
            expected: "[]"
        },
        escapeHash: {
            src: "\\#",
            expected: "#"
        },
        unescapeCharSlash: {
            src: "\\\\",
            expected: "\\"
        },
        escapeMelange1: {
            src: "An action can have inner tags: \\[key:\\#rule\\#\\]",
            expected: "An action can have inner tags: [key:#rule#]"
        },
        escapeMelange2: {
            src: "A tag can have inner actions: \"\\#\\[myName:\\#name\\#\\]story\\[myName:POP\\]\\#\"",
            expected: "A tag can have inner actions: \"#[myName:#name#]story[myName:POP]#\""
        },
        escapeBroken: {
            src: "\"#name#\" should expand to a name. But \\[ this and \\] should be literal square brackets. And again, just another name: \"#name#\". But for some reason it gets put here at the end! Fixed now....."
        },
        emoji: {
            src: "💻🐋🌙🏄🍻",
            expected: "💻🐋🌙🏄🍻"
        },

        unicode: {
            src: "&\\#x2665; &\\#x2614; &\\#9749; &\\#x2665;",
            expected: "&#x2665; &#x2614; &#9749; &#x2665;"
        },

        svg: {
            src: '<svg width="100" height="70"><rect x="0" y="0" width="100" height="100" #svgStyle#/> <rect x="20" y="10" width="40" height="30" #svgStyle#/></svg>'
        },

        pushBasic: {
            src: "[pet:#animal#]You have a #pet#. Your #pet# is #mood#."
        },

        pushPop: {
            src: "[pet:#animal#]You have a #pet#. [pet:#animal#]Pet:#pet# [pet:POP]Pet:#pet#"
        },

        tagAction: {
            src: "#[pet:#animal#]nonrecursiveStory# post:#pet#"
        },

        testComplexGrammar: {
           src: "#origin#"
        },

        modifierWithParams: {
            src: "[pet:#animal#]#nonrecursiveStory# -> #nonrecursiveStory.replace(beach,mall)#"
        },

        modifierCapitalize: {
            src: "#capitalizeMe.capitalize#",
            expected: "SOME CAPITAL LETTERS"
        },

        modifierCapitalizeMore: {
            src: "#capitalizeMore.capitalize#",
            expected: "This sentence HAS CAPITALS IN IT"
        },

        modifierCapitalizeMoreEach: {
            src: "#capitalizeMore.capitalizeAll#",
            expected: "This Sentence HAS CAPITALS IN IT"
        },

        modifierCapitalizeEmpty: {
            src: "#empty.capitalize#",
            expected: ""
        },

        modifierCapitalizeSingle: {
            src: "#single.capitalize#",
            expected: "A"
        },

        recursivePush: {
           src: "[pet:#animal#]#recursiveStory#"
        },

        missingModifier: {
            src: "#animal.foo#",
            error: true
        },

        unmatchedHash: {
            src: "#unmatched",
            error: true
        },
        missingSymbol: {
            src: "#unicorns#",
            error: true
        },
        missingRightBracket: {
            src: "[pet:unicorn",
            error: true
        },
        missingLeftBracket: {
            src: "pet:unicorn]",
            error: true
        },
        justALotOfBrackets: {
            src: "[][]][][][[[]]][[]]]]",
            error: true
        },
        bracketTagMelange: {
            src: "[][#]][][##][[[##]]][#[]]]]",
            error: true
        }
        }

        tests.each { |k,v|
            puts "#{k}: "
            @grammar.clearState
            source = v[:src]
            is_error = v[:error].nil? ? false : v[:error]
            root = @grammar.expand(source)
            all_errors = root.allErrors

            expected = v[:expected]

            if(!expected.nil?) then
                assert(root.finishedText == expected, "\"#{root.finishedText}\" did not match \"#{expected}\"")
            end

            if(is_error) then
                refute(all_errors.empty?, "Expected errors.")
            else
                assert(all_errors.empty?, "Expected no errors.")
                if(!expected.nil? && !expected.empty?) then
                    refute(root.finishedText.empty?, "Expected non-empty output.")
                end
            end
        }
    end

    def test_symbolic_hash_grammars
        grammar = createGrammar({origin: "here's the origin, with an #extra#.", extra: "extra piece of text"})
        root = grammar.expand("#origin#")
        all_errors = root.allErrors
        assert(all_errors.empty?, "No errors should be generated")
        assert(root.finishedText == "here's the origin, with an extra piece of text.")
    end

    def test_set_rnd
        Tracery.setRnd(lambda { return 0 })
        assert(Tracery.random == 0)

        Tracery.setRnd(lambda { return 1 })
        assert(Tracery.random == 1)

        Tracery.resetRnd
        refute(Tracery.random == 1)
    end

    def test_deterministic_rules
        Tracery.setRnd(lambda { return 0 })
        text = @grammar.flatten("#origin#")
        assert(text == "Cheri was a great baker, and this song tells of their adventure. Cheri baked bread, then they baked bread, then they went home to read a book.")
    end
end
