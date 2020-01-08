-module(test_helpers).

-export([string_with_unescaped_newline/0, string_with_escaped_newline/0]).

string_with_unescaped_newline() ->
    <<$", "\n", $">>.

string_with_escaped_newline() ->
    <<$", "\\", "n", $">>.
