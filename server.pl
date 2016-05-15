:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_log)).
:- use_module(library(http/http_files)).

:- use_module(library(md/md_parse)).

:- use_module('/Users/sf/Programming/prolog/swi/resumer/resume.pl').

add_rel_search_path(Alias, directory) :-
    must_be(ground, Alias),
    prolog_load_context(directory, Path),
    absolute_file_name(Path, AbsPath),
    asserta(file_search_path(Alias, AbsPath)).

add_rel_search_path(Alias, Path) :-
    must_be(ground, Alias),
    absolute_file_name(Path, AbsPath),
    asserta(file_search_path(Alias, AbsPath)).

:- add_rel_search_path(dir, directory).
:- add_rel_search_path(md, dir(md)).

:- multifile http:location/3.
:- dynamic   http:location/3.

http:location(files, '/f', []).

jquery_library('https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js').

:- html_resource(files('styles/style.css'), []).
:- jquery_library(JQuery),
   html_resource(JQuery, []).
:- jquery_library(JQuery),
   html_resource(files('js/basic.js'), [requires(JQuery)]).

:- http_handler(root(.), home, []).
:- http_handler(root(resume), resume, []).
:- http_handler(files(.), files, [prefix]).
:- http_handler(root(.), http_404([]), [prefix]).

% The predicate server(+Port) starts the server. It simply creates a
% number of Prolog threads and then returns to the toplevel, so you can
% (re-)load code, debug, etc.
run_server :- http_server(http_dispatch, [port(8000)]).

files(Request) :-
    absolute_file_name(dir(assets), Path),
    http_reply_from_files(Path, [], Request).

home(_Request) :-
    http_log('This works just like format ~w~n', ['Yeehaa']),
    reply_html_page(
            title('Shon Feder\'s Home Page'),
            [ \html_requires(files('js/basic.js')),
              \html_requires(files('styles/style.css')),
              \md_file(home) ]
        ).

resume(_Request) :-
    http_log('What does this do?', []),
    reply_html_page(
            title('Shon Feder\'s Resume'),
            \resume
        ).

md(String) --> {md_parse_string(String, HTML)},
               html(HTML).

md_file(DirName) -->
    {
        absolute_file_name(md(DirName), Path),
        (Extension = md ; Extension = txt),
        file_name_extension(Path, Extension, File),
        access_file(File, read),
        md_parse_file(File, HTML)
    },
    html(HTML).

resume -->
    html([dl(class=skill_set,
             [
                 dt("Languages"),
                 dd([ul([li(class=[language, communication],
                            'German : working proficiency'),
                         li(class=[language, communication],
                            'Spanish : beginner')
                        ])
                    ])
             ])]).

skill_set('Languages',
          [
              'German : working proficiency' : [language, communication],
              'Spanish : beginner' : [language, communication]
          ]).
