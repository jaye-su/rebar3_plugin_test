%%%-------------------------------------------------------------------
%%% @author ztt
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 八月 2018 下午7:04
%%%-------------------------------------------------------------------
-module(rebar3_plugin_test).
-author("ztt").

%% API
-export([init/1]).
init(State) ->
    {ok, State1} = 'rebar3_plugin_test_prv':init(State),
    {ok, State1}.
