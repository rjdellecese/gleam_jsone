-module(test_helpers).

-export([string_with_unescaped_newline/0, string_with_escaped_newline/0, string_with_invalid_utf8/0]).

string_with_unescaped_newline() ->
    <<$", "\n", $">>.

string_with_escaped_newline() ->
    <<$", "\\", "n", $">>.

string_with_invalid_utf8() ->
    <<34,190,72,94,90,253,121,94,71,73,68,91,122,211,253,32,94,86,67,163,253,230,34>>.
