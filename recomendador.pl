:- use_module(library(csv)).
:- dynamic curso/4.
:- dynamic prerrequisito/2.
:- dynamic historial/3.
:- dynamic interes/2.

asegurar_numero(X, X) :- number(X), !.
asegurar_numero(X, N) :- atom(X), atom_number(X, N).

cargar_cursos :-
    csv_read_file('cursos.csv', [_Header|Filas], [functor(fila)]),
    forall(
        member(fila(Codigo, Nombre, Area, CreditosAtom), Filas),
        (
            asegurar_numero(CreditosAtom, Creditos),
            assertz(curso(Codigo, Nombre, Area, Creditos))
        )
    ).

cargar_prerrequisitos :-
    csv_read_file('prerrequisitos.csv', [_Header|Filas], [functor(fila)]),
    forall(
        member(fila(Curso, Prereq), Filas),
        assertz(prerrequisito(Curso, Prereq))
    ).

cargar_historial :-
    csv_read_file('historial.csv', [_Header|Filas], [functor(fila)]),
    forall(
        member(fila(Estudiante, Codigo, NotaAtom), Filas),
        (
            asegurar_numero(NotaAtom, Nota),
            assertz(historial(Estudiante, Codigo, Nota))
        )
    ).

cargar_intereses :-
    csv_read_file('intereses.csv', [_Header|Filas], [functor(fila)]),
    forall(
        member(fila(Estudiante, Area), Filas),
        assertz(interes(Estudiante, Area))
    ).

cargar_todo :-
    cargar_cursos,
    cargar_prerrequisitos,
    cargar_historial,
    cargar_intereses.

% Reglas logicas principales
aprobado(Estudiante, Curso) :-
    historial(Estudiante, Curso, Nota),
    Nota >= 11.

tiene_prerrequisito(Curso) :-
    prerrequisito(Curso, _).

puede_llevar(Estudiante, Curso) :-
    curso(Curso, _, _, _),
    \+ aprobado(Estudiante, Curso),
    forall(
        prerrequisito(Curso, Prereq),
        aprobado(Estudiante, Prereq)
    ).

recomendar_curso(Estudiante, Curso) :-
    curso(Curso, _, _, _),
    puede_llevar(Estudiante, Curso).

curso_bloqueado(Estudiante, Curso) :-
    curso(Curso, _, _, _),
    \+ aprobado(Estudiante, Curso),
    tiene_prerrequisito(Curso),
    \+ puede_llevar(Estudiante, Curso).

recomendar_por_interes(Estudiante, Curso) :-
    interes(Estudiante, Area),
    curso(Curso, _, Area, _),
    puede_llevar(Estudiante, Curso).

% Reglas auxiliares para reportes
cursos_aprobados(Estudiante, Lista) :-
    findall(Curso, aprobado(Estudiante, Curso), Lista).

cursos_desaprobados(Estudiante, Lista) :-
    findall(
        Curso,
        (historial(Estudiante, Curso, Nota), Nota < 11),
        Lista
    ).

cursos_disponibles(Estudiante, Lista) :-
    findall(Curso, recomendar_curso(Estudiante, Curso), Lista).

cursos_bloqueados_lista(Estudiante, Lista) :-
    findall(Curso, curso_bloqueado(Estudiante, Curso), Lista).

cursos_por_interes_lista(Estudiante, Lista) :-
    findall(Curso, recomendar_por_interes(Estudiante, Curso), Lista).

% Reporte completo del estudiante
mostrar_lista([]).
mostrar_lista([H|T]) :-
    write('    - '), write(H), nl,
    mostrar_lista(T).

mostrar_reporte(Estudiante) :-
    nl,
    write('Estudiante: '), write(Estudiante), nl,
    nl,

    cursos_aprobados(Estudiante, Aprobados),
    length(Aprobados, NumAprobados),
    write('Cursos aprobados ('), write(NumAprobados), write('):'), nl,
    mostrar_lista(Aprobados),
    nl,

    cursos_desaprobados(Estudiante, Desaprobados),
    length(Desaprobados, NumDesaprobados),
    write('Cursos desaprobados ('), write(NumDesaprobados), write('):'), nl,
    mostrar_lista(Desaprobados),
    nl,

    cursos_disponibles(Estudiante, Disponibles),
    length(Disponibles, NumDisponibles),
    write('Cursos disponibles para el siguiente ciclo ('), write(NumDisponibles), write('):'), nl,
    mostrar_lista(Disponibles),
    nl,

    cursos_bloqueados_lista(Estudiante, Bloqueados),
    length(Bloqueados, NumBloqueados),
    write('Cursos bloqueados por prerrequisitos pendientes ('), write(NumBloqueados), write('):'), nl,
    mostrar_lista(Bloqueados),
    nl,

    cursos_por_interes_lista(Estudiante, PorInteres),
    write('Cursos recomendados por areas de interes:'), nl,
    mostrar_lista(PorInteres),
    nl.