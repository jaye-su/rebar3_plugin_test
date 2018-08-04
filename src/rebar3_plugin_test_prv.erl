%%%-------------------------------------------------------------------
%%% @author ztt
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 八月 2018 下午7:02
%%%-------------------------------------------------------------------
-module(rebar3_plugin_test_prv).
-author("ztt").
-define(PROVIDER, 'rebar3_plugin_test').
-define(DEPS, [app_discovery]).
-define(SHORT_DESC, "Automatically compile Google Protocol Buffer (.proto) ",
    "files using the gpb compiler").
-define(DESC, "Configure gpb options (gbp_opts) in your rebar.config, e.g.\n"
"  {gpb_opts,["
"    {i, \"path/to/proto_dir\"},"
"    {module_name_suffix, \"_pb\"},"
"    {o_erl, \"path/to/out_src\"},"
"    {o_hrl, \"path/to/out_include\"},"
"    {strings_as_binaries, true},"
"    type_specs]}).").

%% API
-export([init/1, format_error/1, do/1]).

init(State) ->
    Provider = providers:create([
        {name, ?PROVIDER},            % The 'user friendly' name of the task
        {module, ?MODULE},            % The module implementation of the task
        {bare, true},                 % The task can be run by the user, always true
        {deps, ?DEPS},                % The list of dependencies
        {example, "rebar3 rebar3_plugin_test"}, % How to use the plugin
        {opts, []},                   % list of options understood by the plugin
        {short_desc, "A rebar plugin"},
        {desc, "A rebar plugin"}
    ]),
    {ok, rebar_state:add_provider(State, Provider)}.

do(State) ->
    Apps = case rebar_state:current_app(State) of
               undefined ->
                   rebar_state:project_apps(State);
               AppInfo ->
                   [AppInfo]
           end,
    [begin
         Opts = rebar_app_info:opts(AppInfo),
         SourceDir = filename:join(rebar_app_info:dir(AppInfo), "src"),
         IncludeDir = filename:join(rebar_app_info:dir(AppInfo), "include"),
         FoundFiles = rebar_utils:find_files(SourceDir, ".*\\.csv\$"),

         CompileFun = fun(Source, _Opts1) ->
             ModName = filename:basename(Source, ".csv"),
             TargetName = ModName ++ ".erl",
             Hrl = ModName ++ ".hrl",
             %%    lists:foreach(fun rebar3_gpb_compiler:compile/1, Apps),
             {ok, Bin} = file:read_file("./src/for_txt"),
             io:format("~p~n", [Bin]),
             Lines = string:tokens(unicode:characters_to_list(Bin, latin1), [$\n]),
             [[Head, Content, Tail]] = string:tokens(Lines, ","),
             io:format("Head=~p~n Content=~p~n Tail=~p~n", [Head, Content, Tail]),
             L = string:tokens(Head, [$\s]),
             Start = lists:nth(6, L),
             End = lists:nth(10, L),
             Str1 = "-module(for_txt).\n -export([start/0]).\n start()->\nlists:foreach(fun(X)->io:format(\"~p~n\"+[X]) end,lists:seq(" ++ Start ++ "," ++ End ++ ")).\n",
             %%    {ok,Files}=file:list_dir_all("./src"),
             file:write_file("./src/for_txt.erl", Str1)
                      end,

         rebar_base_compiler:run(Opts, [], [], CompileFun)
     end || AppInfo <- Apps],

    {ok, State}.

-spec format_error(any()) -> iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
