% Sophia Narvaez Y Laura Rodriguez - Practica 1, Parte B (Prolog)

:- use_module(library(lists)).

periodo_valido(P) :-
    P >= 262, P =< 292,
    Sem is P mod 10,
    member(Sem, [1,2]),
    Anio is P // 10,
    Anio >= 26, Anio =< 29.

periodo_texto(P, Texto) :-
    Anio is 2000 + (P // 10),
    Sem is P mod 10,
    format(atom(Texto), '~w-~w', [Anio, Sem]).

% divisores propios de N (sin contar el mismo N)
es_divisor_propio(N, D) :-
    between(1, N, D),
    D < N,
    0 is N mod D.

suma_aliquota(N, Suma) :-
    findall(D, es_divisor_propio(N, D), Ds),
    sum_list(Ds, Suma).

clasificacion(N, abundante) :- suma_aliquota(N, S), S > N.
clasificacion(N, perfecto)  :- suma_aliquota(N, S), S =:= N.
clasificacion(N, deficiente):- suma_aliquota(N, S), S < N.

categoria_nombre(abundante,   'Administrative').
categoria_nombre(perfecto,    'Engineering').
categoria_nombre(deficiente,  'Humanities').

paridad(Cod, even) :- 0 is Cod mod 2.
paridad(Cod, odd)  :- 1 is Cod mod 2.

% predicado principal: relaciona el codigo con sus 4 caracteristicas.
codigo_info(Cod, PeriodoTxt, CategoriaTxt, NumTxt, Par) :-
    integer(Cod),
    Cod >= 10000000, Cod =< 99999999,
    Periodo is Cod // 100000,
    periodo_valido(Periodo),
    Resto is Cod mod 100000,
    CatNum is Resto // 1000,
    Consec is Resto mod 1000,
    CatNum >= 1, CatNum =< 99,
    Consec >= 1, Consec =< 999,
    clasificacion(CatNum, Clase),
    categoria_nombre(Clase, CategoriaTxt),
    periodo_texto(Periodo, PeriodoTxt),
    format(atom(NumTxt), 'num~w', [Consec]),
    paridad(Cod, Par).

descripcion(Cod, D) :-
    codigo_info(Cod, P, C, N, Par),
    format(atom(D), '~w ~w ~w ~w', [P, C, N, Par]).

% dado un periodo y una categoria ya conocidos, genera todos los
% codigos posibles sin conocerlos de antemano
generar_codigos(Periodo, CategoriaTxt, Codigos) :-
    periodo_valido(Periodo),
    categoria_nombre(Clase, CategoriaTxt),
    findall(C,
        ( between(1, 99, CatNum),
          clasificacion(CatNum, Clase),
          between(1, 999, Consec),
          C is Periodo * 100000 + CatNum * 1000 + Consec
        ),
        Codigos).

primeros_n(L, N, P) :-
    length(P, N),
    ( append(P, _, L) -> true ; P = L ).

% pruebas con los ejemplos de la guia
pruebas :-
    writeln('ejemplos de la guia:'),
    forall(
        member(Cod, [26276002, 27128112, 27206025, 28124236, 28299115]),
        ( descripcion(Cod, D), format('~w -> ~w~n', [Cod, D]) )
    ),
    nl,
    ( codigo_info(26100001, _, _, _, _)
    -> writeln('26100001 no deberia pasar, algo esta mal')
    ;  writeln('26100001 (2026-1) rechazado, ok') ),
    ( codigo_info(2627600, _, _, _, _)
    -> writeln('2627600 no deberia pasar, algo esta mal')
    ;  writeln('2627600 (7 digitos) rechazado, ok') ),
    nl,
    writeln('consulta en modo generacion (periodo 292 = 2029-2, categoria Engineering):'),
    generar_codigos(292, 'Engineering', Cods),
    length(Cods, Total),
    primeros_n(Cods, 5, M),
    format('total: ~w, primeros: ~w~n', [Total, M]).

% pide un codigo por teclado y muestra la descripcion. 0 para salir.
menu :-
    nl,
    write('codigo (0 para salir): '),
    flush_output,
    catch(read(Cod), _, Cod = error_lectura),
    ( Cod == 0
    -> writeln('listo')
    ;  Cod == end_of_file
    -> writeln('fin de la entrada, listo')
    ;  Cod == error_lectura
    -> ( writeln('entrada invalida, intenta de nuevo'), menu )
    ;  ( descripcion(Cod, D)
       -> format('~w -> ~w~n', [Cod, D])
       ;  format('~w no es valido~n', [Cod]) ),
       menu
    ).

main :- pruebas, nl, menu.

:- initialization(main).